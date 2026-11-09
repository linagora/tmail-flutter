import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';

class CleanupEndedDelegationsSuccess extends UIState {
  final List<AccountId> deletedAccountIds;
  final int lostCount;

  CleanupEndedDelegationsSuccess({
    required this.deletedAccountIds,
    required this.lostCount,
  });

  @override
  List<Object?> get props => [deletedAccountIds, lostCount];
}

class CleanupEndedDelegationsFailure extends FeatureFailure {
  CleanupEndedDelegationsFailure(dynamic exception) : super(exception: exception);
}
