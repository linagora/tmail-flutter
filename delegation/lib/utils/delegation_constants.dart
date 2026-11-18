import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';

class DelegationConstants {
  DelegationConstants._();

  static final CapabilityIdentifier delegationCapability =
      CapabilityIdentifier(Uri.parse('urn:apache:james:params:jmap:delegation'));
}
