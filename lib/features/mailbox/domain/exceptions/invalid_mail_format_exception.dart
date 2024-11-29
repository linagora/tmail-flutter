
class InvalidMailFormatException implements Exception {
  final String mail;

  InvalidMailFormatException(this.mail);

  @override
  String toString() => 'InvalidMailFormatException: $mail';
}
