import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:former_gen/src/annotations/formable.dart';
import 'package:former_gen/src/constants.dart';
import 'package:former_gen/src/utils/list_utils.dart';
import 'package:source_gen/source_gen.dart';

class FormableBuilder extends GeneratorForAnnotation<Formable> {
  /// A [TypeChecker] that checks whether a given [Element] is annotated with
  /// [FormableIgnore].
  late final TypeChecker _formableIgnoreTypeChecker;

  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element.kind != ElementKind.CLASS || element is! ClassElement) {
      throw UnsupportedError('@Formable annotation only works on classes.');
    }

    _formableIgnoreTypeChecker = TypeChecker.fromRuntime(FormableIgnore);

    final fields = element.fields.where(_isNotIgnored).toList();

    final formName = element.name;
    final formNameNoDanglingUnderscore =
        element.name.startsWith('_') ? element.name.substring(1) : element.name;
    final generatedFormerField = '${formNameNoDanglingUnderscore}Field';
    final schemaName = '${formNameNoDanglingUnderscore}Schema';

    return '''
mixin _\$${formNameNoDanglingUnderscore}Indexable on $formName {
  @override
  dynamic operator [](FormerField field) {
    switch (field.value) {
      ${fields.mapIndexed((i, field) => '''
        case $i:
          return ${field.name};
      ''').join('\n')}
    }
  }
  
  @override
  void operator []=(FormerField field, dynamic newValue) {
    switch (field.value) {
      ${fields.mapIndexed((i, field) => '''
        case $i:
          ${field.name} = newValue;
          break;
      ''').join('\n')}
    }
  }
}

/// All fields of [$formName]
class $generatedFormerField extends FormerField {
  const $generatedFormerField._(int value) : super(value);
  
  static const all = [${fields.map((field) => field.name).join(', ')}];

  ${fields.mapIndexed((i, field) => "static const ${field.name} = $generatedFormerField._($i);").join('\n')}
}

/// A [FormerSchema] that [$formName] needs to conform to.
class $schemaName implements FormerSchema<$formName> {
  ${fields.map((field) => 'final ${validatorMap[field.type.element?.name ?? 'dynamic']} ${field.name};').join('\n')}
  
  const $schemaName({
    ${fields.map((field) => 'required this.${field.name},').join('\n')}
  });
  
  @override
  bool validate($formName form) {
    var isValid = true;

    ${fields.map((field) => 'isValid = ${field.name}.validate(form.${field.name});').join('\n')}

    return isValid;
  }
}
''';
  }

  bool _isNotIgnored(FieldElement field) {
    final annotations = _formableIgnoreTypeChecker.annotationsOf(field);
    return annotations.isEmpty;
  }
}
