// Copyright (c) 2020, Tonic Artos
//
// Tonic Artos: http://www.tonicartos.nz/
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

part of mdflow;

typedef DetailPageBuilder = Widget Function(
  BuildContext context,
  Object arguments, {
  DetailViewConfiguration config,
});

typedef OpenDetailPageCallback = void Function(Object arguments, {bool isDefault});

typedef MasterViewBuilder = Widget Function(
  BuildContext context,
  bool isLateral,
  OpenDetailPageCallback openDetailPage,
);

typedef ActionBuilder = List<Widget> Function(
  BuildContext context,
  MdFlowActionLevel actionLevel,
);

abstract class DetailViewConfiguration {
  ScrollController get controller;

  bool get implyLeading;

  Widget get leading;
}

class MdFlowConfiguration {
  const MdFlowConfiguration({
    this.mode = MdFlowLayoutMode.auto,
    this.style = MdFlowLayoutStyle.materialPreferred,
  });

  final MdFlowLayoutMode mode;
  final MdFlowLayoutStyle style;

  MdFlowConfiguration copyWith({
    MdFlowLayoutMode mode,
    MdFlowLayoutStyle style,
  }) =>
      MdFlowConfiguration(
        mode: mode ?? this.mode,
        style: style ?? this.style,
      );
}

enum MdFlowLayoutMode { auto, narrow, wide }
enum MdFlowLayoutStyle { materialPreferred, material, cupertino, cupertinoPreferred }
enum MdFlowActionLevel { top, view, composite }

extension MdFlowLayoutStyleStringer on MdFlowLayoutStyle {
  String get buttonText {
    switch (this) {
      case MdFlowLayoutStyle.materialPreferred:
        return 'Material Preferred';
      case MdFlowLayoutStyle.material:
        return 'Material';
      case MdFlowLayoutStyle.cupertino:
        return 'Cupertino';
      case MdFlowLayoutStyle.cupertinoPreferred:
        return 'Cupertino Preferred';
      default:
        throw UnknownLayoutStyleException(this);
    }
  }
}

extension MdFlowLayoutModeStringer on MdFlowLayoutMode {
  String get buttonText {
    switch (this) {
      case MdFlowLayoutMode.auto:
        return 'Auto';
      case MdFlowLayoutMode.narrow:
        return 'Narrow';
      case MdFlowLayoutMode.wide:
        return 'Wide';
      default:
        throw UnknownLayoutModeException(this);
    }
  }
}

/// A Master Detail Flow widget. Depending on screen width it builds either a lateral or nested
/// navigation flow between a master view and a detail page.
///
/// If focus is on detail view, then switching to nested
/// navigation will populate the navigation history with the master page and the detail page on
/// top. Otherwise the focus is on the master view and just the master page is shown.
///
/// When swapping to lateral navigation, the detail page will always be added. The route settings
/// can be used to reconstruct the detail page, or some other method can be used, such as the
/// bloc pattern.
class MasterDetailFlow extends StatefulWidget {
  static const String navMaster = 'master';
  static const String navDetail = 'detail';

  /// Creates a master detail navigation flow which is either nested or lateral depending on
  /// screen width.
  MasterDetailFlow({
    Key key,
    @required this.detailPageBuilder,
    @required this.masterViewBuilder,
    this.actionBuilder,
    this.autoImplyLeading = true,
    this.centerTitle,
    this.floatingActionButton,
    this.floatingActionButtonGutterWidth,
    this.floatingActionButtonLocation,
    this.floatingActionButtonMasterPageLocation,
    this.leading,
    this.masterPageBuilder,
    this.masterViewWidth,
    this.title,
    MdFlowConfiguration displayConfiguration,
  })  : assert(masterViewBuilder != null),
        assert(detailPageBuilder != null),
        this.displayConfiguration = displayConfiguration ?? const MdFlowConfiguration(),
        super(key: key);

  /// Builder for the master view for lateral navigation.
  ///
  /// If [masterPageBuilder] is not supplied the master page required for nested navigation, also
  /// builds the master view inside a [Scaffold] with an [AppBar].
  final MasterViewBuilder masterViewBuilder;

