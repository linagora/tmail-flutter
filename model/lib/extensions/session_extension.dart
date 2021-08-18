
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:uri/uri.dart';

extension SessionExtension on Session {

  String getDownloadUrl(String accountId, String blobId, String name, String type) {
    final downloadUriTemplate = UriTemplate('${downloadUrl.origin}');
    return downloadUriTemplate.expand({
      'accountId' : '$accountId',
      'blobId' : '$blobId',
      'name' : '$name',
      'type' : '$type',
    });
  }
}