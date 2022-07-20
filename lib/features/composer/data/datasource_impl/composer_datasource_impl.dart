
import 'package:core/core.dart';
import 'package:tmail_ui_user/features/composer/data/datasource/composer_datasource.dart';

class ComposerDataSourceImpl extends ComposerDataSource {

  final DownloadClient downloadClient;

  ComposerDataSourceImpl(this.downloadClient);

  @override
  Future<String?> downloadImageAsBase64(String url) {
    return downloadClient.downloadImageAsBase64(url);
  }
}