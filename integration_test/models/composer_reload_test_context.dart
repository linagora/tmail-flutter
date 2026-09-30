import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';

class ComposerReloadTestContext {
  final MailboxDashBoardController dashboard;
  final ComposerController originalController;
  final Session session;
  final AccountId accountId;
  final String composerId;
  final String cacheKey;

  const ComposerReloadTestContext({
    required this.dashboard,
    required this.originalController,
    required this.session,
    required this.accountId,
    required this.composerId,
    required this.cacheKey,
  });
}
