import 'package:core/presentation/extensions/url_extension.dart';
import 'package:core/utils/app_logger.dart';

extension URIExtension on Uri {

  String get asString => toString();

  Uri toQualifiedUrl(String baseUrl) {
    final originUrl = asString;
    log('URIExtension::toQualifiedUrl(): BASE_URL = $baseUrl | ORIGIN_URL = $originUrl');
    if (originUrl.isValid()) {
      return this;
    }

    final baseUrlValid = baseUrl.removeLastSlashOfUrl();
    log('URIExtension::toQualifiedUrl(): BASE_URL_VALID = $baseUrlValid');
    final qualifiedUrl = '$baseUrlValid$originUrl'.removeLastSlashOfUrl();
    log('URIExtension::toQualifiedUrl(): QUALIFIED = $qualifiedUrl');
    return Uri.parse(qualifiedUrl);
  }
}