// Copyright (c) 2020, Tonic Artos
//
// Tonic Artos: http://www.tonicartos.nz/
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

part of material_mdflow;

typedef ActionBuilder = List<Widget> Function(
  BuildContext context,
  ActionLevel actionLevel,
);

enum ActionLevel { top, view, composite }

class _NestedConfiguration extends DetailViewConfiguration {
  _NestedConfiguration({this.icon, this.onBack});

  final void Function() onBack;
  final IconData icon;
  @override
  ScrollController get controller => null;

  @override
  bool get implyLeading => true;

  @override
  Widget get leading => IconButton(icon: Icon(icon), onPressed: onBack);
}

class _EmbeddedConfiguration extends DetailViewConfiguration {
  _EmbeddedConfiguration(this.controller);

  @override
  final ScrollController controller;

  @override
  bool get implyLeading => false;

  @override
  Widget get leading => null;
}
