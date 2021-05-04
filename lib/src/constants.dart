/// maps types to the names of their corresponding validators. for example,
/// a field of type [String] should be validated by a StringValidator.
const validatorMap = <String, String>{
  'String': 'StringValidator',
  'int': 'IntValidator',
  'dynamic': 'Validator',
};
