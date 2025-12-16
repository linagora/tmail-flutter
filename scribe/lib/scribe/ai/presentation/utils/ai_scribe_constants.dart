import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';

class AiScribeConstants {
  AiScribeConstants._();

  static final CapabilityIdentifier aiCapability =
      CapabilityIdentifier(Uri.parse('com:linagora:params:jmap:aibot'));
}
