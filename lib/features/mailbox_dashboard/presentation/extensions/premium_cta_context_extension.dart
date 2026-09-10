import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/paywall/presentation/providers/premium_cta_provider.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';

extension PremiumCtaContextExtension on MailboxDashBoardController {
  PremiumCtaContext? get currentPremiumCtaContext => _buildPremiumCtaContext(
        session: sessionCurrent,
        accountId: accountId.value,
        ownerEmail: ownEmailAddress.value,
        jmapUrl: dynamicUrlInterceptors.jmapUrl,
      );
}

extension ManageAccountPremiumCtaContextExtension
    on ManageAccountDashBoardController {
  PremiumCtaContext? get currentPremiumCtaContext => _buildPremiumCtaContext(
        session: sessionCurrent,
        accountId: accountId.value,
        ownerEmail: ownEmailAddress.value,
        jmapUrl: dynamicUrlInterceptors.jmapUrl,
      );
}

PremiumCtaContext? _buildPremiumCtaContext({
  required Session? session,
  required AccountId? accountId,
  required String ownerEmail,
  required String? jmapUrl,
}) =>
    PremiumCtaContext.tryCreate(
      session: session,
      accountId: accountId,
      owner: PremiumCtaOwner(
        email: ownerEmail,
        domainName: RouteUtils.getRootDomain(),
      ),
      jmapUrl: jmapUrl,
    );
