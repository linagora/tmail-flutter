import 'package:jmap_dart_client/http/converter/account_id_converter.dart';
import 'package:jmap_dart_client/http/converter/capability_identifier_converter.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';

class SessionPrimaryAccountConverter {

  MapEntry<String, dynamic> convertToMapEntry(CapabilityIdentifier identifier, AccountId accountId) {
    return MapEntry(
      const CapabilityIdentifierConverter().toJson(identifier),
      const AccountIdConverter().toJson(accountId)
    );
  }
}