
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';

class FirebaseCapability extends CapabilityIdentifier {
  static final identifier = FirebaseCapability(Uri.parse('com:linagora:params:jmap:firebase:push'));

  FirebaseCapability(super.value);
}