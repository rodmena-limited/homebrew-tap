#!/usr/bin/env python3
"""
Homebrew tap formula updater.

Queries PyPI JSON API for each formula in Formula/ and updates the URL
and SHA256 when a newer version is available.

Usage:
    python3 scripts/update.py          # Apply updates
    python3 scripts/update.py --dry-run  # Dry-run (exit 1 if updates available)
    python3 scripts/update.py -f issuedb  # Update a single formula
"""

import argparse
import json
import os
import re
import sys
import urllib.error
import urllib.request

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FORMULA_DIR = os.path.join(REPO_ROOT, "Formula")
PYPI_API = "https://pypi.org/pypi/{}/json"
USER_AGENT = "homebrew-tap-updater/1.0"


# ── Helpers ──────────────────────────────────────────────────────────

def pypi_json(package_name):
    """Fetch PyPI JSON for *package_name*. Returns None on 404."""
    url = PYPI_API.format(package_name)
    req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            return json.loads(resp.read())
    except urllib.error.HTTPError as e:
        if e.code == 404:
            return None
        raise


def fmt_pypi_name(formula_name):
    """Derive the PyPI package name from a formula filename stem."""
    return formula_name.replace("_", "-")


def sdist_info(pypi_data):
    """Return dict {url, sha256, version} for the sdist of the latest release."""
    for u in pypi_data["urls"]:
        if u["packagetype"] == "sdist":
            return {
                "url": u["url"],
                "sha256": u["digests"]["sha256"],
                "version": pypi_data["info"]["version"],
            }
    return None


def current_version_from_url(url, pypi_name):
    """
    Extract the current version from an sdist URL.

    The URL basename is ``{pypi_name_with_underscores}-{version}.tar.gz``.
    We reverse-search for the first hyphen after removing ``.tar.gz``.
    """
    basename = url.rsplit("/", 1)[-1]               # name-1.2.3.tar.gz
    stem = basename[:-7] if basename.endswith(".tar.gz") else basename

    # The part before the last `-<version>` is the package name (with _).
    # We know the PyPI name, so look for its underscore form as a prefix.
    name_und = pypi_name.replace("-", "_")
    prefix = name_und + "-"
    if stem.startswith(prefix):
        return stem[len(prefix):]

    # Fallback: formula file name (already underscores)
    prefix = pypi_name.replace("-", "_") + "-"
    if stem.startswith(prefix):
        return stem[len(prefix):]

    return None


def replace_url_and_sha256(content, new_url, new_sha256):
    """Surgically replace the ``url`` and ``sha256`` lines."""
    content = re.sub(
        r'(^\s+url\s+)"[^"]*"',
        lambda m: f'{m.group(1)}"{new_url}"',
        content,
        count=1,
        flags=re.MULTILINE,
    )
    content = re.sub(
        r'(^\s+sha256\s+)"[^"]*"',
        lambda m: f'{m.group(1)}"{new_sha256}"',
        content,
        count=1,
        flags=re.MULTILINE,
    )
    return content


# ── Main ─────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(description="Update Homebrew tap formulae from PyPI")
    parser.add_argument(
        "--dry-run", "-n", action="store_true",
        help="Check for updates without modifying files; exit 1 if any found",
    )
    parser.add_argument(
        "--formula", "-f",
        help="Update only a specific formula (filename without .rb)",
    )
    args = parser.parse_args()

    os.makedirs(FORMULA_DIR, exist_ok=True)

    if args.formula:
        formula_files = [os.path.join(FORMULA_DIR, args.formula + ".rb")]
    else:
        formula_files = sorted(
            os.path.join(FORMULA_DIR, f)
            for f in os.listdir(FORMULA_DIR)
            if f.endswith(".rb")
        )

    if not formula_files:
        print("No formula files found.", file=sys.stderr)
        return 1

    updates = []
    errors = []
    up_to_date = 0

    for fp in formula_files:
        fname = os.path.splitext(os.path.basename(fp))[0]
        pypi_name = fmt_pypi_name(fname)

        # Read content
        try:
            with open(fp) as fh:
                content = fh.read()
        except OSError as e:
            errors.append(f"{fname}: Cannot read file – {e}")
            continue

        # Extract current URL
        m_url = re.search(r'^\s+url\s+"([^"]+)"', content, re.MULTILINE)
        if not m_url:
            errors.append(f"{fname}: No url line found")
            continue

        current_url = m_url.group(1)

        # Extract current version from URL
        current_ver = current_version_from_url(current_url, pypi_name)
        if current_ver is None:
            errors.append(f"{fname}: Cannot extract version from URL {current_url}")
            continue

        # Fetch PyPI data
        data = pypi_json(pypi_name)
        if data is None:
            # Edge case: maybe PyPI name uses underscores
            alt_name = pypi_name.replace("-", "_")
            data = pypi_json(alt_name)
        if data is None:
            errors.append(f"{fname}: Package not found on PyPI")
            continue

        latest_ver = data["info"]["version"]

        if current_ver == latest_ver:
            print(f"✓ {fname}  {current_ver}")
            up_to_date += 1
            continue

        # Fetch sdist info for the latest version
        info = sdist_info(data)
        if info is None:
            errors.append(f"{fname}: No sdist for {latest_ver}")
            continue

        print(f"↑ {fname}  {current_ver} → {latest_ver}")

        updates.append({
            "filepath": fp,
            "content": content,
            "new_url": info["url"],
            "new_sha256": info["sha256"],
        })

    # ── Report ────────────────────────────────────────────────────────

    if errors:
        print(file=sys.stderr)
        for e in errors:
            print(f"  error: {e}", file=sys.stderr)

    if args.dry_run:
        if updates:
            print(f"\n→ {len(updates)} update(s) available")
            return 1
        if errors:
            return 1
        return 0

    # Apply updates
    for u in updates:
        new_content = replace_url_and_sha256(
            u["content"], u["new_url"], u["new_sha256"],
        )
        with open(u["filepath"], "w") as fh:
            fh.write(new_content)
        print(f"  ✔ {os.path.basename(u['filepath'])}")

    # Summary
    print(f"\n─── {len(updates)} updated, {up_to_date} up-to-date"
          f"{', ' + str(len(errors)) + ' errors' if errors else ''} ───")

    return 1 if updates else 0


if __name__ == "__main__":
    sys.exit(main())
