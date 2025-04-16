
import 'dart:ui';

import 'package:core/presentation/extensions/uri_extension.dart';
import 'package:get/get_utils/src/extensions/string_extensions.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/calendar_event_capability.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_properties.dart';
import 'package:jmap_dart_client/jmap/core/capability/default_capability.dart';
import 'package:jmap_dart_client/jmap/core/capability/empty_capability.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/error_type_handler/account_exception.dart';
import 'package:model/error_type_handler/unknown_address_exception.dart';
import 'package:model/error_type_handler/unknown_uri_exception.dart';
import 'package:model/model.dart';
import 'package:model/principals/capability_principals.dart';
import 'package:uri/uri.dart';

extension SessionExtension on Session {

  String getDownloadUrl({String? jmapUrl}) {
    final Uri downloadUrlValid;
    if (jmapUrl != null) {
      downloadUrlValid = downloadUrl.toQualifiedUrl(baseUrl: Uri.parse(jmapUrl));
    } else if (downloadUrl.hasOrigin) {
      downloadUrlValid = downloadUrl;
    } else {
      throw UnknownUriException();
    }

    var baseUrl = '${downloadUrlValid.origin}${downloadUrlValid.path}?${downloadUrlValid.query}';
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    final downloadUrlDecode = Uri.decodeFull(baseUrl);
    return downloadUrlDecode;
  }

  Uri getUploadUri(AccountId accountId, {String? jmapUrl}) {
    final Uri uploadUrlValid;
    if (jmapUrl != null) {
      uploadUrlValid = uploadUrl.toQualifiedUrl(baseUrl: Uri.parse(jmapUrl));
    } else if (uploadUrl.hasOrigin) {
      uploadUrlValid = uploadUrl;
    } else {
      throw UnknownUriException();
    }

    final baseUrl = '${uploadUrlValid.origin}${uploadUrlValid.path}';
    final uploadUriTemplate = UriTemplate(Uri.decodeFull(baseUrl));
    final uploadUri = uploadUriTemplate.expand({
      'accountId' : accountId.id.value
    });
    return Uri.parse(uploadUri);
  }

  T? getCapabilityProperties<T extends CapabilityProperties>(
    AccountId accountId,
    CapabilityIdentifier identifier
  ) {
    var capability = accounts[accountId]?.accountCapabilities[identifier];
    if (capability == null || capability is EmptyCapability) {
      capability = capabilities[identifier];
    }
    if (capability is T) {
      return capability;
    } else {
      return null;
    }
  }

  String getOwnEmailAddress() {
    return username.value.isEmail ? username.value
        : _getOwnEmailAddressFromPersonalAccount()
        ?? _getOwnEmailAddressFromPrincipalsCapability()
        ?? (throw UnknownAddressException());
  }

  String? _getOwnEmailAddressFromPersonalAccount() {
    try {
      return personalAccount.name.value.isEmail ? personalAccount.name.value : null;
    } catch (_) {
      return null;
    }
  }

  String? _getOwnEmailAddressFromPrincipalsCapability() {
    try {
      var principalsCapability = getCapabilityProperties<DefaultCapability>(AccountId(Id(username.value)), capabilityPrincipals);
      final sendTo = principalsCapability?.properties?['urn:ietf:params:jmap:calendars']?['sendTo'];
      if (sendTo is Map<String, dynamic>) {
        final wrappedAddress = sendTo['imip'];
        if (wrappedAddress is String && wrappedAddress.startsWith('mailto:')) {
          String address = wrappedAddress.substring("mailto:".length);
          return address.isEmail ? address : null;
        }
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  JmapAccount get personalAccount {
    if (accounts.isNotEmpty) {
      final listPersonalAccount = accounts.entries
        .map((entry) => entry.value.toJmapAccount(entry.key))
        .where((jmapAccount) => jmapAccount.isPersonal)
        .toList();

      if (listPersonalAccount.isNotEmpty) {
        return listPersonalAccount.first;
      }
    }
    throw NotFoundPersonalAccountException();
  }

  AccountId get accountId => personalAccount.accountId;

  ({
    bool isAvailable,
    CalendarEventCapability? calendarEventCapability
  }) validateCalendarEventCapability(AccountId accountId) {
    final capability = getCapabilityProperties<CalendarEventCapability>(
      accountId,
      CapabilityIdentifier.jamesCalendarEvent);
    
    return (isAvailable: capability != null, calendarEventCapability: capability);
  }

  bool validateAcceptCounterCalendarEventCapability(AccountId accountId) {
    final capability = getCapabilityProperties<CalendarEventCapability>(
      accountId,
      CapabilityIdentifier.jamesCalendarEvent);

    return capability?.counterSupport == true;
  }

  String? getLanguageForCalendarEvent(
    Locale locale,
    AccountId accountId,
  ) {
    final validation = validateCalendarEventCapability(accountId);
    if (!validation.isAvailable) return null;

    final supportedLanguages = validation.calendarEventCapability!.replySupportedLanguage;
    if (supportedLanguages == null) return null;

    final currentLanguage = locale.languageCode;
    if (supportedLanguages.contains(currentLanguage)) {
      return currentLanguage;
    } else if (supportedLanguages.contains('en')) {
      return 'en';
    } else {
      return supportedLanguages.firstOrNull;
    }
  }
}