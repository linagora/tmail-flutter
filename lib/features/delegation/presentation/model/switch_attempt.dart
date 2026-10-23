import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';

/// One try to change the shown account. Going back after a failed try is a new attempt.
class SwitchAttempt with EquatableMixin {
  final int id;
  final AccountId from;
  final AccountId to;

  const SwitchAttempt({required this.id, required this.from, required this.to});

  @override
  List<Object?> get props => [id, from, to];
}
