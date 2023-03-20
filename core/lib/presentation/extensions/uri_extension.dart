import 'package:core/presentation/extensions/url_extension.dart';
import 'package:core/utils/app_logger.dart';

extension URIExtension on Uri {

  Uri toQualifiedUrl({required Uri baseUrl}) {
    log('SessionUtils::toQualifiedUrl():baseUrl: $baseUrl | sourceUrl: $this');
    if (toString().startsWith(baseUrl.toString())) {
      final qualifiedUrl = toString().removeLastSlashOfUrl();
      log('SessionUtils::toQualifiedUrl():qualifiedUrl: $qualifiedUrl');
      return Uri.parse(qualifiedUrl);
    } else {
      final baseUrlValid = baseUrl.toString().removeLastSlashOfUrl();
      final sourceUrlValid = toString().addFirstSlashOfUrl().removeLastSlashOfUrl();
      log('SessionUtils::toQualifiedUrl():baseUrlValid: $baseUrlValid | sourceUrlValid: $sourceUrlValid');
      final qualifiedUrl = baseUrlValid + sourceUrlValid;
      log('SessionUtils::toQualifiedUrl():qualifiedUrl: $qualifiedUrl');
      return Uri.parse(qualifiedUrl);
    }
  }
}