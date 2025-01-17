import 'package:core/presentation/extensions/url_extension.dart';
import 'package:core/utils/app_logger.dart';

extension URIExtension on Uri {

  Uri toQualifiedUrl({required Uri baseUrl}) {
    log('SessionUtils::toQualifiedUrl():baseUrl: $baseUrl | sourceUrl: $this');
    if (hasOrigin) {
      final qualifiedUrl = toString();
      log('SessionUtils::toQualifiedUrl():qualifiedUrl: $qualifiedUrl');
      return Uri.parse(qualifiedUrl);
    } else if (toString().isEmpty) {
      log('SessionUtils::toQualifiedUrl():qualifiedUrl: $baseUrl');
      return baseUrl;
    } else {
      final baseUrlValid = baseUrl.toString().removeLastSlashOfUrl();
      final sourceUrlValid = toString().addFirstSlashOfUrl();
      log('SessionUtils::toQualifiedUrl():baseUrlValid: $baseUrlValid | sourceUrlValid: $sourceUrlValid');
      final qualifiedUrl = baseUrlValid + sourceUrlValid;
      log('SessionUtils::toQualifiedUrl():qualifiedUrl: $qualifiedUrl');
      return Uri.parse(qualifiedUrl);
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