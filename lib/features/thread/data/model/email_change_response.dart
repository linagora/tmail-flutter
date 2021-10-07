
import 'package:model/model.dart';
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';

class EmailChangeResponse with EquatableMixin {
  final List<Email>? updated;
  final List<Email>? created;
  final List<EmailId>? destroyed;
  final State? newStateEmail;
  final State? newStateChanges;
  final bool hasMoreChanges;
  final Properties? updatedProperties;

  EmailChangeResponse({
    this.updated,
    this.created,
    this.destroyed,
    this.newStateEmail,
    this.newStateChanges,
    this.hasMoreChanges = false,
    this.updatedProperties,
  });

  EmailChangeResponse union(EmailChangeResponse other) => EmailChangeResponse(
    updated: updated.unite(other.updated),
    created: created.unite(other.created),
    destroyed: destroyed.unite(other.destroyed),
    newStateEmail: other.newStateEmail,
    newStateChanges: other.newStateChanges,
    hasMoreChanges: other.hasMoreChanges,
    updatedProperties: other.updatedProperties,
  );

  @override
  List<Object?> get props => [
    updated,
    created,
    destroyed,
    newStateEmail,
    newStateChanges,
    hasMoreChanges,
    updatedProperties
  ];
}