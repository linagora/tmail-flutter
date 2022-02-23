
extension NameValidatorStringExtension on String {
  bool hasSpecialCharactersInName() {
    return  RegExp(r'(?=.*?[#?!@$%^&*)(=+}{:;?/|\\><.,`~])').hasMatch(this);
  }
}