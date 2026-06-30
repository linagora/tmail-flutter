import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';

/// JMAP `Email` properties to fetch when resolving an `Email/changes` query:
/// [created] for newly created emails, [updated] for modified ones.
class EmailChangesProperties with EquatableMixin {
  final Properties? created;
  final Properties? updated;

  const EmailChangesProperties({this.created, this.updated});

  @override
  List<Object?> get props => [created, updated];
}
