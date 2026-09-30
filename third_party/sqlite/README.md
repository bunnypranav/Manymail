# SQLite amalgamation

The SQLite library that Manymail's database runs on, as source.

| | |
|---|---|
| Version | **3.53.4** |
| Source | <https://sqlite.org/2026/sqlite-amalgamation-3530400.zip> |
| SHA3-256 of that zip | `628a44cfe82c66aed1ccbbe85a562d2e33ebe64b3288981ed76285612227934e` |
| Licence | Public domain — <https://sqlite.org/copyright.html> |
| Files kept | `sqlite3.c`, `sqlite3.h`, `sqlite3ext.h`, unmodified |

## Why it is here

`package:sqlite3` (used through drift) ships a build hook that, by default,
**downloads a precompiled `libsqlite3.so` from GitHub** at build time. That is a
binary nobody built from this repository, fetched over the network during the
build.

F-Droid forbids exactly that: every native binary it ships has to be compiled
from source on its own build server. So `pubspec.yaml` tells the hook to
compile this file instead:

```yaml
hooks:
  user_defines:
    sqlite3:
      source: source
      path: third_party/sqlite/sqlite3.c
```

It applies to **every** build, not just F-Droid's, so the Play build and the
F-Droid build run the same SQLite compiled the same way. Nothing is downloaded.

The version matches what `package:sqlite3` would otherwise have downloaded, so
switching to it changed nothing about how the database behaves. That was
checked against a real device: a database written by the old prebuilt library
opened unchanged under this one.

## What it costs

Compiling SQLite needs a C compiler:

- **Android builds** use the NDK. Flutter 3.47.4 pins NDK `28.2.13676358`
  (r28c). Android Studio or `sdkmanager` installs it.
- **`flutter test`** also runs the hook for your own machine, so it needs a host
  compiler: Visual Studio Build Tools (MSVC) on Windows, Xcode command-line
  tools on macOS, `clang` or `gcc` on Linux.

## Updating it

Keep it in step with the SQLite version `package:sqlite3` expects. That version
is in the package's `CHANGELOG.md` ("Upgrade SQLite to 3.x.y").

1. Download the matching `sqlite-amalgamation-XXXXXXX.zip` from
   <https://sqlite.org/download.html>. The page lists its SHA3-256.
2. Verify it:

   ```bash
   python -c "import hashlib,sys; print(hashlib.sha3_256(open(sys.argv[1],'rb').read()).hexdigest())" sqlite-amalgamation-XXXXXXX.zip
   ```

3. Replace the three files here with the ones from the zip.
4. Update the table at the top of this file.
5. Confirm the version landed:

   ```bash
   grep -m1 '#define SQLITE_VERSION ' third_party/sqlite/sqlite3.h
   ```
