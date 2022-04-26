
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';

class IdentitiesResponse with EquatableMixin {
  final List<Identity>? identities;
  final State? state;

  IdentitiesResponse({
    this.identities,
    this.state
  });

  bool hasData() {
    return identities != null
      && identities!.isNotEmpty
      && state != null;
  }

  @override
  List<Object?> get props => [identities, state];
}