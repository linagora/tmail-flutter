import 'package:tmail_ui_user/features/cleanup/domain/model/cleanup_rule.dart';

class RecentLoginUsernameCleanupRule extends CleanupRule {
  final int storageLimit;

  RecentLoginUsernameCleanupRule({this.storageLimit = 10}) : super();

  @override
  List<Object?> get props => [storageLimit];
}