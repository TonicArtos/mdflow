// Copyright (c) 2020, Tonic Artos
//
// Tonic Artos: http://www.tonicartos.nz/
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

part of material_mdflow;

const double _kCardElevation = 4;
const double _kMasterViewWidth = 320;
const double _kDetailPageFABlessGutterWidth = 40;
const double _kDetailPageFABGutterWidth = 84;

class MasterDetailScaffold extends StatelessWidget {
  MasterDetailScaffold({
    Key key,
    @required DetailPageBuilder detailPageBuilder,
    @required MasterViewBuilder masterViewBuilder,
    ActionBuilder actionBuilder,
    FloatingActionButton floatingActionButton,
    FloatingActionButtonLocation floatingActionButtonLocation,
    Object initialArguments,
    Widget leading,
    Widget title,
    bool autoImplyLeading,
    bool centerTitle,
    double detailPageFABlessGutterWidth,
    double detailPageFABGutterWidth,
    double masterViewWidth,
  })  : assert(detailPageBuilder != null),
        assert(MasterViewBuilder != null),
        _actionBuilder = actionBuilder,
        _autoImplyLeading = autoImplyLeading,
        _centreTitle = centerTitle,
        _detailPageBuilder = detailPageBuilder,
        _detailPageFABlessGutterWidth =
            detailPageFABlessGutterWidth ?? _kDetailPageFABlessGutterWidth,
        _floatingActionButton = floatingActionButton,
        _detailPageFABGutterWidth = detailPageFABGutterWidth ?? _kDetailPageFABGutterWidth,
        _floatingActionButtonLocation =
            floatingActionButtonLocation ?? FloatingActionButtonLocation.endTop,
        _initialArguments = initialArguments,
        _leading = leading,
        _masterViewBuilder = masterViewBuilder,
        _masterViewWidth = masterViewWidth ?? _kMasterViewWidth,
        _title = title,
        super(key: key);

  final ActionBuilder _actionBuilder;
  final DetailPageBuilder _detailPageBuilder;
  final FloatingActionButton _floatingActionButton;
  final FloatingActionButtonLocation _floatingActionButtonLocation;
  final MasterViewBuilder _masterViewBuilder;
  final Object _initialArguments;
  final Widget _leading;
  final Widget _title;
  final bool _autoImplyLeading;
  final bool _centreTitle;
  final double _detailPageFABlessGutterWidth;
  final double _detailPageFABGutterWidth;
  final double _masterViewWidth;
  final ValueNotifier<Object> _defaultRequest = ValueNotifier(null);
  final ValueNotifier<Object> _detailArgument = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          floatingActionButtonLocation: _floatingActionButtonLocation,
          appBar: AppBar(
            title: _title,
            actions: _actionBuilder(context, ActionLevel.top),
            leading: _leading,
            automaticallyImplyLeading: _autoImplyLeading,
            centerTitle: _centreTitle,
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(kToolbarHeight),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  ConstrainedBox(
                    constraints: BoxConstraints.tightFor(width: _masterViewWidth),
                    child: ButtonBar(
                      children: _actionBuilder(context, ActionLevel.view),
                    ),
                  )
                ],
              ),
            ),
          ),
          body: _buildMasterPanel(context),
          floatingActionButton: _floatingActionButton,
        ),
        // Detail view stacked above main scaffold and master view.
        SafeArea(
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              start: _masterViewWidth + _kCardElevation,
              end: _floatingActionButton == null
                  ? _detailPageFABlessGutterWidth
                  : _detailPageFABGutterWidth,
            ),
            child: ValueListenableBuilder(
              valueListenable: _detailArgument,
              builder: (context, value, child) {
                return AnimatedSwitcher(
                  transitionBuilder: (child, animation) =>
                      _FadeUpwardsPageTransition(child: child, animation: animation),
                  duration: Duration(milliseconds: 500),
                  child: Container(
                    key: ValueKey(value ?? _initialArguments ?? _defaultRequest.value),
                    constraints: BoxConstraints.expand(),
                    child: _DetailView(
                      builder: _detailPageBuilder,
                      arguments: value ?? _initialArguments ?? _defaultRequest.value,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  ConstrainedBox _buildMasterPanel(
    BuildContext context, {
    needsScaffold = false,
  }) {
    final masterView = _masterViewBuilder(
      context,
      true,
      (v, {isDefault = false}) {
        (isDefault ? _defaultRequest : _detailArgument).value = v;
      },
    );
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: _masterViewWidth),
      child: needsScaffold
          ? Scaffold(
              appBar: AppBar(
                title: _title,
                actions: _actionBuilder(context, ActionLevel.top),
                leading: _leading,
                automaticallyImplyLeading: _autoImplyLeading,
                centerTitle: _centreTitle,
              ),
              body: masterView)
          : masterView,
    );
  }
}
