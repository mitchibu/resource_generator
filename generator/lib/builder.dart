import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'resource_generator.dart';

Builder genarator(BuilderOptions options) => SharedPartBuilder(
  [
    ResourceGenerator(),
  ],
  'resoure_generator'
);
