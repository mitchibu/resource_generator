import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';

import 'package:resource_generator_annotation/annotation.dart';

const BASE_STRING_CLASS = '\$String';
const BASE_VALUE_CLASS = '\$Value';
const STRING_MAP_NAME = '_\$StringMap';
const VALUE_MAP_NAME = '_\$ValueMap';

class ResourceGenerator extends GeneratorForAnnotation<Resources> {
  final Map<String, Map<String, dynamic>> _stringResourceMap = {};
  final Map<String, Map<String, dynamic>> _valueResourceMap = {};

  @override
  FutureOr<String> generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    if(element is! ClassElement) {
      throw InvalidGenerationSourceError('Generator can not target \'${element.name}\'.');
    }

    var buffer = StringBuffer();
//    buffer.writeln('/*');
    _marge(Directory(annotation.read('path').stringValue));
    _output(buffer);
//    buffer.writeln('*/');
    return buffer.toString();
  }

  void _marge(Directory dir) {
    dir.listSync(recursive: true).forEach((entity) {
      if(FileSystemEntity.isDirectorySync(entity.path)) return;

      String path = entity.parent.path.replaceAll(dir.path, '');
      Map<String, dynamic> json = jsonDecode(File(entity.path).readAsStringSync());
      json.forEach((name, value) {
        if(value is String) {
          Map<String, dynamic> stringResources = _stringResourceMap[path];
          if(stringResources == null) stringResources = _stringResourceMap[path] = {};
          stringResources[name] = value;
        } else {
          Map<String, dynamic> valueResources = _valueResourceMap[path];
          if(valueResources == null) valueResources = _valueResourceMap[path] = {};
          valueResources[name] = value;
        }
      });
    });

    Map<String, Map<String, dynamic>> groupedResourceMap = _margeResources(_stringResourceMap);
    _stringResourceMap.clear();
    _stringResourceMap.addAll(groupedResourceMap);

    groupedResourceMap = _margeResources(_valueResourceMap);
    _valueResourceMap.clear();
    _valueResourceMap.addAll(groupedResourceMap);
  }

  Map<String, Map<String, dynamic>> _margeResources(Map<String, Map<String, dynamic>> resourceMap) {
    Map<String, Map<String, dynamic>> groupedResourceMap = {};
    List<String> keys = List.from(resourceMap.keys);
    keys.forEach((key) {
      List<String> parents = _findParents(keys, key);
      parents.sort((a, b) => a.compareTo(b));

      Map<String, dynamic> resources = {};
      parents.forEach((parent) {
        resources.addAll(resourceMap[parent]);
      });
      resources.addAll(resourceMap[key]);
      groupedResourceMap[key] = resources;
    });
    return groupedResourceMap;
  }

  List<String> _findParents(List<String> keys, String current) {
    List<String> parents = [];
    int index;
    do {
      index = current.lastIndexOf(Platform.pathSeparator);
      if(index >= 0) {
        current = current.substring(0, index);
        if(keys.contains(current)) parents.add(current);
      }
    } while(index >= 0);
    return parents;
  }

  void _output(StringBuffer buffer) {
    List<String> stringClasses = [];
    List<String> valueClasses = [];

    _stringResourceMap.forEach((path, map) {
      stringClasses.add(_outputClass(buffer, BASE_STRING_CLASS, path, map));
    });
    _valueResourceMap.forEach((path, map) {
      valueClasses.add(_outputClass(buffer, BASE_VALUE_CLASS, path, map));
    });

    buffer.writeln('typedef Instantiate<T> = T Function();');
    stringClasses.sort((a, b) => a.compareTo(b));
    _outputInstantiateMap(buffer, BASE_STRING_CLASS, STRING_MAP_NAME, stringClasses);
    valueClasses.sort((a, b) => a.compareTo(b));
    _outputInstantiateMap(buffer, BASE_VALUE_CLASS, VALUE_MAP_NAME, valueClasses);

    _outputKeyGetter(buffer);
    _outputValueResourceGetter(buffer, BASE_STRING_CLASS, '_findStringResource', STRING_MAP_NAME);
    _outputValueResourceGetter(buffer, BASE_VALUE_CLASS, '_findValueResource', VALUE_MAP_NAME);
  }

  String _outputClass(StringBuffer buffer, String baseName, String path, Map<String, dynamic> fields) {
    String className = baseName;
    String superClassName;
    if(path.isNotEmpty) {
      className += path.replaceAll(Platform.pathSeparator, '\$');
      superClassName = baseName;
    }

    if(superClassName == null) {
      buffer.writeln('class $className {');
      if(fields.isEmpty) {
        buffer.writeln('  const $className();');
      } else {
        List<String> params = [];
        fields.forEach((name, value) {
          buffer.writeln('  final ${value.runtimeType} $name;');
          if(value is String) value = '\'$value\'';
          params.add('this.$name = $value');
        });
        buffer.writeln('  const $className({');
        params.forEach((param) {
          buffer.writeln('    $param,');
        });
        buffer.writeln('  });');
      }
      buffer.writeln('}');
    } else {
      buffer.writeln('class $className extends $superClassName {');
      buffer.writeln('  const $className() : super(');
      fields.forEach((name, value) {
        if(value is String) value = '\'$value\'';
        buffer.writeln('    $name: $value,');
      });
      buffer.writeln('  );');
      buffer.writeln('}');
    }
    return className;
  }

  void _outputInstantiateMap(StringBuffer buffer, String baseName, String mapName, List<String> classes) {
    buffer.writeln('Map<String, Instantiate<$baseName>> $mapName = {');
    classes.forEach((name) {
      String key = name.substring(baseName.length);
      if(key.startsWith('\$')) key = key.replaceAll('\$', '_');
      buffer.writeln('  \'$key\': () => $name(),');
    });
    buffer.writeln('};');
  }

  void _outputKeyGetter(StringBuffer buffer) {
    buffer.writeln('String _getKey(List<String> attrs) {');
    buffer.writeln('  String key = \'\';');
    buffer.writeln('  attrs.remove(null);');
    buffer.writeln('  attrs.remove(\'\');');
    buffer.writeln('  attrs.forEach((attr) {');
    buffer.writeln('    key += \'_\$attr\';');
    buffer.writeln('  });');
    buffer.writeln('  return key;');
    buffer.writeln('}');
  }

  void _outputValueResourceGetter(StringBuffer buffer, String className, String methodName, String mapName) {
    buffer.writeln('$className $methodName(List<String> attrs) => ($mapName[_getKey(attrs)] ?? $mapName[\'\'])();');
  }
}
