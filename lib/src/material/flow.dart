// Copyright (c) 2020, Tonic Artos
//
// Tonic Artos: http://www.tonicartos.nz/
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.

part of material_mdflow;

class MdFlowConfiguration {
  const MdFlowConfiguration({
    this.mode = LayoutMode.auto,
    this.style = LayoutStylePreference.materialPreferred,
  });

  final LayoutMode mode;
  final LayoutStylePreference style;

  MdFlowConfiguration copyWith({
    LayoutMode mode,
    LayoutStylePreference style,
  }) =>
      MdFlowConfiguration(
        mode: mode ?? this.mode,
        style: style ?? this.style,
      );
}

/// A Master Detail Flow widget. Depending on screen width it builds either a lateral or nested
/// navigation flow between a master view and a detail page.
/// bloc pattern.
///
/// If focus is on detail view, then switching to nested
/// navigation will populate the navigation history with the master page and the detail page on
/// top. Otherwise the focus is on the master view and just the master page is shown.
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
    this.detailPageFABGutterWidth,
    this.detailPageFABlessGutterWidth,
    this.floatingActionButtonLocation,
    this.floatingActionButtonMasterPageLocation,
    this.leading,
    this.masterPageBuilder,
    this.masterViewWidth,
    this.title,
    LayoutMode displayMode,
  })  : assert(masterViewBuilder != null),
        assert(detailPageBuilder != null),
        this.displayMode = displayMode ?? LayoutMode.auto,
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
  final double detailPageFABGutterWidth;

  /// Override the width of the gutter when there is no floating action button.
  final double detailPageFABlessGutterWidth;

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
  /// If level is [ActionLevel.top] then the actions are for
  /// the entire lateral UI page. If level is [ActionLevel.view] the actions are for the master
  /// view toolbar. Finally, if the [AppBar] for the master page for the nested UI is being built
  /// by [MasterDetailFlow], then [ActionLevel.composite] indicates the actions are for the
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
  final LayoutMode displayMode;

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
              MaterialPageRoute(
                builder:
                    widget.masterPageBuilder != null ? widget.masterPageBuilder : _buildMasterPage,
              ),
            ];
          default:
            return <Route>[
              MaterialPageRoute(
                builder:
                    widget.masterPageBuilder != null ? widget.masterPageBuilder : _buildMasterPage,
              ),
              MaterialPageRoute(
                builder: (c) => WillPopScope(
                  child: widget.detailPageBuilder(
                      c,
                      _cachedDetailArguments,
                      _NestedConfiguration(
                        icon: Icons.arrow_back,
                        onBack: () {
                          focus = _Focus.master;
                          Navigator.of(c).pop();
                        },
                      )),
                  onWillPop: () async {
                    // No need for setState() as rebuild happens on navigation pop.
                    focus = _Focus.master;
                    Navigator.of(c).pop();
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
            return MaterialPageRoute(
              builder:
                  widget.masterPageBuilder != null ? widget.masterPageBuilder : _buildMasterPage,
            );
          case MasterDetailFlow.navDetail:
            // Matching state to navigation event.
            focus = _Focus.detail;
            // Cache detail page settings.
            _cachedDetailArguments = settings.arguments;
            return MaterialPageRoute(
              builder: (c) => WillPopScope(
                child: widget.detailPageBuilder(
                    c,
                    _cachedDetailArguments,
                    _NestedConfiguration(
                      icon: Icons.arrow_back,
                      onBack: () {
                        focus = _Focus.master;
                        Navigator.of(c).pop();
                      },
                    )),
                onWillPop: () async {
                  // No need for setState() as rebuild happens on navigation pop.
                  focus = _Focus.master;
                  Navigator.of(c).pop();
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

  Widget _buildMasterPage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.title,
        leading: widget.leading,
        automaticallyImplyLeading: widget.autoImplyLeading,
        actions: widget.actionBuilder == null
            ? const <Widget>[]
            : widget.actionBuilder(context, ActionLevel.composite),
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

  Widget buildLateralUI(BuildContext context) {
    return MasterDetailScaffold(
      actionBuilder: widget.actionBuilder == null ? const <Widget>[] : widget.actionBuilder,
      autoImplyLeading: widget.autoImplyLeading,
      centerTitle: widget.centerTitle,
      detailPageBuilder: (context, arguments, config) => widget.detailPageBuilder(
        context,
        arguments != null ? arguments : _cachedDetailArguments,
        config,
      ),
      floatingActionButton: widget.floatingActionButton,
      detailPageFABlessGutterWidth: widget.detailPageFABlessGutterWidth,
      detailPageFABGutterWidth: widget.detailPageFABGutterWidth,
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
