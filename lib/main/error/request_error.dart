import 'package:core/domain/exceptions/app_base_exception.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';

class InvalidCapability extends AppBaseException {
  const InvalidCapability([super.message]);

  @override
  String get exceptionName => 'InvalidCapability';
}

class SessionMissingCapability extends InvalidCapability {
  final Set<CapabilityIdentifier> capabilityIdentifiers;

  SessionMissingCapability(this.capabilityIdentifiers)
      : super('Missing capabilities $capabilityIdentifiers');

  @override
  String get exceptionName => 'SessionMissingCapability';

  @override
  List<Object?> get props => [capabilityIdentifiers];
}
