
import 'package:model/upload/file_info.dart';

abstract class ComposerDataSource {
  Future<String?> downloadImageAsBase64(String url, String cid, FileInfo fileInfo, {double? maxWidth, bool? compress});
}