import 'package:core/presentation/extensions/capitalize_extension.dart';
import 'package:core/presentation/extensions/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';

extension EmailAddressExtension on EmailAddress {

  String asString() {
    if (displayName.isNotEmpty) {
      return displayName;
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

  String asFullStringWithLtGtCharacter() {
    if (displayName.isNotEmpty && emailAddress.isNotEmpty) {
      return '${displayName.capitalizeFirstEach} <$emailAddress>';
    } else if (displayName.isNotEmpty) {
      return displayName.capitalizeFirstEach;
    } else if (emailAddress.isNotEmpty) {
      return '<$emailAddress>';
    }
    return '';
  }

  String get emailAddress => email ?? '';

  String get displayName => name ?? '';

  String get labelAvatar => asString().isNotEmpty ? asString()[0].toUpperCase() : '';

  List<Color> get avatarColors => emailAddress.gradientColors;
}