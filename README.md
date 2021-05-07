# former_gen

Code generation for former.

## Usage

0. Make sure `build_runner` is installed.
1. Annotate your form class with `@Formable`
2. Add `part '<file-name>.g.dart';` before your class declaration
3. Add `class YourForm = _YourForm with _$YourFormIndexable;`
4. Run `flutter pub get build_runner build`
5. A `.g.dart` file should be generated next to the file that contains your form class.

## What's generated

- A mixin that makes your form class "indexable" with the bracket operator.
- An enum class that includes all the fields of your form.
  They are used when you need to specify what field a particular
  Former widget should control.
- A schema class that you should create when using the `Former` widget.
  Use it to describe the requirements of your form, using either the built-in validators
  or create your own by implementing `Validator` class.
