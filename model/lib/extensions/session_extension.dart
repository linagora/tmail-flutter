
import 'package:jmap_dart_client/jmap/core/session/session.dart';

extension SessionExtension on Session {
  String getDownloadUrl() {
    var baseUrl = '${downloadUrl.origin}${downloadUrl.path}';
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    return Uri.decodeFull(baseUrl);
  }
}