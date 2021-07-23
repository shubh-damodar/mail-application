
class ValidatorTextField {
  RegExp regExp;
  String emailPattern="^[a-zA-Z0-9.!#\$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*\$";

  bool validateTextField(String pattern, String compareData)  {
    regExp=RegExp(pattern);
    return regExp.hasMatch(compareData);
  }
}