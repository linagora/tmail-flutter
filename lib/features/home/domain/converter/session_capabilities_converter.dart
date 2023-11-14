import 'package:jmap_dart_client/http/converter/capability_identifier_converter.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_properties.dart';
import 'package:tmail_ui_user/features/home/domain/converter/capability_properties_converter.dart';

class SessionCapabilitiesConverter {

  MapEntry<String, dynamic> convertToMapEntry(CapabilityIdentifier identifier, CapabilityProperties properties) {
    return MapEntry(
      const CapabilityIdentifierConverter().toJson(identifier),
      CapabilityPropertiesConverter().toJson(properties)
    );
  }
}