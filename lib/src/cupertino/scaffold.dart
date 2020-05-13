// Copyright (c) 2020, Tonic Artos
//
// Tonic Artos: http://www.tonicartos.nz/
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

part of cupertino_mdflow;

class CupertinoMasterDetailScaffold extends StatelessWidget {
  CupertinoMasterDetailScaffold({
    Key key,
    @required DetailPageBuilder detailPageBuilder,
    Object initialArguments,
    @required MasterPageBuilder masterPageBuilder,
    double masterPageWidth,
  })  : assert(detailPageBuilder != null),
        assert(MasterPageBuilder != null),
        _detailPageBuilder = detailPageBuilder,
        _initialArguments = initialArguments,
        _masterPageBuilder = masterPageBuilder,
        _masterViewWidth = masterPageWidth ?? _kMasterPageWidth,
        super(key: key);

  final DetailPageBuilder _detailPageBuilder;
  final MasterPageBuilder _masterPageBuilder;
  final Object _initialArguments;
  final double _masterViewWidth;
  final ValueNotifier<Object> _defaultRequest = ValueNotifier(null);
  final ValueNotifier<Object> _detailArgument = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _buildMasterView(context),
        _buildDetailView(context),
      ],
    );
  }

  Widget _buildDetailView(BuildContext context) {
    return Expanded(
      child: ValueListenableBuilder(
        valueListenable: _detailArgument,
        builder: (context, value, child) => AnimatedSwitcher(
          transitionBuilder: (child, animation) =>
              _CupertinoPageTransition(child: child, animation: animation),
          duration: Duration(milliseconds: 500),
          child: Container(
            key: ValueKey(value ?? _initialArguments ?? _defaultRequest.value),
            constraints: BoxConstraints.expand(),
            child: _detailPageBuilder(
              context,
              value ?? _initialArguments ?? _defaultRequest.value,
              _EmbeddedConfiguration(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMasterView(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: _masterViewWidth),
      child: _masterPageBuilder(
        context,
        true,
        (v, {isDefault = false}) {
          (isDefault ? _defaultRequest : _detailArgument).value = v;
        },
      ),
    );
  }
}
