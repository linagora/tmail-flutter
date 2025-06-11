
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/cleanup/domain/model/cleanup_rule.dart';

class RecentSearchCleanupRule extends CleanupRule {
  final int storageLimit;
  final AccountId accountId;
  final UserName userName;

  RecentSearchCleanupRule(
    this.accountId,
    this.userName,
    {this.storageLimit = 10}
  ) : super();

  @override
  List<Object?> get props => [accountId, userName, storageLimit];
}