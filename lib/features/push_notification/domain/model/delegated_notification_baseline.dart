import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;

/// The Email state a delegated mailbox notifies from, so the first push lists only new emails.
class DelegatedNotificationBaseline with EquatableMixin {
  final AccountId accountId;

  /// Null keeps the cursor already stored, which the pushes may have moved past the server state.
  final jmap.State? state;
  final String ownerName;

  const DelegatedNotificationBaseline({
    required this.accountId,
    this.state,
    required this.ownerName,
  });

  @override
  List<Object?> get props => [accountId, state, ownerName];
}
