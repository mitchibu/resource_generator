import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:package_info/package_info.dart';
import 'app.dart';
import 'resources.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => App<PackageInfo>.builder(
    builder: (context, data) => MaterialApp(
      title: data.appName,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      supportedLocales: [
        const Locale('en', 'US'),
        const Locale('ja', 'JP'),
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,  
        GlobalWidgetsLocalizations.delegate  
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for(var supportedLocale in supportedLocales) {
          if(supportedLocale.languageCode == locale.languageCode || supportedLocale.countryCode == locale.countryCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      // home: MyHomePage(title: initResources(context).string.app_name),
      builder: (context, child) {
        return MyHomePage(title: initResources(context).string.app_name);
      },
    ),
  );
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              R.string.message,
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
