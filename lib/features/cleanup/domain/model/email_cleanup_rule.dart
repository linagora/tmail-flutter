
import 'package:tmail_ui_user/features/cleanup/domain/model/cleanup_rule.dart';

class EmailCleanupRule extends CleanupRule {
  final Duration cachingEmailPeriod;

  EmailCleanupRule(this.cachingEmailPeriod) : super();

  @override
  List<Object?> get props => [cachingEmailPeriod];
}