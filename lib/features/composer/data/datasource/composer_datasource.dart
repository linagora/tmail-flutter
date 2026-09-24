
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/composer/domain/model/image_download_options.dart';

abstract class ComposerDataSource {
  Future<String?> downloadImageAsBase64(String url, String cid, FileInfo fileInfo, {ImageDownloadOptions? options});
}