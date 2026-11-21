import 'package:tmail_ui_user/main/exceptions/remote/network_exception.dart';

/// For read requests only: a write sent again could be applied twice.
///
/// A keep-alive socket iOS closed while the app was suspended fails the first
/// request after launch or resume; a new connection then succeeds.
Future<T> retryReadOnceOnTransportError<T>(
  Future<T> Function() read, {
  Duration delay = const Duration(milliseconds: 500),
}) async {
  try {
    return await read();
  } on SocketError {
    await Future<void>.delayed(delay);
  } on ConnectionError {
    await Future<void>.delayed(delay);
  }
  return read();
}
