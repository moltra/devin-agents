#!/usr/bin/env python3
"""
Devin pre-commit review hook.

Runs syntax validation, ruff lint, black format check, isort check,
and bandit security scan on Python files. Designed to be used as a
local pre-commit hook entry point.

Usage in .pre-commit-config.yaml:
    - repo: local
      hooks:
        - id: devin-review
          name: Devin Code Review
          entry: python3 ~/.config/devin/scripts/review_code.py
          language: system
          pass_filenames: true
          stages: [pre-commit]

When invoked by pre-commit, the file list is passed via argv (so
`pre-commit run --all-files` works correctly in CI). When invoked
manually without arguments, it falls back to `git diff --cached` to
inspect staged files only.
"""

import subprocess
import sys
from pathlib import Path


def get_files_from_argv() -> list[str]:
    """Return file list passed by pre-commit via argv."""
    return [f for f in sys.argv[1:] if f and Path(f).suffix == ".py"]


def get_staged_python_files() -> list[str]:
    """Return list of staged .py files (fallback when no argv given)."""
    result = subprocess.run(
        ["git", "diff", "--cached", "--name-only", "-z", "--diff-filter=ACM"],
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        print(f"  git diff failed (exit {result.returncode}): {result.stderr.strip()}")
        return []
    # -z uses NUL separators; the trailing element is "" which we filter out
    files = result.stdout.split("\0")
    return [f for f in files if f and Path(f).suffix == ".py"]


def run_tool(cmd: list[str], label: str, required: bool = True) -> bool:
    """Run a command and report pass/fail. Returns True if passed.

    If the tool is not found:
      - required=True  -> FAIL (return False) so missing tools don't
        silently pass the hook.
      - required=False -> skip with a warning (return True).
    """
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=120)
        if result.returncode != 0:
            print(f"  {label} found issues:")
            # Print first 50 lines of output to avoid flooding
            lines = (result.stdout + result.stderr).strip().split("\n")
            for line in lines[:50]:
                print(f"    {line}")
            if len(lines) > 50:
                print(f"    ... ({len(lines) - 50} more lines)")
            return False
        return True
    except FileNotFoundError:
        if required:
            print(f"  {label}: tool not found on PATH — install it or fix PATH.")
            return False
        else:
            print(f"  {label}: tool not found, skipping (non-blocking).")
            return True
    except subprocess.TimeoutExpired:
        print(f"  {label}: timed out after 120s")
        return False


def main() -> int:
    # Prefer file list from pre-commit (argv); fall back to staged files
    # so manual invocation without args still works.
    files = get_files_from_argv() or get_staged_python_files()

    if not files:
        print("No Python files to review.")
        return 0

    print(f"Devin review: checking {len(files)} Python file(s)...")
    for f in files:
        print(f"  - {f}")

    all_passed = True

    # 1. Ruff lint (also catches syntax errors via E999, so a separate
    #    compile() pass would be redundant).
    print("\n1/4 Ruff lint...")
    if not run_tool(["ruff", "check"] + files, "ruff", required=True):
        all_passed = False

    # 2. Black format check
    print("\n2/4 Black format check...")
    if not run_tool(["black", "--check"] + files, "black", required=True):
        all_passed = False

    # 3. isort import check
    print("\n3/4 isort import check...")
    if not run_tool(["isort", "--check-only"] + files, "isort", required=True):
        all_passed = False

    # 4. Bandit security scan (non-blocking — warn only)
    print("\n4/4 Bandit security scan (warn-only)...")
    run_tool(["bandit", "-q"] + files, "bandit", required=False)

    # Summary
    print("\n" + "=" * 50)
    if all_passed:
        print("PASS: All pre-commit checks passed.")
        return 0
    else:
        print("FAIL: Pre-commit checks found issues. Fix above before committing.")
        return 1


if __name__ == "__main__":
    sys.exit(main())
