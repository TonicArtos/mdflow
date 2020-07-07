// Copyright (c) 2020, Tonic Artos
//
// Tonic Artos: http://www.tonicartos.nz/
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

import 'package:contextx/widgets.dart';
import 'package:flutter/widgets.dart';

class Responsive extends StatelessWidget {
  static const int _breakpointForLargeDisplay = 840;
  static const int _breakpointForMediumDisplay = 600;

  static const int _breakpointForGutterSize = 720;
  static const double _smallGutter = 12;
  static const double _largeGutter = 24;

  static double getGutterSize(BuildContext context) =>
      context.mediaQuery().size.width >= _breakpointForGutterSize
          ? _largeGutter
          : _smallGutter;

  Responsive(
    this.small, {
    this.medium,
    this.large,
    this.mediumBreakpoint = _breakpointForMediumDisplay,
    this.largeBreakpoint = _breakpointForLargeDisplay,
  });

  final WidgetBuilder small;
  final WidgetBuilder medium;
  final WidgetBuilder large;

  final int mediumBreakpoint;
  final int largeBreakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        if (large != null && availableWidth >= _breakpointForLargeDisplay) {
          return large(context);
        } else if (medium != null && availableWidth >= _breakpointForMediumDisplay) {
          return medium(context);
        } else {
          return small(context);
        }
      },
    );
  }
}
