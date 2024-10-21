
class NullSessionOrAccountIdException implements Exception {

  NullSessionOrAccountIdException();

  @override
  String toString() => 'NullSessionOrAccountIdException: session and accountId should not be null';
}
