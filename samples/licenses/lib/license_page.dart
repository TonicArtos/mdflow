// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mdflow/material.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({
    Key key,
    this.packageName,
    this.licenseEntries,
    this.config,
  }) : super(key: key);

  final String packageName;
  final List<LicenseEntry> licenseEntries;
  final DetailViewConfiguration config;

  @override
  State createState() => DetailPageState();
}

class DetailPageState extends State<DetailPage> {
  @override
  void initState() {
    super.initState();
    _initLicenses();
  }

  final List<Widget> _licenses = <Widget>[];
  bool _loaded = false;

  Future<void> _initLicenses() async {
    int debugFlowId = -1;
    assert(() {
      final dev.Flow flow = dev.Flow.begin();
      dev.Timeline.timeSync('_initLicenses()', () {}, flow: flow);
      debugFlowId = flow.id;
      return true;
    }());
    for (final LicenseEntry license in widget.licenseEntries) {
      if (!mounted) {
        return;
      }
      assert(() {
        dev.Timeline.timeSync('_initLicenses()', () {}, flow: dev.Flow.step(debugFlowId));
        return true;
      }());
      final List<LicenseParagraph> paragraphs =
          await SchedulerBinding.instance.scheduleTask<List<LicenseParagraph>>(
        license.paragraphs.toList,
        Priority.animation,
        debugLabel: 'License',
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _licenses.add(const Padding(
          padding: EdgeInsets.symmetric(vertical: 18.0),
          child: Text(
            '🍀‬', // That's U+1F340. Could also use U+2766 (❦) if U+1F340 doesn't work everywhere.
            textAlign: TextAlign.center,
          ),
        ));
//        _licenses.add(Container(
//          decoration: const BoxDecoration(border: Border(bottom: BorderSide(width: 0.0))),
//          child: Text(
//            license.packages.join(', '),
//            style: const TextStyle(fontWeight: FontWeight.bold),
//            textAlign: TextAlign.center,
//          ),
//        ));
        for (final LicenseParagraph paragraph in paragraphs) {
          if (paragraph.indent == LicenseParagraph.centeredIndent) {
            _licenses.add(Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                paragraph.text,
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ));
          } else {
            assert(paragraph.indent >= 0);
            _licenses.add(Padding(
              padding: EdgeInsetsDirectional.only(top: 8.0, start: 16.0 * paragraph.indent),
              child: Text(paragraph.text),
            ));
          }
        }
      });
    }
    setState(() {
      _loaded = true;
    });
    assert(() {
      dev.Timeline.timeSync('Build scheduled', () {}, flow: dev.Flow.end(debugFlowId));
      return true;
    }());
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    final String package = widget.packageName;
    final localisations = MaterialLocalizations.of(context);
    final gutterSize = Responsive.getGutterSize(context);

    if (widget.config.controller == null) {
      return Scaffold(
        appBar: AppBar(
          title: _buildTitle(package, localisations, context),
        ),
        body: Localizations.override(
          locale: const Locale('en', 'US'),
          context: context,
          child: DefaultTextStyle(
            style: Theme.of(context).textTheme.caption,
            child: Scrollbar(
              child: ListView(
                padding: EdgeInsets.only(
                  left: gutterSize,
                  right: gutterSize,
                  bottom: gutterSize,
                ),
                children: <Widget>[
                  ..._licenses,
                  if (!_loaded)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return Localizations.override(
        context: context,
        locale: const Locale('en', 'US'),
        child: DefaultTextStyle(
          style: Theme.of(context).textTheme.caption,
          child: CustomScrollView(
            controller: widget.config.controller,
            slivers: <Widget>[
              SliverAppBar(
                pinned: true,
                backgroundColor: Theme.of(context).cardColor,
                title: _buildTitle(
                  package,
                  localisations,
                  context,
                  theme: Theme.of(context).textTheme,
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.only(                  left: gutterSize,
                  right: gutterSize,
                  bottom: gutterSize,),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    <Widget>[
                      ..._licenses,
                      if (!_loaded)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.0),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Column _buildTitle(String package, MaterialLocalizations localisations, BuildContext context,
      {TextTheme theme}) {
    theme ??= Theme.of(context).primaryTextTheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(package, style: theme.headline6),
        Text(
          localisations.licensesPageTitle,
          style: theme.subtitle2,
        ),
      ],
    );
  }
}
