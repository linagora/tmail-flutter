import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';

class SessionMissingCapability extends Equatable implements Exception {
  final Set<CapabilityIdentifier> capabilityIdentifiers;

  SessionMissingCapability(this.capabilityIdentifiers);

  @override
  List<Object?> get props => [capabilityIdentifiers];
}