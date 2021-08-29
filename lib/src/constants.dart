/// maps types to the names of their corresponding validators. for example,
/// a field of type [String] should be validated by a StringValidator.
const validatorMap = <String, String>{
  'String': 'StringMust',
  'int': 'NumberMust',
  'double': 'NumberMust',
  'num': 'NumberMust',
  'bool': 'BoolMust',
  'dynamic': 'Validator',
};
