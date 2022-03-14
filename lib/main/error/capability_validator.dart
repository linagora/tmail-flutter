import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/main/error/request_error.dart';

void requireCapability(Session session, List<CapabilityIdentifier> requiredCapabilities) {
  final matchedCapabilities = session.capabilities.keys
      .fold<Set<CapabilityIdentifier>>(
        Set<CapabilityIdentifier>(),
        (previousValue, element) {
          if (requiredCapabilities.contains(element)) {
            previousValue.add(element);
          }
          return previousValue;
        }
      );
  final missingCapabilities = requiredCapabilities.toSet().difference(matchedCapabilities);
  if (missingCapabilities.length > 0) {
    throw SessionMissingCapability(missingCapabilities);
  }
}