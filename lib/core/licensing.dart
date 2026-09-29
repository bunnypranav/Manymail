// Manymail - Many addresses, one app.
// Copyright (C) 2026 Bunny Pranav
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This file is part of Manymail, distributed under the GNU General Public
// License v3 or later. See the LICENSE file at the root of this repository.

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The app's own licence identity, and the notices the GPL asks an interactive
/// program to show.
///
/// Flutter already collects a licence for every *bundled package* and shows
/// them in `showLicensePage`. It knows nothing about the licence of the
/// application itself, so [registerAppLicense] adds ours to the same registry
/// — which means a user can read the full GPL text inside the app rather than
/// being told to go and find it.
abstract final class Licensing {
  const Licensing._();

  static const appName = 'Manymail';
  static const tagline = 'Many addresses, one app';

  /// Kept in step with `version:` in pubspec.yaml.
  static const version = '1.0.0';

  static const copyright = 'Copyright (C) 2026 Bunny Pranav';

  static const spdx = 'GPL-3.0-or-later';

  static const licenseName = 'GNU General Public License v3.0 or later';

  static const sourceUrl = 'https://github.com/bunnypranav/Manymail';

  /// The short notice GPL-3.0 section 0 calls "Appropriate Legal Notices":
  /// copyright, no warranty, and how to get the source.
  static const legalese =
      '$copyright\n\n'
      'Manymail is free software: you can redistribute it and/or modify it '
      'under the terms of the GNU General Public License as published by the '
      'Free Software Foundation, either version 3 of the License, or (at your '
      'option) any later version.\n\n'
      'Manymail is distributed in the hope that it will be useful, but '
      'WITHOUT ANY WARRANTY; without even the implied warranty of '
      'MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU '
      'General Public License for more details.';

  static var _registered = false;

  /// Adds the bundled `LICENSE` file to Flutter's licence registry.
  ///
  /// Registered lazily by the registry itself, so the 35 KB of licence text is
  /// only read if the user actually opens the licences page.
  static void registerAppLicense() {
    if (_registered) return;
    _registered = true;

    LicenseRegistry.addLicense(() async* {
      try {
        final text = await rootBundle.loadString('LICENSE');
        yield LicenseEntryWithLineBreaks(const ['Manymail'], text);
      } catch (error) {
        // A missing asset must never crash the licences page. Fall back to the
        // short notice, which is the part that legally matters most.
        debugPrint('Could not load bundled LICENSE: $error');
        yield const LicenseEntryWithLineBreaks(
          ['Manymail'],
          '$legalese\n\n'
          'The full licence text could not be loaded from this build. '
          'It is available at https://www.gnu.org/licenses/gpl-3.0.txt',
        );
      }
    });
  }
}
