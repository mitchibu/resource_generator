// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resources.dart';

// **************************************************************************
// ResourceGenerator
// **************************************************************************

class $String$ja extends $String {
  const $String$ja()
      : super(
          app_name: 'テスト',
          message: 'ボタンを押した回数:',
          test1: '1',
        );
}

class $String {
  final String app_name;
  final String message;
  final String test1;
  const $String({
    this.app_name = 'test',
    this.message = 'You have pushed the button this many times:',
    this.test1 = '1',
  });
}

class $Value {
  final int test2;
  final double test3;
  final bool test4;
  const $Value({
    this.test2 = 1,
    this.test3 = 1.0,
    this.test4 = true,
  });
}

typedef Instantiate<T> = T Function();
Map<String, Instantiate<$String>> _$StringMap = {
  '': () => $String(),
  '_ja': () => $String$ja(),
};
Map<String, Instantiate<$Value>> _$ValueMap = {
  '': () => $Value(),
};
String _getKey(List<String> attrs) {
  String key = '';
  attrs.remove(null);
  attrs.remove('');
  attrs.forEach((attr) {
    key += '_$attr';
  });
  return key;
}

$String _findStringResource(List<String> attrs) =>
    (_$StringMap[_getKey(attrs)] ?? _$StringMap[''])();
$Value _findValueResource(List<String> attrs) =>
    (_$ValueMap[_getKey(attrs)] ?? _$ValueMap[''])();
