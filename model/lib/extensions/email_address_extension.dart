import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/email/email_address_cache.dart';
import 'package:core/core.dart';

extension EmailAddressExtension on EmailAddress {

  String asString() {
    if (displayName.isNotEmpty) {
      if (emailAddress.isNotEmpty && displayName == emailAddress) {
        return displayName;
      }
      return displayName.capitalizeFirstEach;
    } else if (emailAddress.isNotEmpty) {
      return emailAddress;
    }
    return '';
  }

  String asFullString() {
    if (displayName.isNotEmpty) {
      if (emailAddress.isNotEmpty) {
        return '${displayName.capitalizeFirstEach} <$emailAddress>';
      }
      return displayName.capitalizeFirstEach;
    } else if (emailAddress.isNotEmpty) {
      return emailAddress;
    }
    return '';
  }

  String get emailAddress => email ?? '';

  String get displayName => name ?? '';

  EmailAddressCache toEmailAddressCache() => EmailAddressCache(displayName, emailAddress);
}