
import 'package:core/core.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/composer/data/datasource/composer_datasource.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class ComposerDataSourceImpl extends ComposerDataSource {

  final DownloadClient downloadClient;
  final ExceptionThrower _exceptionThrower;

  ComposerDataSourceImpl(this.downloadClient, this._exceptionThrower);

  @override
  Future<String?> downloadImageAsBase64(
    String url,
    String cid,
    FileInfo fileInfo,
    {
      double? maxWidth,
      bool? compress
    }
  ) {
    return Future.sync(() async {
      return await downloadClient.downloadImageAsBase64(
        url,
        cid,
        fileInfo.fileExtension,
        fileInfo.fileName,
        fileInfo.mimeType,
        filePath: fileInfo.filePath,
        maxWidth: maxWidth,
        compress: compress);
    }).catchError(_exceptionThrower.throwException);
  }
}