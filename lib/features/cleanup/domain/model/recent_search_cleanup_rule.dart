
import 'package:tmail_ui_user/features/cleanup/domain/model/cleanup_rule.dart';

class RecentSearchCleanupRule extends CleanupRule {
  final int storageLimit;

  RecentSearchCleanupRule(
      {this.storageLimit = 10}
  ) : super();

  @override
  List<Object?> get props => [storageLimit];
}