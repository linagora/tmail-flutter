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
      if (!hasOrigin) {
        final baseUrlValid = baseUrl.toString().removeLastSlashOfUrl();
        final sourceUrlValid = toString().addFirstSlashOfUrl().removeLastSlashOfUrl();
        log('SessionUtils::toQualifiedUrl():baseUrlValid: $baseUrlValid | sourceUrlValid: $sourceUrlValid');
        final qualifiedUrl = baseUrlValid + sourceUrlValid;
        log('SessionUtils::toQualifiedUrl():qualifiedUrl: $qualifiedUrl');
        return Uri.parse(qualifiedUrl);
      } else {
        final qualifiedUrl = toString().removeLastSlashOfUrl();
        log('SessionUtils::toQualifiedUrl():qualifiedUrl: $qualifiedUrl');
        return Uri.parse(qualifiedUrl);
      }
    }
  }

  bool get hasOrigin {
    try {
      return origin.isNotEmpty;
    } catch (e) {
      logError('URIExtension::hasOrigin:Exception = $e');
      return false;
    }
  }
}