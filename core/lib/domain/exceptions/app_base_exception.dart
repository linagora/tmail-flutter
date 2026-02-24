abstract class AppBaseException implements Exception {
  final String? message;

  const AppBaseException([this.message]);

  @override
  String toString() {
    if (message != null && message!.isNotEmpty) {
      return '$exceptionName: $message';
    }
    return exceptionName;
  }

  String get exceptionName;
}