  /// Builder for the master page for nested navigation.
  ///
  /// This builder is usually a wrapper around the [masterViewBuilder] builder to provide the
  /// extra UI required to make a page. However, this builder is optional, and the master page
  /// can be built using the master view builder and the configuration for the lateral UI's app bar.
  final MasterViewBuilder masterPageBuilder;

  /// Builder for the detail page.
  ///
  /// [DetailViewConfiguration] is used to determine whether the detail page is in lateral or
  /// nested navigation, and the UI built can change as needed. The lateral detail page is inside
  /// a [DraggableScrollableSheet] and should have a scrollable element that uses the
  /// [ScrollController] provided in the configuration argument. In fact, it is strongly
  /// recommended the entire lateral page is scrollable.
  final DetailPageBuilder detailPageBuilder;

  /// Override the width of the master view in the lateral UI.
  final double masterViewWidth;

  /// Override the width of the floating action button gutter in the lateral UI.
  final double floatingActionButtonGutterWidth;

  /// Add a floating action button to the lateral UI. If no [masterPageBuilder] is supplied, this
  /// floating action button is also used on the nested master page.
  ///
  /// See [Scaffold.floatingActionButton].
  final FloatingActionButton floatingActionButton;

  /// The title for the lateral UI [AppBar].
  ///
  /// See [AppBar.title].
  final Widget title;

  /// A widget to display before the title for the lateral UI [AppBar].
  ///
  /// See [AppBar.leading].
  final Widget leading;

  /// Override the framework from determining whether to show a leading widget or not.
  ///
  /// See [AppBar.autoImplyLeading].
  final bool autoImplyLeading;

  /// Override the framework from determining whether to display the title in the centre of the
  /// app bar or not.
  ///
  /// See [AppBar.centerTitle].
  final bool centerTitle;

  /// Build actions for the lateral UI, and potentially the master page in the nested UI.
  ///
  /// If level is [MdFlowActionLevel.top] then the actions are for
  /// the entire lateral UI page. If level is [MdFlowActionLevel.view] the actions are for the master
  /// view toolbar. Finally, if the [AppBar] for the master page for the nested UI is being built
  /// by [MasterDetailFlow], then [MdFlowActionLevel.composite] indicates the actions are for the
  /// nested master page.
  final ActionBuilder actionBuilder;

  /// Determine where the floating action button will go.
  ///
  /// If null, [FloatingActionButtonLocation.endTop] is used.
  ///
  /// Also see [Scaffold.floatingActionButtonLocation].
  final FloatingActionButtonLocation floatingActionButtonLocation;

  /// Determine where the floating action button will go on the master page.
  ///
  /// See [Scaffold.floatingActionButtonLocation].
  final FloatingActionButtonLocation floatingActionButtonMasterPageLocation;

  /// Forces display mode and style.
  final MdFlowConfiguration displayConfiguration;

  @override
  _MasterDetailFlowState createState() => _MasterDetailFlowState();
}

class _MasterDetailFlowState extends State<MasterDetailFlow> {
  /// Tracks whether focus is on the detail or master views. Determines behaviour when switching
  /// from lateral to nested navigation.
  _Focus focus = _Focus.master;
  Object _cachedDetailArguments;

  @override
  Widget build(BuildContext context) {
    switch (widget.displayConfiguration.mode) {
      case MdFlowLayoutMode.narrow:
        return buildSmall(context);
      case MdFlowLayoutMode.wide:
        return buildLarge(context);
      case MdFlowLayoutMode.auto:
        return Responsive(
          buildSmall,
          large: buildLarge,
        );
      default:
        throw UnknownLayoutModeException(widget.displayConfiguration.mode);
    }
  }

