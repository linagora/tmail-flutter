
import 'package:core/core.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/composer/data/datasource/composer_datasource.dart';

class ComposerDataSourceImpl extends ComposerDataSource {

  final DownloadClient downloadClient;

  ComposerDataSourceImpl(this.downloadClient);

  @override
  Future<String?> downloadImageAsBase64(String url, String cid, FileInfo fileInfo, {double? maxWidth, bool? compress}) {
    return downloadClient.downloadImageAsBase64(
        url,
        cid,
        fileInfo.fileExtension,
        fileInfo.fileName,
        bytesData: fileInfo.bytes,
        maxWidth: maxWidth,
        compress: compress);
  }
}