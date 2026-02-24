import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:core/domain/exceptions/app_base_exception.dart';

class InvalidCapability extends AppBaseException with EquatableMixin {
  const InvalidCapability([super.message]);

  @override
  String get exceptionName => 'InvalidCapability';

  @override
  List<Object?> get props => [message];
}

class SessionMissingCapability extends InvalidCapability {
  final Set<CapabilityIdentifier> capabilityIdentifiers;

  const SessionMissingCapability(this.capabilityIdentifiers)
      : super('Missing capabilities $capabilityIdentifiers');

  @override
  String get exceptionName => 'SessionMissingCapability';

  @override
  List<Object?> get props => [capabilityIdentifiers, ...super.props];
}
