
import 'package:core/utils/app_logger.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:uri/uri.dart';

extension SessionExtension on Session {
  String getDownloadUrl() {
    var baseUrl = '${downloadUrl.origin}${downloadUrl.path}?${downloadUrl.query}';
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    log('SessionExtension::getDownloadUrl(): $baseUrl');
    final downloadUrlDecode = Uri.decodeFull(baseUrl);
    log('SessionExtension::getDownloadUrl(): DECODE $downloadUrlDecode');
    return downloadUrlDecode;
  }

  Uri getUploadUri(AccountId accountId) {
    final baseUrl = '${uploadUrl.origin}${uploadUrl.path}';
    final uploadUriTemplate = UriTemplate('${Uri.decodeFull(baseUrl)}');
    final uploadUri = uploadUriTemplate.expand({
      'accountId' : '${accountId.id.value}'
    });
    log('SessionExtension::getUploadUri(): uploadUri: $uploadUri');
    return Uri.parse(uploadUri);
  }
}