  Widget buildSmall(BuildContext context) {
    return Navigator(
      initialRoute: 'initial',
      onGenerateInitialRoutes: (navigator, initialRoute) {
        switch (focus) {
          case _Focus.master:
            return <Route>[
              _choosePageRoute(
                Theme.of(context).platform,
                widget.displayConfiguration,
                widget.masterPageBuilder != null ? widget.masterPageBuilder : _buildMasterPage,
              ),
            ];
          default:
            return <Route>[
              _choosePageRoute(
                Theme.of(context).platform,
                widget.displayConfiguration,
                widget.masterPageBuilder != null ? widget.masterPageBuilder : _buildMasterPage,
              ),
              _choosePageRoute(
                Theme.of(context).platform,
                widget.displayConfiguration,
                (c) => WillPopScope(
                  child: widget.detailPageBuilder(c, _cachedDetailArguments,
                      config: _NestedConfiguration(
                        icon: _getBackArrowIcon(c),
                        onBack: () {
                          focus = _Focus.master;
                          c.navigation.pop();
                        },
                      )),
                  onWillPop: () async {
                    // No need for setState() as rebuild happens on navigation pop.
                    focus = _Focus.master;
                    c.navigation.pop();
                    return false;
                  },
                ),
              )
            ];
        }
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case MasterDetailFlow.navMaster:
            // Matching state to navigation event.
            focus = _Focus.master;
            return _choosePageRoute(
              Theme.of(context).platform,
              widget.displayConfiguration,
              widget.masterPageBuilder != null ? widget.masterPageBuilder : _buildMasterPage,
            );
          case MasterDetailFlow.navDetail:
            // Matching state to navigation event.
            focus = _Focus.detail;
            // Cache detail page settings.
            _cachedDetailArguments = settings.arguments;
            return _choosePageRoute(
              Theme.of(context).platform,
              widget.displayConfiguration,
              (c) => WillPopScope(
                child: widget.detailPageBuilder(c, _cachedDetailArguments,
                    config: _NestedConfiguration(
                      icon: _getBackArrowIcon(c),
                      onBack: () {
                        focus = _Focus.master;
                        c.navigation.pop();
                      },
                    )),
                onWillPop: () async {
                  // No need for setState() as rebuild happens on navigation pop.
                  focus = _Focus.master;
                  c.navigation.pop();
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

  IconData _getBackArrowIcon(BuildContext c) {
    switch (_styleChoice(Theme.of(c).platform, widget.displayConfiguration)) {
      case _StyleChoice.cupertino:
        return Icons.arrow_back_ios;
      case _StyleChoice.material:
      default:
        return Icons.arrow_back;
    }
  }

  Widget _buildMasterPage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.title,
        leading: widget.leading,
        automaticallyImplyLeading: widget.autoImplyLeading,
        actions: widget.actionBuilder == null
            ? const <Widget>[]
            : widget.actionBuilder(context, MdFlowActionLevel.composite),
        centerTitle: widget.centerTitle,
      ),
      body: widget.masterViewBuilder(
        context,
        false,
        (v, {isDefault = false}) {
          if (!isDefault) Navigator.of(context).pushNamed(MasterDetailFlow.navDetail, arguments: v);
        },
      ),
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation: widget.floatingActionButtonLocation,
    );
  }

  Widget buildLarge(BuildContext context) {
    return MasterDetailScaffold(
      actionBuilder: widget.actionBuilder == null ? const <Widget>[] : widget.actionBuilder,
      autoImplyLeading: widget.autoImplyLeading,
      centerTitle: widget.centerTitle,
      configuration: widget.displayConfiguration,
      detailPageBuilder: (context, arguments, {config}) => widget.detailPageBuilder(
        context,
        arguments != null ? arguments : _cachedDetailArguments,
        config: config,
      ),
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonGutterWidth: widget.floatingActionButtonGutterWidth,
      floatingActionButtonLocation: widget.floatingActionButtonLocation,
      initialArguments: _cachedDetailArguments,
      leading: widget.leading,
      masterViewBuilder: (c, isLateral, cb) => widget.masterViewBuilder(
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
      masterViewWidth: widget.masterViewWidth,
      title: widget.title,
    );
  }
}

enum _Focus { master, detail }

extension _NavigationContext on BuildContext {
  NavigatorState get navigation => Navigator.of(
        this,
        rootNavigator: false,
        nullOk: false,
      );
}

class _NestedConfiguration extends DetailViewConfiguration {
  _NestedConfiguration({this.icon, this.onBack});

  final void Function() onBack;
  final IconData icon;
  @override
  ScrollController get controller => null;

  @override
  bool get implyLeading => true;

  @override
  Widget get leading => IconButton(
        icon: Icon(icon),
        onPressed: onBack,
      );
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
