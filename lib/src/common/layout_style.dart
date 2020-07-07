// Copyright (c) 2020, Tonic Artos
//
// Tonic Artos: http://www.tonicartos.nz/
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

enum LayoutStylePreference {
  materialPreferred,
  material,
  cupertino,
  cupertinoPreferred,
}

enum LayoutStyle { material, cupertino }

extension LayoutStyleStringer on LayoutStylePreference {
  String get text {
    switch (this) {
      case LayoutStylePreference.materialPreferred:
        return 'Material Preferred';
      case LayoutStylePreference.material:
        return 'Material';
      case LayoutStylePreference.cupertino:
        return 'Cupertino';
      case LayoutStylePreference.cupertinoPreferred:
        return 'Cupertino Preferred';
      default:
        throw UnknownLayoutStyleException(this);
    }
  }
}

class UnknownLayoutStyleException {
  UnknownLayoutStyleException(Object v)
      : message = 'Unknown value: $v on LayoutStyle';

  final String message;

  @override
  String toString() {
    if (message == null) return "Exception";
    return 'Exception: $message';
  }
}

/// Use to determine which widget style to use.
///
/// Note: pass [kIsWeb] as value for [isWeb].
LayoutStyle styleChoice(
  TargetPlatform platform,
  LayoutStylePreference style, [
  bool isWeb = false,
]) {
  if (style == LayoutStylePreference.cupertino) {
    // Forced to use cupertino icon for all platforms.
    return LayoutStyle.cupertino;
  } else if (style == LayoutStylePreference.materialPreferred &&
      (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS)) {
    // Cupertino icon selected based on platform preference.
    return LayoutStyle.cupertino;
  } else if (style == LayoutStylePreference.cupertinoPreferred &&
      (isWeb ||
          platform != TargetPlatform.android &&
              platform != TargetPlatform.fuchsia)) {
    // Cupertino icon selected to be preferred for non-Google platforms.
    return LayoutStyle.cupertino;
  } else {
    // Material icon.
    return LayoutStyle.material;
  }
}
