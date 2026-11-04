import 'package:dio/dio.dart';
import 'package:tmail_ui_user/main/deep_links/open_app_deep_link_data.dart';

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

  /// Returns the identities the server reports for the link token: the session
  /// `username` first, then the names of the accounts it can access.
  Future<List<String>> getAccountIdentities(OpenAppDeepLinkData data) async {
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
      return _identitiesOf(response.data ?? const {});
    } finally {
      dio.close(force: true);
    }
  }

  static List<String> _identitiesOf(Map<String, dynamic> session) {
    final accounts = session['accounts'];
    final accountNames = accounts is Map
        ? accounts.values
            .whereType<Map>()
            .map((account) => account['name'])
            .whereType<String>()
        : const <String>[];

    return [
      if (session['username'] is String) session['username'] as String,
      ...accountNames,
    ].where((identity) => identity.trim().isNotEmpty).toList();
  }
}
