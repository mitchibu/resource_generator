import 'package:flutter/widgets.dart';
import 'package:resource_generator_annotation/annotation.dart';

part 'resources.g.dart';

MyResources R;
MyResources initResources(BuildContext context) => R ??= MyResources(context);

@Resources(path: 'resources')
class MyResources {
  static List<String> types;
  static List<String> _resourceTypes(BuildContext context) {
    if(types == null) {
      types = [];
      types.add(Localizations.localeOf(context).languageCode);
      types.add(String.fromEnvironment('flavor'));
    }
    return types;
  }

  final $String string;
  final $Value value;

  MyResources(BuildContext context)
    : string = _findStringResource(_resourceTypes(context))
    , value = _findValueResource(_resourceTypes(context));
}
