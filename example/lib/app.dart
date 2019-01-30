import 'package:flutter/widgets.dart';
import 'package:package_info/package_info.dart';

typedef AppBuilder<T> = Widget Function(BuildContext context, T data);

class App<T> extends StatelessWidget {
  final AppBuilder builder;
  final Widget waiting;

  App.builder({
    Key key,
    @required this.builder,
    this.waiting,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => FutureBuilder<T>(
    future: init(),
    builder: _build,
  );

  Future init() {
    return PackageInfo.fromPlatform();
  }

  Widget _build(BuildContext context, AsyncSnapshot<T> snapshot) {
    switch(snapshot.connectionState) {
    case ConnectionState.done:
    case ConnectionState.none:
      return builder(context, snapshot.data);
    case ConnectionState.waiting:
    case ConnectionState.active:
      return waiting;
    }
  }
}
