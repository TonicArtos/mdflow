// Copyright (c) 2020, Tonic Artos
//
// Tonic Artos: http://www.tonicartos.nz/
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

import 'package:flutter/widgets.dart';

typedef OpenDetailPageCallback = void Function(
  Object arguments, {
  bool isDefault,
});

typedef MasterViewBuilder = Widget Function(
  BuildContext context,
  bool isLateral,
  OpenDetailPageCallback openDetailPage,
);

typedef MasterPageBuilder = Widget Function(
  BuildContext context,
  bool isLateral,
  OpenDetailPageCallback openDetailPage,
);

typedef DetailPageBuilder = Widget Function(
  BuildContext context,
  Object arguments,
  DetailViewConfiguration config,
);

abstract class DetailViewConfiguration {
  ScrollController get controller;

  bool get implyLeading;

  Widget get leading;
}
