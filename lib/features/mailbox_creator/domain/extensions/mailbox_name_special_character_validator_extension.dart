
extension MailboxNameSpecialCharacterValidatorExtension on String {
  bool get isValid {
    if (startsWith('#')) {
      return false;
    }

    final forbiddenChars = RegExp(r'[%*\r\n]');
    if (forbiddenChars.hasMatch(this)) {
      return false;
    }

    return true;
  }
}