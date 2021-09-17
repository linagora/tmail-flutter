
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:uri/uri.dart';

extension SessionExtension on Session {
  String getDownloadUrl() {
    var baseUrl = '${downloadUrl.origin}${downloadUrl.path}';
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    return Uri.decodeFull(baseUrl);
  }

  Uri getUploadUrl(AccountId accountId) {
    final baseUrl = '${uploadUrl.origin}${uploadUrl.path}';
    final uploadUriTemplate = UriTemplate('${Uri.decodeFull(baseUrl)}');
    final uploadUri = uploadUriTemplate.expand({
      'accountId' : '${accountId.id.value}'
    });
    return Uri.parse(uploadUri);
  }
}