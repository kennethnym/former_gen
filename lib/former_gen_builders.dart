library former_gen.builder;

import 'package:build/build.dart';
import 'package:former_gen/src/builders/formable_builder.dart';
import 'package:source_gen/source_gen.dart';

Builder formerBuilder(BuilderOptions options) =>
    SharedPartBuilder([FormableBuilder()], 'former');
