
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';

class MailboxChangeResponse with EquatableMixin {
  final List<Mailbox>? updated;
  final List<Mailbox>? created;
  final List<MailboxId>? destroyed;
  final State? newState;
  final Properties? updatedProperties;

  MailboxChangeResponse({
    this.updated,
    this.created,
    this.destroyed,
    this.newState,
    this.updatedProperties,
  });

  @override
  List<Object?> get props => [updated, created, destroyed, newState, updatedProperties];
}