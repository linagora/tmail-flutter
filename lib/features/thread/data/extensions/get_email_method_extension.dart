import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/mail/email/get/get_email_method.dart';

extension GetEmailMethodExtension on GetEmailMethod {
  void addPropertiesIfNotNull(Properties? properties) {
    if (properties != null) addProperties(properties);
  }
}
