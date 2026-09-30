#!/usr/bin/env python3
"""Write one F-Droid changelog per ABI build of the current release.

F-Droid looks up release notes by version code, literally:
fastlane/metadata/android/<locale>/changelogs/<versionCode>.txt. There is no
fallback file. Manymail's F-Droid builds are one APK per ABI, each with its own
version code (versionCode * 10 + abi, set in android/app/build.gradle.kts), so a
single release needs three identical changelog files:

    version: 1.0.0+1   ->   changelogs/11.txt, 12.txt, 13.txt

Keeping three copies in step by hand is how one of them ends up stale. This
reads the version code from pubspec.yaml and writes all three from one source.

Usage:
    python tool/fdroid_changelogs.py notes.txt   # write all three from notes.txt
    python tool/fdroid_changelogs.py             # check the current release's files

Exit code 1 if anything is missing, over F-Droid's 500-character limit, or the
three copies disagree.
"""
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
CHANGELOGS = ROOT / "fastlane" / "metadata" / "android" / "en-US" / "changelogs"
LIMIT = 500

# Must match abiDigits in android/app/build.gradle.kts.
ABIS = {"armeabi-v7a": 1, "arm64-v8a": 2, "x86_64": 3}


def version():
    text = (ROOT / "pubspec.yaml").read_text(encoding="utf-8")
    m = re.search(r"^version:\s*([^\s+]+)\+(\d+)\s*$", text, re.M)
    if not m:
        sys.exit("pubspec.yaml has no 'version: x.y.z+N' line")
    return m.group(1), int(m.group(2))


def main():
    name, code = version()
    targets = {abi: CHANGELOGS / f"{code * 10 + digit}.txt"
               for abi, digit in ABIS.items()}

    if len(sys.argv) > 1:
        notes = pathlib.Path(sys.argv[1]).read_text(encoding="utf-8").strip()
        if len(notes) > LIMIT:
            sys.exit(f"{len(notes)} characters; F-Droid allows {LIMIT}")
        CHANGELOGS.mkdir(parents=True, exist_ok=True)
        for path in targets.values():
            path.write_text(notes + "\n", encoding="utf-8", newline="\n")
        print(f"{name}+{code}: wrote {', '.join(p.name for p in targets.values())}")
        return 0

    problems = []
    contents = set()
    for abi, path in targets.items():
        if not path.exists():
            problems.append(f"missing {path.name} ({abi})")
            continue
        body = path.read_text(encoding="utf-8").strip()
        contents.add(body)
        state = "ok" if len(body) <= LIMIT else "OVER"
        print(f"  [{state:4}] {path.name:8} {abi:12} {len(body):>4} / {LIMIT}")
        if len(body) > LIMIT:
            problems.append(f"{path.name} is over {LIMIT} characters")
    if len(contents) > 1:
        problems.append("the three changelogs are not identical")

    if problems:
        print("\n" + "\n".join(problems))
        return 1
    print(f"\n{name}+{code}: all three F-Droid changelogs present and identical.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
