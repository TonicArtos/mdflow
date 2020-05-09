// Copyright (c) 2020, Tonic Artos
//
// Tonic Artos: http://www.tonicartos.nz/
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

part of mdflow;

PageRoute _choosePageRoute(
    TargetPlatform platform,
    MdFlowConfiguration configuration,
    WidgetBuilder builder,
    ) {
  switch (_styleChoice(platform, configuration)) {
    case _StyleChoice.cupertino:
      return CupertinoPageRoute(builder: builder);
    case _StyleChoice.material:
    default:
      return MaterialPageRoute(builder: builder);
  }
}

_StyleChoice _styleChoice(TargetPlatform platform, MdFlowConfiguration configuration) {
  if (configuration.style == MdFlowLayoutStyle.cupertino) {
    // Forced to use cupertino icon for all platforms.
    return _StyleChoice.cupertino;
  } else if (configuration.style == MdFlowLayoutStyle.materialPreferred &&
      (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS)) {
    // Cupertino icon selected based on platform preference.
    return _StyleChoice.cupertino;
  } else if (configuration.style == MdFlowLayoutStyle.cupertinoPreferred &&
      (kIsWeb || platform != TargetPlatform.android && platform != TargetPlatform.fuchsia)) {
    // Cupertino icon selected to be preferred for non-Google platforms.
    return _StyleChoice.cupertino;
  } else {
    // Material icon.
    return _StyleChoice.material;
  }
}

enum _StyleChoice { material, cupertino }
