import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:licenses/license_page.dart';
import 'package:mdflow/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Licenses Sample',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LicensesPage(
        applicationName: 'MDFlow Licenses Sample',
        applicationVersion: 'May 2020',
        applicationIcon: FlutterLogo(),
        applicationLegalese: 'Copyright © 2020 Tonic Artos',
      ),
    );
  }
}

class LicensesPage extends StatefulWidget {
  LicensesPage(
      {Key key,
      this.applicationName,
      this.applicationVersion,
      this.applicationIcon,
      this.applicationLegalese})
      : super(key: key);

  @override
  _LicensesPageState createState() => _LicensesPageState();

  final String applicationName;
  final String applicationVersion;
  final Widget applicationIcon;
  final String applicationLegalese;
}

class LicenseData {
  final licenses = List<LicenseEntry>();
  final packageLicenseBindings = Map<String, List<int>>();
  final packages = List<String>();

  void addLicense(LicenseEntry entry) {
    entry.packages.forEach((package) {
      _addPackage(package);
      packageLicenseBindings[package].add(licenses.length);
    });
    licenses.add(entry);
  }

  void _addPackage(String package) {
    if (!packageLicenseBindings.containsKey(package)) {
      packageLicenseBindings[package] = List();
      packages.add(package);
      packages.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    }
  }
}

class _LicensesPageState extends State<LicensesPage> {
  final ValueNotifier<int> selectedId = ValueNotifier(null);

  final Future<LicenseData> licenses =
      LicenseRegistry.licenses.fold<LicenseData>(LicenseData(), (previous, license) {
    previous.addLicense(license);
    return previous;
  });

  @override
  Widget build(BuildContext context) {
    return MasterDetailFlow(
      title: Text(MaterialLocalizations.of(context).licensesPageTitle),
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {},
      ),
      masterViewBuilder: _masterView,
      detailPageBuilder: (context, final arguments, config) {
        assert(arguments is DetailArguments);
        if (arguments is DetailArguments) {
          return DetailPage(
            packageName: arguments.packageName,
            config: config,
            licenseEntries: arguments.licenseEntries,
          );
        } else {
          throw Exception('Expected DetailArguments, got $arguments');
        }
      },
    );
  }

  Widget _masterView(BuildContext context, bool isLateral, OpenDetailPageCallback openDetailPage) {
    return AnimatedSwitcher(
      transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
      duration: Duration(milliseconds: 500),
      child: FutureBuilder<LicenseData>(
        future: licenses,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final packageName = snapshot.data.packages[selectedId.value ?? 0];
              final bindings = snapshot.data.packageLicenseBindings[packageName];
              openDetailPage(
                DetailArguments(packageName,
                    bindings.map((it) => snapshot.data.licenses[it]).toList(growable: false)),
                isDefault: true,
              );
              return ValueListenableBuilder<int>(
                valueListenable: selectedId,
                builder: (context, selectedId, _) => Center(
                  child: Material(
                    color: Theme.of(context).cardColor,
                    elevation: 4,
                    child: Container(
                      constraints: BoxConstraints.loose(Size.fromWidth(600)),
                      child:
                          _buildList(context, selectedId, snapshot.data, openDetailPage, isLateral),
                    ),
                  ),
                ),
              );
            default:
              return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    int selectedId,
    LicenseData data,
    OpenDetailPageCallback openDetailPage,
    bool drawSelection,
  ) {
    return ListView.builder(
      itemCount: data.packages.length,
      itemBuilder: (context, index) {
        return index == 0
            ? Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: Responsive.getGutterSize(context), vertical: 24.0),
                child: Column(
                  children: <Widget>[
                    Text(
                      widget.applicationName,
                      style: Theme.of(context).textTheme.headline5,
                      textAlign: TextAlign.center,
                    ),
                    if (widget.applicationIcon != null)
                      IconTheme(
                        data: Theme.of(context).iconTheme,
                        child: widget.applicationIcon,
                      ),
                    Text(
                      widget.applicationVersion,
                      style: Theme.of(context).textTheme.bodyText2,
                      textAlign: TextAlign.center,
                    ),
                    Container(height: 18.0),
                    Text(
                      widget.applicationLegalese ?? '',
                      style: Theme.of(context).textTheme.caption,
                      textAlign: TextAlign.center,
                    ),
                    Container(height: 18.0),
                    Text(
                      'Powered by Flutter',
                      style: Theme.of(context).textTheme.bodyText2,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : _buildTile(context, index - 1, drawSelection && index - 1 == (selectedId ?? 0), data,
                openDetailPage);
      },
    );
  }

  Widget _buildTile(
    BuildContext context,
    int index,
    bool isSelected,
    LicenseData data,
    OpenDetailPageCallback openDetailPage,
  ) {
    final packageName = data.packages[index];
    final bindings = data.packageLicenseBindings[packageName];
    return Ink(
      color: isSelected ? Theme.of(context).highlightColor : Theme.of(context).cardColor,
      child: ListTile(
        title: Text(packageName),
        subtitle: Text('${bindings.length} licenses'),
        selected: isSelected,
        onTap: () {
          selectedId.value = index;
          openDetailPage(DetailArguments(
            packageName,
            bindings.map((it) => data.licenses[it]).toList(growable: false),
          ));
        },
      ),
    );
  }
}

class DetailArguments {
  DetailArguments(this.packageName, this.licenseEntries);

  final String packageName;
  final List<LicenseEntry> licenseEntries;

  @override
  bool operator ==(final dynamic other) {
    if (other is DetailArguments) {
      return other.packageName == packageName;
    }
    return other == this;
  }

  @override
  int get hashCode => packageName.hashCode;
}
