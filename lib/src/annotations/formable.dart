/// Annotates classes that will be consumed by [Former].
///
/// All fields in the annotated class will be treated as an entry in the form,
/// unless it is marked as [FormableIgnore].
///
/// A class will be generated containing all the fields in the form
/// and their string representation.
/// It enables safer access to form fields without resorting to magic strings.
///
/// For example, The [Field] widget needs to know what field in the form
/// it is representing via the [Field.name] attribute so that it can
/// update the correct entry in the form.
class Formable {
  const Formable();
}

/// [FormableIgnore] tells the code generator to not treat the annotated
/// field as part of the form.
class FormableIgnore {
  const FormableIgnore();
}
