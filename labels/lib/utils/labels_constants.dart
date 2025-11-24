import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';

class LabelsConstants {
  LabelsConstants._();

  static final CapabilityIdentifier labelsCapability =
      CapabilityIdentifier(Uri.parse('com:linagora:params:jmap:labels'));
}
