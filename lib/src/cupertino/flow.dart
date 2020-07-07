// Copyright (c) 2020, Tonic Artos
//
// Tonic Artos: http://www.tonicartos.nz/
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

part of cupertino_mdflow;

/// A Master Detail Flow widget. Depending on screen width it builds either a
/// lateral or nested navigation flow between a master view and a detail page.
///
/// If focus is on detail view, then switching to nested navigation will
/// populate the navigation history with the master page and the detail page on
/// top. Otherwise the focus is on the master view and just the master page is
/// shown.
class CupertinoMasterDetailFlow extends StatefulWidget {
  static const String navMaster = 'master';
  static const String navDetail = 'detail';

  /// Creates a master detail navigation flow which is either nested or lateral
  /// depending on screen width.
  CupertinoMasterDetailFlow({
    Key key,
    @required this.detailPageBuilder,
    @required this.masterPageBuilder,
    this.masterPageWidth,
    LayoutMode displayMode,
  })  : assert(masterPageBuilder != null),
        assert(detailPageBuilder != null),
        this.displayMode = displayMode ?? LayoutMode.auto,
        super(key: key);

  /// Builder for the master page.
  final MasterPageBuilder masterPageBuilder;

  /// Builder for the detail page.
  final DetailPageBuilder detailPageBuilder;

  /// Override the width of the master page in the lateral UI.
  final double masterPageWidth;

  /// Forces display mode and style.
  final LayoutMode displayMode;

  @override
  _MasterDetailFlowState createState() => _MasterDetailFlowState();
}

class _MasterDetailFlowState extends State<CupertinoMasterDetailFlow> {
  /// Tracks whether focus is on the detail or master views. Determines
  /// behaviour when switching from lateral to nested navigation.
  _Focus focus = _Focus.master;
  Object _cachedDetailArguments;

  @override
  Widget build(BuildContext context) {
    switch (widget.displayMode) {
      case LayoutMode.narrow:
        return buildNestedUI(context);
      case LayoutMode.wide:
        return buildLateralUI(context);
      case LayoutMode.auto:
        return Responsive(
          buildNestedUI,
          large: buildLateralUI,
        );
      default:
        throw UnknownLayoutModeException(widget.displayMode);
    }
  }

  Widget buildNestedUI(BuildContext context) {
    return Navigator(
      initialRoute: 'initial',
      onGenerateInitialRoutes: (navigator, initialRoute) {
        switch (focus) {
          case _Focus.master:
            return <Route>[
              CupertinoPageRoute(
                builder: (c) => widget.masterPageBuilder(c, false, (v, {isDefault = false}) {
                  if (!isDefault) {
                    c.navigator().pushNamed(CupertinoMasterDetailFlow.navDetail,
                        arguments: v);
                  }
                }),
              ),
            ];
          default:
            return <Route>[
              CupertinoPageRoute(
                builder: (c) => widget.masterPageBuilder(c, false, (v, {isDefault = false}) {
                  if (!isDefault) {
                    c.navigator().pushNamed(
                        CupertinoMasterDetailFlow.navDetail, arguments: v);
                  }
                }),
              ),
              CupertinoPageRoute(
                builder: (c) => WillPopScope(
                  child: widget.detailPageBuilder(
                    c,
                    _cachedDetailArguments,
                    _NestedConfiguration(
                      onBack: () {
                        focus = _Focus.master;
                        c.navigator().pop();
                      },
                    ),
                  ),
                  onWillPop: () async {
                    // No need for setState() as rebuild happens on navigation pop.
                    focus = _Focus.master;
                    c.navigator().pop();
                    return false;
                  },
                ),
              )
            ];
        }
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case CupertinoMasterDetailFlow.navMaster:
            // Matching state to navigation event.
            focus = _Focus.master;
            return CupertinoPageRoute(
              builder: (c) => widget.masterPageBuilder(c, false, (v, {isDefault = false}) {
                if (!isDefault) {
                  c.navigator().pushNamed(
                      CupertinoMasterDetailFlow.navDetail, arguments: v);
                }
              }),
            );
          case CupertinoMasterDetailFlow.navDetail:
            // Matching state to navigation event.
            focus = _Focus.detail;
            // Cache detail page settings.
            _cachedDetailArguments = settings.arguments;
            return CupertinoPageRoute(
              builder: (c) => WillPopScope(
                child: widget.detailPageBuilder(
                  c,
                  _cachedDetailArguments,
                  _NestedConfiguration(
                    onBack: () {
                      focus = _Focus.master;
                      c.navigator().pop();
                    },
                  ),
                ),
                onWillPop: () async {
                  // No need for setState() as rebuild happens on navigation pop.
                  focus = _Focus.master;
                  c.navigator().pop();
                  return false;
                },
              ),
            );
          default:
            throw Exception('Unknown route ${settings.name}');
        }
      },
    );
  }

  Widget buildLateralUI(BuildContext context) {
    return CupertinoMasterDetailScaffold(
      detailPageBuilder: (context, arguments, config) => widget.detailPageBuilder(
        context,
        arguments != null ? arguments : _cachedDetailArguments,
        config,
      ),
      initialArguments: _cachedDetailArguments,
      masterPageBuilder: (c, isLateral, cb) => widget.masterPageBuilder(
        c,
        isLateral,
        (v, {isDefault = false}) {
          /* Capture focus state and arguments for reuse on reflow to non-large display.*/
          if (!isDefault) {
            focus = _Focus.detail;
            if (_cachedDetailArguments != v) {
              _cachedDetailArguments = v;
              cb(v, isDefault: isDefault);
            }
          } else if (_cachedDetailArguments == null) {
            _cachedDetailArguments = v;
            cb(v, isDefault: isDefault);
          }
        },
      ),
      masterPageWidth: widget.masterPageWidth,
    );
  }
}

enum _Focus { master, detail }
