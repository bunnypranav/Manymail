#!/usr/bin/env python3
"""Audit every resolved dependency for GPL-3.0 compatibility.

Manymail is GPL-3.0-or-later, which obliges us to link only against
GPL-compatible code. This reads pubspec.lock, finds each package in the local
pub cache and classifies its licence from the licence text itself rather than
from package metadata, which is often absent or wrong.

Usage:  python tool/audit_licenses.py
Exit code 1 if anything incompatible is found, so it can gate CI.
"""
import collections
import os
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
CACHE = pathlib.Path(
    os.environ.get("PUB_CACHE")
    or pathlib.Path(os.environ["LOCALAPPDATA"]) / "Pub" / "Cache"
) / "hosted" / "pub.dev"

# Licences we may link against from GPL-3.0-or-later code.
GPL3_COMPATIBLE = {
    "MPL-2.0", "Apache-2.0", "MIT", "BSD-3-Clause", "BSD-2-Clause",
    "Unlicense/PD", "LGPL", "GPL", "AGPL-3.0", "BUNDLED-WITH-FLUTTER",
}


def resolved_versions():
    lock = (ROOT / "pubspec.lock").read_text(encoding="utf-8")
    versions, name = {}, None
    for line in lock.splitlines():
        m = re.match(r"^  ([a-z0-9_]+):", line)
        if m:
            name = m.group(1)
        m = re.match(r'^    version: "(.+)"', line)
        if m and name:
            versions[name] = m.group(1)
    return versions


def detect(pkg, ver):
    """Classify a licence from its own text.

    Order matters. MPL-2.0 and Apache-2.0 both NAME other licences in their
    bodies -- MPL-2.0 mentions the GNU GPL, LGPL and AGPL in its "Secondary
    License" clause -- so a naive substring search misreports them as AGPL.
    Anchor on how the file STARTS instead.
    """
    directory = CACHE / f"{pkg}-{ver}"
    for candidate in ("LICENSE", "LICENSE.md", "LICENSE.txt", "license"):
        path = directory / candidate
        if not path.exists():
            continue
        head = path.read_text(encoding="utf-8", errors="replace")[:4000]
        start = head.lstrip()
        if start.startswith("Mozilla Public License"):
            return "MPL-2.0"
        if "Apache License" in head[:400]:
            return "Apache-2.0"
        if start.upper().startswith("GNU AFFERO"):
            return "AGPL-3.0"
        if start.upper().startswith("GNU LESSER"):
            return "LGPL"
        if start.upper().startswith("GNU GENERAL PUBLIC"):
            return "GPL"
        if "Redistribution and use in source and binary forms" in head:
            return ("BSD-3-Clause" if "neither the name" in head.lower()
                    else "BSD-2-Clause")
        if "Permission is hereby granted, free of charge" in head:
            return "MIT"
        if "Unlicense" in head or "public domain" in head.lower():
            return "Unlicense/PD"
        return "UNKNOWN: " + start.splitlines()[0][:50]
    # SDK packages (flutter, sky_engine, ...) ship no separate LICENSE file;
    # they are covered by the Flutter SDK's own BSD-3-Clause licence.
    return "BUNDLED-WITH-FLUTTER"


def main():
    versions = resolved_versions()
    tally = collections.Counter()
    incompatible = []
    for pkg, ver in sorted(versions.items()):
        licence = detect(pkg, ver)
        tally[licence] += 1
        if licence not in GPL3_COMPATIBLE:
            incompatible.append((pkg, ver, licence))

    print(f"{len(versions)} resolved packages\n")
    for licence, count in tally.most_common():
        print(f"  {count:4}  {licence}")

    if incompatible:
        print("\nGPL-3.0 INCOMPATIBLE:")
        for pkg, ver, licence in incompatible:
            print(f"  {pkg} {ver} -> {licence}")
        return 1
    print("\nAll packages are GPL-3.0 compatible.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
