// Copyright (c) 2020, Tonic Artos
//
// Tonic Artos: http://www.tonicartos.nz/
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mdflow/cupertino.dart';
import 'package:mdflow/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Master Detail Flow Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final ValueNotifier<int> selectedId = ValueNotifier(null);
  final ValueNotifier<MdFlowConfiguration> configuration = ValueNotifier(MdFlowConfiguration());

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MdFlowConfiguration>(
      valueListenable: configuration,
      builder: (context, configuration, child) {
        switch (styleChoice(
          Theme.of(context).platform,
          configuration.style,
          kIsWeb,
        )) {
          case LayoutStyle.cupertino:
            return CupertinoMasterDetailFlow(
              displayMode: configuration.mode,
              masterPageBuilder: _buildCupertinoMasterPage,
              detailPageBuilder: _buildCupertinoDetailPage,
            );
          case LayoutStyle.material:
          default:
            return MasterDetailFlow(
              title: Text('Master Detail Flow Demo'),
              displayMode: configuration.mode,
              actionBuilder: _actionBuilder,
              masterViewBuilder: _buildMasterPage,
              detailPageBuilder: _buildDetailPage,
            );
        }
      },
    );
  }

  List<Widget> _actionBuilder(context, mode) {
    switch (mode) {
      case ActionLevel.top:
        return <Widget>[
          IconButton(
            icon: Icon(Icons.view_compact),
            tooltip: 'Configure display',
            onPressed: () => onConfigureDisplay(context),
          ),
          PopupMenuButton<PopupAction>(
            onSelected: (v) => onPopupAction(context, v),
            itemBuilder: (c) => [
              PopupMenuItem(
                value: PopupAction.about,
                child: Text('About'),
              ),
            ],
          )
        ];
      case ActionLevel.view:
        return <Widget>[
          IconButton(
            icon: Icon(Icons.view_compact),
            tooltip: 'Configure display',
            onPressed: () => onConfigureDisplay(context),
          ),
          IconButton(
            icon: Icon(Icons.view_compact),
            tooltip: 'Configure display',
            onPressed: () => onConfigureDisplay(context),
          ),
        ];
      case ActionLevel.composite:
        return <Widget>[
          IconButton(
            icon: Icon(Icons.view_compact),
            tooltip: 'Configure display',
            onPressed: () => onConfigureDisplay(context),
          ),
          PopupMenuButton<PopupAction>(
            onSelected: (v) => onPopupAction(context, v),
            itemBuilder: (c) => [
              PopupMenuItem(
                value: PopupAction.about,
                child: Text('About'),
              ),
            ],
          )
        ];
    }
    return <Widget>[];
  }

  Widget _buildCupertinoMasterPage(
    BuildContext context,
    bool isLateral,
    OpenDetailPageCallback openDetailPage,
  ) {
    selectedId.value ??= 0;
    openDetailPage(DetailPageArguments(0), isDefault: true);
    return ValueListenableBuilder<int>(
      valueListenable: selectedId,
      builder: (context, value, _) => CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('Master Detail Flow Demo'),
          trailing: CupertinoButton(
            child: Icon(CupertinoIcons.ellipsis),
            onPressed: () {
              showCupertinoModalPopup(
                  context: context,
                  builder: (context) {
                    return CupertinoActionSheet(
                      title: Text('Options'),
                      cancelButton: CupertinoButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      actions: <Widget>[
                        CupertinoButton(
                          child: Text('Configure'),
                          onPressed: () {},
                        ),
                        CupertinoButton(
                          child: Text('About'),
                          onPressed: () {},
                        ),
                      ],
                    );
                  });
            },
          ),
        ),
        child: Material(
          child: Responsive(
            (context) => _buildListView(openDetailPage, isLateral, value),
            medium: (context) => _buildGridView(openDetailPage, isLateral, value),
          ),
        ),
      ),
    );
  }

  Widget _buildCupertinoDetailPage(
    final BuildContext context,
    final Object arguments,
    final DetailViewConfiguration config,
  ) {
    if (arguments is DetailPageArguments) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('Item ${arguments.id}'),
          leading: config.leading,
          automaticallyImplyLeading: config.implyLeading,
        ),
        child: Center(
          child: Text('Item ${arguments.id}'),
        ),
      );
    } else {
      throw Exception('Arguments not given. '
          'argType = ${arguments.runtimeType}. '
          'arguments = $arguments');
    }
  }

  Widget _buildMasterPage(
    BuildContext context,
    bool isLateral,
    OpenDetailPageCallback openDetailPage,
  ) {
    selectedId.value ??= 0;
    openDetailPage(DetailPageArguments(0), isDefault: true);
    return ValueListenableBuilder<int>(
      valueListenable: selectedId,
      builder: (context, value, _) => Responsive(
        (context) => _buildListView(openDetailPage, isLateral, value),
        medium: (context) => _buildGridView(openDetailPage, isLateral, value),
      ),
    );
  }

  GridView _buildGridView(OpenDetailPageCallback openDetailPage, bool isLateral, int value) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
      ),
      itemBuilder: (context, i) => Card(
        clipBehavior: Clip.antiAlias,
        child: _buildTile(i, openDetailPage, isLateral && value == i),
      ),
      itemCount: 100,
    );
  }

  ListView _buildListView(OpenDetailPageCallback openDetailPage, bool isLateral, int value) {
    return ListView.builder(
      itemBuilder: (context, i) => _buildTile(i, openDetailPage, isLateral && value == i),
      itemCount: 100,
    );
  }

  ListTile _buildTile(int i, OpenDetailPageCallback openDetailPage, bool isSelected) {
    return ListTile(
      title: Text('Item $i'),
      onTap: () {
        this.selectedId.value = i;
        openDetailPage(DetailPageArguments(i));
      },
      selected: isSelected,
    );
  }

  Widget _buildDetailPage(
    BuildContext context,
    final Object arguments,
    DetailViewConfiguration config,
  ) {
    if (arguments is DetailPageArguments) {
      if (config.controller == null) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Item ${arguments.id}'),
            leading: config.leading,
            automaticallyImplyLeading: config.implyLeading,
          ),
          body: SingleChildScrollView(
            child: Responsive((c) => Container()),
          ),
        );
      } else {
        return Scaffold(
          body: CustomScrollView(
            controller: config.controller,
            primary: config.controller == null,
            slivers: <Widget>[
              SliverAppBar(
                title: Text('Item ${arguments.id}'),
                leading: config.leading,
                automaticallyImplyLeading: config.implyLeading,
              ),
              SliverToBoxAdapter(
                child: Responsive((c) => Container()),
              ),
            ],
          ),
        );
      }
    } else {
      throw Exception('Arguments not given. '
          'argType = ${arguments.runtimeType}. '
          'arguments = $arguments');
    }
  }

  void onConfigureDisplay(BuildContext context) {
    final cachedConfig = configuration.value;
    final theme = Theme.of(context);
    final dialog = ValueListenableBuilder(
      valueListenable: configuration,
      builder: (context, config, child) {
        return AlertDialog(
          title: Text('Settings'),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                configuration.value = cachedConfig;
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
                child: Text('Okay'),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
          ],
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                formattedText(
                  _configText.withStyle(theme.textTheme.bodyText2),
                  8.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Divider(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Force layout style', style: theme.textTheme.bodyText1),
                ),
                formattedText(
                  configuration.value.style.explain.withStyle(theme.textTheme.bodyText2),
                  8.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ToggleButtons(
                      borderRadius: BorderRadius.circular(16.0),
                      children: LayoutStylePreference.values
                          .map((i) => Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(i.text),
                              ))
                          .toList(growable: false),
                      isSelected: LayoutStylePreference.values
                          .map((i) => i.index == configuration.value.style.index)
                          .toList(growable: false),
                      onPressed: (i) {
                        configuration.value =
                            configuration.value.copyWith(style: LayoutStylePreference.values[i]);
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Force layout mode', style: theme.textTheme.bodyText1),
                ),
                formattedText(
                  configuration.value.mode.explain.withStyle(theme.textTheme.bodyText2),
                  8.0,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ToggleButtons(
                    borderRadius: BorderRadius.circular(16.0),
                    children: LayoutMode.values
                        .map((i) => Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(i.text),
                            ))
                        .toList(growable: false),
                    isSelected: LayoutMode.values
                        .map((i) => i.index == configuration.value.mode.index)
                        .toList(growable: false),
                    onPressed: (i) {
                      configuration.value =
                          configuration.value.copyWith(mode: LayoutMode.values[i]);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    showDialog(
      context: context,
      builder: (context) => dialog,
    );
  }

  void onPopupAction(BuildContext context, PopupAction v) {
    var flutterLogo = FlutterLogo();
    switch (v) {
      case PopupAction.about:
        showAboutDialog(
          context: context,
          applicationName: 'Master Detail Flow Example',
          applicationVersion: 'May 2020',
          applicationIcon: flutterLogo,
          applicationLegalese: 'Copyright © 2020 Tonic Artos.',
          useRootNavigator: true,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 400.0),
              child:
                  formattedText(_aboutText.withStyle(Theme.of(context).textTheme.bodyText2), 24.0),
            ),
          ],
        );
        break;
    }
  }

  Widget formattedText(TextSpan text, double padding) {
    return ConstrainedBox(
      constraints: BoxConstraints.loose(Size.fromWidth(480.0)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: padding),
        child: RichText(
          text: text,
          textAlign: TextAlign.justify,
        ),
      ),
    );
  }
}

enum PopupAction { about }

class DetailPageArguments {
  DetailPageArguments(this.id);

  final int id;

  @override
  bool operator ==(final dynamic other) {
    if (other is DetailPageArguments) {
      return other.id == id;
    } else if (other is num) {
      return other == id;
    }
    return other == this;
  }

  @override
  int get hashCode => id.hashCode;
}

TextSpan get _aboutText => TextSpan(
      children: [
        'Master Detail Flow Demo '.bold,
        'is an example of how to use the '.span,
        'MdFlow '.bold,
        'package to create a reponsive interface for the master detail flow user interface pattern.'
            .span,
      ],
    );

TextSpan get _configText => TextSpan(
      children: [
        'The default configuration for the '.span,
        'MdFlow '.bold,
        'package conforms to the material design specification with exceptions for cupertino '
                'platforms. Of course, this behaviour can be changed, as shown by this dialogue.'
            .span,
      ],
    );

extension ExplainMdFlowLayoutStyle on LayoutStylePreference {
  TextSpan get explain {
    switch (this) {
      case LayoutStylePreference.materialPreferred:
        return TextSpan(
          children: [
            'LayoutStylePreference.materialPreferred '.bold,
            'is the default configuration. This behaviour implements the '.span,
            'Material '.em,
            'visual style on all platforms except '.span,
            'iOS '.em,
            'and '.span,
            'macOS'.em,
            '.'.span,
          ],
        );
      case LayoutStylePreference.material:
        return TextSpan(
          children: [
            'LayoutStylePreference.material '.bold,
            'forces the package to use the '.span,
            'Material '.em,
            'visual elements and layout configuration on all platforms.'.span,
          ],
        );
      case LayoutStylePreference.cupertino:
        return TextSpan(
          children: [
            'LayoutStylePreference.cupertino '.bold,
            'forces the package to use the '.span,
            'Cupertino '.em,
            'visual elements and layout configuration on all platforms.'.span,
          ],
        );
      case LayoutStylePreference.cupertinoPreferred:
        return TextSpan(
          children: [
            'LayoutStylePreference.cupertinoPreferred '.bold,
            'sets all plaforms to use the '.span,
            'Cupertino '.em,
            'visual style, except the '.span,
            'Android '.em,
            'and '.span,
            'Fuchsia '.em,
            'platforms.'.span,
          ],
        );
      default:
        throw Exception(); // yeah.
    }
  }
}

extension ExplainMdFlowLayoutMode on LayoutMode {
  TextSpan get explain {
    switch (this) {
      case LayoutMode.auto:
        return TextSpan(
          children: [
            'LayoutMode.auto '.bold,
            'is the default configuration. In this mode the package will choose whether to use a '
                    'single panel UI with nested navigation, or a two panel UI with lateral '
                    'navigation.'
                .span,
          ],
        );
      case LayoutMode.narrow:
        return TextSpan(
          children: [
            'LayoutMode.narrow '.bold,
            'forces the package to use a single panel UI with nested navigation.'.span,
          ],
        );
      case LayoutMode.wide:
        return TextSpan(
          children: [
            'LayoutMode.wide '.bold,
            'forces the package to use a two panel UI with lateral navigation.'.span,
          ],
        );
      default:
        throw Exception(); // yeah.
    }
  }
}

extension StringToTextSpan on String {
  TextSpan get span => TextSpan(text: this);
  TextSpan get bold => TextSpan(text: this, style: TextStyle(fontWeight: FontWeight.bold));
  TextSpan get em => TextSpan(text: this, style: TextStyle(fontStyle: FontStyle.italic));
  TextSpan get boldEm => TextSpan(
        text: this,
        style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
      );
}

extension TextSpanStyle on TextSpan {
  TextSpan withStyle(TextStyle style) => TextSpan(children: [this], style: style);
}
