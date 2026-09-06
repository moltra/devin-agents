#Requires -Version 5.1
<#
.SYNOPSIS
    Install or update Devin agent templates and skills.

.DESCRIPTION
    Asks whether to install locally (current project: .\.devin) or globally (user
    Devin config: %APPDATA%\devin). On non-interactive terminals it defaults to
    global.

    Installs agent templates as named AGENT.md profiles and copies skills from
    plugins/devin-agents/skills and .devin/skills. Existing files are backed up before overwriting.

    If the script is not run from inside the repository, it clones the repository to
    a temporary directory automatically.

.PARAMETER DevinConfig
    Override the target Devin configuration directory. Skips the local/global prompt.

.PARAMETER Local
    Install into the current project directory (.\devin).

.PARAMETER Global
    Install into the user Devin configuration directory.

.PARAMETER InstallMode
    Explicitly set the scope to local or global (alternative to -Local/-Global).

.PARAMETER RepoUrl
    Git repository URL to clone when running standalone.

.PARAMETER RepoBranch
    Git branch to clone when running standalone.

.EXAMPLE
    .\scripts\install-agents.ps1

.EXAMPLE
    .\scripts\install-agents.ps1 -Local

.EXAMPLE
    .\scripts\install-agents.ps1 -Global

.EXAMPLE
    .\scripts\install-agents.ps1 -DevinConfig "C:\Users\Me\AppData\Roaming\devin"

.EXAMPLE
    irm https://raw.githubusercontent.com/moltra/devin-agents/main/scripts/install-agents.ps1 | iex
#>
[CmdletBinding()]
param(
    [string]$DevinConfig = "",
    [switch]$Local,
    [switch]$Global,
    [string]$InstallMode = "",
    [string]$RepoUrl = "https://github.com/moltra/devin-agents.git",
    [string]$RepoBranch = "main"
)

$ErrorActionPreference = "Stop"

$tmpRepoDir = $null

function Locate-Repo {
    $scriptDir = $null
    if ($PSCommandPath) {
        $scriptDir = Split-Path -Parent $PSCommandPath
    }

    if ($scriptDir) {
        $candidate = Split-Path -Parent $scriptDir
        if ((Test-Path (Join-Path $candidate "templates")) -and
            (Test-Path (Join-Path (Join-Path (Join-Path $candidate "plugins") "devin-agents") "skills"))) {
            return $candidate
        }
    }

    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        throw "git is not installed and the repository is not available locally."
    }

    $tmpDir = Join-Path $env:TEMP ("devin-automations-" + (Get-Random))
    Write-Host "Repository not found locally. Cloning to $tmpDir..."
    git clone --depth 1 --branch $RepoBranch $RepoUrl $tmpDir | Out-Null
    $script:tmpRepoDir = $tmpDir
    return $tmpDir
}

function Select-InstallScope {
    if ($DevinConfig) {
        return "global"
    }

    if ($Local) {
        return "local"
    }

    if ($Global) {
        return "global"
    }

    if ($InstallMode) {
        $mode = $InstallMode.ToLower()
        if ($mode -ne "local" -and $mode -ne "global") {
            throw "Invalid InstallMode: $InstallMode. Must be local or global."
        }
        return $mode
    }

    if ($Host.UI.RawUI -and [Environment]::UserInteractive) {
        $prompt = "Install locally (current project: $PWD\.devin) or globally (user config)? [local/global]"
        $response = Read-Host $prompt
        $mode = $response.ToLower()
        if ($mode -ne "local" -and $mode -ne "global") {
            Write-Host "Invalid choice: $response. Defaulting to global."
            $mode = "global"
        }
        return $mode
    }

    return "global"
}

$repoDir = Locate-Repo
$scope = Select-InstallScope

if ($DevinConfig) {
    $devinConfig = $DevinConfig
} elseif ($scope -eq "local") {
    $devinConfig = Join-Path $PWD "devin"
} else {
    $devinConfig = Join-Path $env:APPDATA "devin"
}

$backupDir = Join-Path $devinConfig ("backup-" + (Get-Date -Format "yyyyMMdd-HHmmss"))
$agentsDir = Join-Path $devinConfig "agents"
$skillsDir = Join-Path $devinConfig "skills"

Write-Host "Installing Devin agents and skills..."
Write-Host "Scope:      $scope"
Write-Host "Repository: $repoDir"
Write-Host "Target:     $devinConfig"

New-Item -ItemType Directory -Force -Path $agentsDir | Out-Null
New-Item -ItemType Directory -Force -Path $skillsDir | Out-Null
New-Item -ItemType Directory -Force -Path $backupDir | Out-Null

# Backup existing agents and skills if they contain data.
if (Test-Path $agentsDir) {
    $children = Get-ChildItem -Path $agentsDir -Force
    if ($children) {
        Copy-Item -Path $agentsDir -Destination $backupDir -Recurse -Force
    }
}
if (Test-Path $skillsDir) {
    $children = Get-ChildItem -Path $skillsDir -Force
    if ($children) {
        Copy-Item -Path $skillsDir -Destination $backupDir -Recurse -Force
    }
}

Write-Host "`nInstalling/updating agents..."
$templates = Get-ChildItem -Path (Join-Path $repoDir "templates") -Filter "*.md"
foreach ($template in $templates) {
    $name = $template.BaseName -replace '-template$', ''
    $targetDir = Join-Path $agentsDir $name
    $targetFile = Join-Path $targetDir "AGENT.md"

    if (Test-Path $targetFile) {
        Write-Host "  Updating agent: $name"
    } else {
        Write-Host "  Installing agent: $name"
    }

    New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
    Copy-Item -Path $template.FullName -Destination $targetFile -Force
}

Write-Host "`nInstalling/updating skills..."
function Install-SkillsFrom {
    param([string]$SourceDir)

    if (-not (Test-Path $SourceDir)) {
        return
    }

    $skillDirs = Get-ChildItem -Path $SourceDir -Directory
    foreach ($skillDir in $skillDirs) {
        $name = $skillDir.Name
        $targetDir = Join-Path $skillsDir $name

        if (Test-Path $targetDir) {
            Write-Host "  Updating skill: $name"
        } else {
            Write-Host "  Installing skill: $name"
        }

        Copy-Item -Path $skillDir.FullName -Destination $targetDir -Recurse -Force
    }
}

Install-SkillsFrom -SourceDir (Join-Path (Join-Path (Join-Path $repoDir "plugins") "devin-agents") "skills")
Install-SkillsFrom -SourceDir (Join-Path (Join-Path $repoDir ".devin") "skills")

Write-Host "`nInstallation complete."
Write-Host "Backup: $backupDir"
Write-Host "`nNext steps:"
Write-Host "1. Review backed-up files if you had customizations."
Write-Host "2. Restart Devin to load the updated configurations."

if ($tmpRepoDir -and (Test-Path $tmpRepoDir)) {
    Remove-Item -Path $tmpRepoDir -Recurse -Force
}
