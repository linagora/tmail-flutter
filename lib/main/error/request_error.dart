import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';

class SessionMissingCapability extends InvalidCapability {
  final Set<CapabilityIdentifier> capabilityIdentifiers;

  const SessionMissingCapability(this.capabilityIdentifiers) : super();

  @override
  List<Object?> get props => [capabilityIdentifiers];
}

class InvalidCapability extends Equatable implements Exception {
  const InvalidCapability();

  @override
  List<Object?> get props => [];
}