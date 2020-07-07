// Copyright (c) 2020, Tonic Artos
//
// Tonic Artos: http://www.tonicartos.nz/
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

part of material_mdflow;

class _DetailView extends StatelessWidget {
  _DetailView({
    Key key,
    @required DetailPageBuilder builder,
    Object arguments,
  })  : assert(builder != null),
        _builder = builder,
        _arguments = arguments,
        super(key: key);

  final DetailPageBuilder _builder;
  final Object _arguments;

  @override
  Widget build(BuildContext context) {
    if (_arguments == null) return Container();
    final screenHeight = context.mediaQuery().size.height;
    final minHeight = (screenHeight - kToolbarHeight) / screenHeight;

    return DraggableScrollableSheet(
      initialChildSize: minHeight,
      minChildSize: minHeight,
      maxChildSize: 1,
      expand: false,
      builder: (context, controller) {
        // Using MouseRegion is a workaround for [59741](https://github.com/flutter/flutter/issues/59741). Pointer events not intercepted by visible regions.
        return MouseRegion(
          child: Card(
            color: context.theme().cardColor,
            elevation: _kCardElevation,
            clipBehavior: Clip.antiAlias,
            margin: EdgeInsets.fromLTRB(_kCardElevation, 0, _kCardElevation, 0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(3), bottom: Radius.zero),
            ),
            child: _builder(context, _arguments, _EmbeddedConfiguration(controller)),
          ),
        );
      },
    );
  }
}
