import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:former_gen/src/annotations/formable.dart';
import 'package:former_gen/src/constants.dart';
import 'package:former_gen/src/utils/list_utils.dart';
import 'package:source_gen/source_gen.dart';

class FormableBuilder extends GeneratorForAnnotation<Formable> {
  /// A [TypeChecker] that checks whether a given [Element] is annotated with
  /// [FormableIgnore].
  final _formableIgnoreTypeChecker = TypeChecker.fromRuntime(FormableIgnore);

  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element.kind != ElementKind.CLASS || element is! ClassElement) {
      throw UnsupportedError('@Formable annotation only works on classes.');
    }

    final fields = element.fields.where(_isNotIgnored).toList();

    final formName = element.name;
    final formNameNoDanglingUnderscore =
        element.name.startsWith('_') ? element.name.substring(1) : element.name;
    final generatedFormerField = '${formNameNoDanglingUnderscore}Field';
    final schemaName = '${formNameNoDanglingUnderscore}Schema';

    return '''
mixin _\$${formNameNoDanglingUnderscore} on $formName {
  @override
  final Map<FormerField, String> fieldType = {
    ${fields.map((field) => _typeMapEntry(field, generatedFormerField)).join(',\n')}
  };

  @override
  dynamic operator [](FormerField field) {
    if (field is! $generatedFormerField) {
      throw ArgumentError(
        '\$field cannot be used to index ${formNameNoDanglingUnderscore}'
        'Do you mean to use $generatedFormerField instead?',
      );
    }

    switch (field.value) {
      ${fields.mapIndexed((i, field) => '''
        case $i:
          return ${field.name};
      ''').join('\n')}
    }
  }

  @override
  void operator []=(FormerField field, dynamic newValue) {
    if (field is! $generatedFormerField) {
      throw ArgumentError(
        '\$field cannot be used to index ${formNameNoDanglingUnderscore}'
        'Do you mean to use $generatedFormerField instead?',
      );
    }

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
class $schemaName extends FormerSchema<$formName> {
  ${fields.map((field) => 'final ${validatorMap[field.type.element?.name ?? 'dynamic'] ?? 'Validator'} ${field.name};').join('\n')}

  const $schemaName({
    ${fields.map((field) => 'required this.${field.name},').join('\n')}
  });
  
  @override
  String errorOf(FormerField field) {
    if (field is! $generatedFormerField) {
      throw ArgumentError(
        '\$field cannot be used to access ${formNameNoDanglingUnderscore}.'
        'Do you mean to use $generatedFormerField instead?',
      );
    }

    switch (field.value) {
      ${fields.mapIndexed((i, field) => '''
        case $i:
          return ${field.name}.error;
      ''').join('\n')}

      default:
        return '';
    }
  }

  @override
  bool validate($formName form) => [
      ${fields.map((field) => '${field.name}.validate(form.${field.name}),').join('\n')}
    ].every(fieldIsValid);
}
''';
  }

  bool _isNotIgnored(FieldElement field) {
    final annotations = _formableIgnoreTypeChecker.annotationsOf(field);
    return annotations.isEmpty;
  }

  /// Generate an entry in fieldMap for [field].
  String _typeMapEntry(FieldElement field, String generatedFormerField) {
    final fieldName = field.name;
    final typeName = field.type.element?.name ?? 'dynamic';
    final nullabilitySuffix =
        field.type.nullabilitySuffix == NullabilitySuffix.question ? '?' : '';

    return "${generatedFormerField}.$fieldName: '$typeName$nullabilitySuffix'";
  }
}
