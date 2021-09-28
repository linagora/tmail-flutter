
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';

class MailboxChangeResponse with EquatableMixin {
  final List<Mailbox>? updated;
  final List<Mailbox>? created;
  final List<MailboxId>? destroyed;
  final State? newStateMailbox;
  final State? newStateChanges;
  final bool hasMoreChanges;
  final Properties? updatedProperties;

  MailboxChangeResponse({
    this.updated,
    this.created,
    this.destroyed,
    this.newStateMailbox,
    this.newStateChanges,
    this.hasMoreChanges = false,
    this.updatedProperties,
  });

  @override
  List<Object?> get props => [
    updated,
    created,
    destroyed,
    newStateMailbox,
    newStateChanges,
    hasMoreChanges,
    updatedProperties
  ];
}