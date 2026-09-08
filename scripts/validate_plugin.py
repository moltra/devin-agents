#!/usr/bin/env python3
"""Validate plugin structure and frontmatter. Used by CI."""
import glob
import sys
import yaml


def check_frontmatter(path, required_keys):
    """Check that a markdown file has valid YAML frontmatter with required keys."""
    with open(path) as f:
        content = f.read()
    if not content.startswith("---"):
        return f"{path}: missing frontmatter delimiter"
    parts = content.split("---", 2)
    if len(parts) < 3:
        return f"{path}: malformed frontmatter"
    try:
        fm = yaml.safe_load(parts[1])
    except yaml.YAMLError as e:
        return f"{path}: {e}"
    if not isinstance(fm, dict):
        return f"{path}: frontmatter is not a mapping"
    for key in required_keys:
        if key not in fm:
            return f"{path}: missing {key}"
    return None


def main():
    errors = []

    # Validate agent profiles
    for path in sorted(glob.glob("plugins/devin-agents/agents/*/AGENT.md")):
        err = check_frontmatter(path, ["name", "description"])
        if err:
            errors.append(err)

    # Validate skill profiles
    for path in sorted(glob.glob("plugins/devin-agents/skills/*/SKILL.md")):
        err = check_frontmatter(path, ["name", "description"])
        if err:
            errors.append(err)

    # Validate issue templates
    for path in sorted(glob.glob(".github/ISSUE_TEMPLATE/*.md")):
        err = check_frontmatter(path, ["name"])
        if err:
            errors.append(err)

    if errors:
        for e in errors:
            print(f"FAIL: {e}")
        sys.exit(1)

    agents = len(glob.glob("plugins/devin-agents/agents/*/AGENT.md"))
    skills = len(glob.glob("plugins/devin-agents/skills/*/SKILL.md"))
    print(f"All profiles have valid YAML frontmatter ({agents} agents, {skills} skills)")


if __name__ == "__main__":
    main()
