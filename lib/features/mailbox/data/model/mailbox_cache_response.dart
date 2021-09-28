
import 'package:equatable/equatable.dart';
import 'package:model/model.dart';

class MailboxCacheResponse with EquatableMixin {
  final List<MailboxCache>? mailboxCaches;
  final StateDao? oldState;

  MailboxCacheResponse({
    this.mailboxCaches,
    this.oldState
  });

  @override
  List<Object?> get props => [mailboxCaches, oldState];
}