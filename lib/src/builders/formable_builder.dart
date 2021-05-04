import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:former_gen/src/annotations/formable.dart';
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

    final fields =
        element.fields.where(_isNotIgnored).map((field) => field.name);

    final baseFormName = element.name;
    final formName = element.name.substring(0, baseFormName.length - 4);
    final generatedFormerField = '${formName}Field';

    return '''
/// All fields of [$generatedFormerField]
class $formName extends $baseFormName implements FormerForm {
  @override
  dynamic operator [](FormerField field) {
    switch (field.fieldName) {
      ${fields.map((field) => '''
        case '$field':
          return $field;
      ''').join('\n')}
    }
  }
  
  @override
  void operator []=(FormerField field, dynamic newValue) {
    switch (field.fieldName) {
      ${fields.map((field) => '''
        case '$field':
          $field = newValue;
          break;
      ''').join('\n')}
    }
  }
}

class $generatedFormerField extends FormerField {
  const $generatedFormerField._(String fieldName) : super(fieldName);

  ${fields.map((field) => "static const $field = $generatedFormerField._('$field');").join('\n')}
}
''';
  }

  bool _isNotIgnored(FieldElement field) {
    final annotations = _formableIgnoreTypeChecker.annotationsOf(field);
    return annotations.isEmpty;
  }
}
