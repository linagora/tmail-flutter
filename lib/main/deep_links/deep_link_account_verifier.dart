import 'package:dio/dio.dart';
import 'package:tmail_ui_user/main/deep_links/open_app_deep_link_data.dart';
import 'package:tmail_ui_user/main/utils/app_config.dart';

/// Asks the JMAP server which account a sign-in link's access token belongs to.
///
/// The `username` of an `openApp` link is free text chosen by whoever built
/// the link, so it proves nothing. The server-side identity of the token is
/// what the user must confirm before the app stores that token.
///
/// A bare [Dio] is used on purpose: the link token never goes through the app
/// interceptors of a signed-in session, and nothing is persisted.
class DeepLinkAccountVerifier {
  static const Duration _timeout = Duration(seconds: 10);
  static const String _sessionPath = '/.well-known/jmap';

  final Dio Function() _createDio;

  DeepLinkAccountVerifier({Dio Function()? createDio})
      : _createDio = createDio ?? Dio.new;

  /// Returns the `username` of the JMAP session of the link token: the
  /// account a sign-in with this token opens. Throws when the server refuses
  /// the token, can't be reached, or sends no username.
  ///
  /// Only the session username counts: the names of the other accounts the
  /// token can access (team mailboxes) are not who the user signs in as.
  Future<String> getAccountUsername(OpenAppDeepLinkData data) async {
    final dio = _createDio()
      ..options = BaseOptions(
        baseUrl: data.jmapUrl,
        connectTimeout: _timeout,
        receiveTimeout: _timeout,
        headers: {
          'Authorization': 'Bearer ${data.accessToken}',
          'Accept': 'application/json',
        },
      );

    try {
      final response = await dio.get<Map<String, dynamic>>(_sessionPath);
      if (!_isAllowedOrigin(response.realUri)) {
        throw StateError('The JMAP session was answered by a host that is not allowed');
      }
      final username = response.data?['username'];
      if (username is! String || username.trim().isEmpty) {
        throw StateError('The JMAP session has no username');
      }
      return username;
    } finally {
      dio.close(force: true);
    }
  }

  static bool _isAllowedOrigin(Uri uri) =>
      uri.isScheme('https') && AppConfig.deepLinkAllowedHosts.contains(uri.host);
}
