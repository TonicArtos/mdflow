// Copyright (c) 2020, Tonic Artos
//
// Tonic Artos: http://www.tonicartos.nz/
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

part of cupertino_mdflow;

const double _kMasterPageWidth = 320;

class _NestedConfiguration extends DetailViewConfiguration {
  _NestedConfiguration({this.onBack});

  final void Function() onBack;

  @override
  ScrollController get controller => null;

  @override
  bool get implyLeading => true;

  @override
  Widget get leading => CupertinoNavigationBarBackButton(onPressed: onBack);
}

class _EmbeddedConfiguration extends DetailViewConfiguration {
  @override
  ScrollController get controller => null;

  @override
  bool get implyLeading => false;

  @override
  Widget get leading => null;
}
