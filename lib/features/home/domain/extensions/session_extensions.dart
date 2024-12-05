
import 'dart:convert';

import 'package:contact/contact/model/autocomplete_capability.dart';
import 'package:contact/contact/model/capability_contact.dart';
import 'package:core/presentation/extensions/uri_extension.dart';
import 'package:core/utils/app_logger.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/http/converter/state_converter.dart';
import 'package:jmap_dart_client/http/converter/user_name_converter.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/home/data/model/session_hive_obj.dart';
import 'package:tmail_ui_user/features/home/domain/converter/session_account_converter.dart';
import 'package:tmail_ui_user/features/home/domain/converter/session_capabilities_converter.dart';
import 'package:tmail_ui_user/features/home/domain/converter/session_primary_account_converter.dart';

extension SessionExtensions on Session {
  static final CapabilityIdentifier linagoraContactSupportCapability = CapabilityIdentifier(Uri.parse('com:linagora:params:jmap:contact:support'));

  Map<String, dynamic> toJson() {
    final val = <String, dynamic>{};

    void writeNotNull(String key, dynamic value) {
      if (value != null) {
        val[key] = value;
      }
    }

    writeNotNull('capabilities', capabilities.map((key, value) =>  SessionCapabilitiesConverter().convertToMapEntry(key, value)));
    writeNotNull('accounts', accounts.map((key, value) => SessionAccountConverter().convertToMapEntry(key, value)));
    writeNotNull('primaryAccounts', primaryAccounts.map((key, value) => SessionPrimaryAccountConverter().convertToMapEntry(key, value)));
    writeNotNull('username', const UserNameConverter().toJson(username));
    writeNotNull('apiUrl', apiUrl.toString());
    writeNotNull('downloadUrl', downloadUrl.toString());
    writeNotNull('uploadUrl', uploadUrl.toString());
    writeNotNull('eventSourceUrl', eventSourceUrl.toString());
    writeNotNull('state', const StateConverter().toJson(state));

    return val;
  }

  SessionHiveObj toHiveObj() => SessionHiveObj(value: jsonEncode(toJson()));

  String getQualifiedApiUrl({String? baseUrl}) {
    if (baseUrl != null) {
      return apiUrl.toQualifiedUrl(baseUrl: Uri.parse(baseUrl)).toString();
    } else {
      return apiUrl.toString();
    }
  }

  String get internalDomain {
    try {
      if (GetUtils.isEmail(username.value)) {
        return username.value.split('@').last;
      } else if (GetUtils.isEmail(personalAccount.name.value)) {
        return personalAccount.name.value.split('@').last;
      } else {
        return '';
      }
    } catch (e) {
      logError('SessionExtensions::internalDomain: Exception: $e');
      return '';
    }
  }

  UnsignedInt? getMinInputLengthAutocomplete(AccountId accountId) {
    try {
      final autocompleteCapability = getCapabilityProperties<AutocompleteCapability>(
        accountId,
        tmailContactCapabilityIdentifier);
      final minInputLength = autocompleteCapability?.minInputLength;
      log('SessionExtensions::getMinInputLengthAutocomplete:minInputLength = $minInputLength');
      return minInputLength;
    } catch (e) {
      logError('SessionExtensions::getMinInputLengthAutocomplete():[Exception] $e');
      return null;
    }
  }

  ContactSupportCapability? getContactSupportCapability(AccountId accountId) {
    try {
      final contactSupportCapability = getCapabilityProperties<ContactSupportCapability>(
        accountId,
        linagoraContactSupportCapability,
      );
      log('SessionExtensions::getContactSupportCapability:contactSupportCapability = $contactSupportCapability');
      return contactSupportCapability;
    } catch (e) {
      logError('SessionExtensions::getContactSupportCapability():[Exception] $e');
      return null;
    }
  }
}