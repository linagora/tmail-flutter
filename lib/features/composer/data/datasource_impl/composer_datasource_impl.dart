
import 'package:core/core.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/composer/data/datasource/composer_datasource.dart';
import 'package:tmail_ui_user/features/composer/domain/model/image_download_options.dart';
import 'package:tmail_ui_user/main/exceptions/thrower/exception_thrower.dart';

class ComposerDataSourceImpl extends ComposerDataSource {

  final DownloadClient downloadClient;
  final ExceptionThrower _exceptionThrower;

  ComposerDataSourceImpl(this.downloadClient, this._exceptionThrower);

  @override
  Future<String?> downloadImageAsBase64(
    String url,
    String cid,
    FileInfo fileInfo,
    {ImageDownloadOptions? options}
  ) {
    return Future.sync(() async {
      return await downloadClient.downloadImageAsBase64(
        url,
        cid,
        fileInfo.fileExtension,
        fileInfo.fileName,
        fileInfo.mimeType,
        filePath: fileInfo is FilePathInfo ? fileInfo.filePath : null,
        maxWidth: options?.maxWidth,
        compress: options?.compress);
    }).catchError(_exceptionThrower.throwException);
  }
}