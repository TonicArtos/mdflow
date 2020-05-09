// Copyright (c) 2020, Tonic Artos
//
// Tonic Artos: http://www.tonicartos.nz/
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

part of mdflow;

class MasterDetailScaffold extends StatelessWidget {
  static const double _defaultMasterViewWidth = 320;
  static const double _cardElevation = 4;
  static const double _defaultDetailPageRightPaddingWithNoFab = 40;
  static const double _defaultFloatingActionButtonGutterWidth = 84;

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
    double detailPageRightPaddingWithNoFab,
    double floatingActionButtonGutterWidth,
    double masterViewWidth,
    MdFlowConfiguration configuration,
  })  : assert(detailPageBuilder != null),
        assert(MasterViewBuilder != null),
        _actionBuilder = actionBuilder,
        _autoImplyLeading = autoImplyLeading,
        _centreTitle = centerTitle,
        _configuration = configuration ?? MdFlowConfiguration(),
        _detailPageBuilder = detailPageBuilder,
        _detailPageRightPaddingWithNoFab =
            detailPageRightPaddingWithNoFab ?? _defaultDetailPageRightPaddingWithNoFab,
        _floatingActionButton = floatingActionButton,
        _floatingActionButtonGutterWidth =
            floatingActionButtonGutterWidth ?? _defaultFloatingActionButtonGutterWidth,
        _floatingActionButtonLocation =
            floatingActionButtonLocation ?? FloatingActionButtonLocation.endTop,
        _initialArguments = initialArguments,
        _leading = leading,
        _masterViewBuilder = masterViewBuilder,
        _masterViewWidth = masterViewWidth ?? _defaultMasterViewWidth,
        _title = title,
        super(key: key);

  final ActionBuilder _actionBuilder;
  final MdFlowConfiguration _configuration;
  final DetailPageBuilder _detailPageBuilder;
  final FloatingActionButton _floatingActionButton;
  final FloatingActionButtonLocation _floatingActionButtonLocation;
  final GlobalKey<NavigatorState> _navKey = GlobalKey();
  final MasterViewBuilder _masterViewBuilder;
  final Object _initialArguments;
  final Widget _leading;
  final Widget _title;
  final bool _autoImplyLeading;
  final bool _centreTitle;
  final double _detailPageRightPaddingWithNoFab;
  final double _floatingActionButtonGutterWidth;
  final double _masterViewWidth;
  final ValueNotifier<Object> _defaultRequest = ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          floatingActionButtonLocation: _floatingActionButtonLocation,
          appBar: AppBar(
              title: _title,
              actions: _actionBuilder(context, MdFlowActionLevel.top),
              leading: _leading,
              automaticallyImplyLeading: _autoImplyLeading,
              centerTitle: _centreTitle,
              bottom: PreferredSize(
                  preferredSize: Size.fromHeight(kToolbarHeight),
                  child: Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
                    Container(
                        constraints: BoxConstraints.tightFor(width: _masterViewWidth),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: _actionBuilder(context, MdFlowActionLevel.view),
                        ))
                  ]))),
          body: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: _masterViewWidth),
            child: _masterViewBuilder(
              context,
              true,
              (v, {isDefault = false}) {
                if (!isDefault) {
                  _navKey.currentState.popAndPushNamed('detail', arguments: v);
                } else {
                  _defaultRequest.value = v;
                }
              },
            ),
          ),
          floatingActionButton: _floatingActionButton,
        ),
        // Detail view stacked above main scaffold and master view.
        SafeArea(
            child: Padding(
                padding: EdgeInsetsDirectional.only(
                  start: _masterViewWidth + _cardElevation,
                  end: _floatingActionButton == null
                      ? _detailPageRightPaddingWithNoFab
                      : _floatingActionButtonGutterWidth,
                ),
                //TODO: replace navigator with own animations because it eats gestures.
                child: Navigator(
                    key: _navKey,
                    onGenerateInitialRoutes: (navigator, initialRoute) => [
                          _choosePageRoute(
                              Theme.of(context).platform,
                              _configuration,
                              (context) => _DetailView(
                                    builder: _detailPageBuilder,
                                    arguments: _initialArguments ?? _defaultRequest.value,
                                  )),
                        ],
                    onGenerateRoute: (settings) => _choosePageRoute(
                        Theme.of(context).platform,
                        _configuration,
                        (context) => _DetailView(
                              builder: _detailPageBuilder,
                              arguments: settings.arguments,
                            ))))),
      ],
    );
  }
}

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
    final screenHeight = MediaQuery.of(context).size.height;
    final minHeight = (screenHeight - kToolbarHeight) / screenHeight;

    return GestureDetector(
      onTap: () {
        print('draggable');
      },
      behavior: HitTestBehavior.deferToChild,
      child: DraggableScrollableSheet(
        initialChildSize: minHeight,
        minChildSize: minHeight,
        maxChildSize: 1,
        expand: false,
        builder: (context, controller) {
          return Card(
            elevation: MasterDetailScaffold._cardElevation,
            clipBehavior: Clip.antiAlias,
            margin: EdgeInsets.fromLTRB(
              MasterDetailScaffold._cardElevation,
              0,
              MasterDetailScaffold._cardElevation,
              0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(3), bottom: Radius.zero),
            ),
            child: _builder(context, _arguments, config: _EmbeddedConfiguration(controller)),
          );
        },
      ),
    );
  }
}
