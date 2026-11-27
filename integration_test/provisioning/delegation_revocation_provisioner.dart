import 'package:delegation/model/delegated_account.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/delegation/domain/state/get_delegated_accounts_state.dart';
import 'package:tmail_ui_user/features/delegation/domain/state/remove_delegated_account_state.dart';
import 'package:tmail_ui_user/features/delegation/presentation/providers/delegated_account_providers.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/main/providers/app_provider_container.dart';

/// Ends a delegation on the server behind the app's back, so the session the app holds still lists it.
class DelegationRevocationProvisioner {
  const DelegationRevocationProvisioner();

  Future<void> revoke(String ownerAddress) async {
    final session = Get.find<MailboxDashBoardController>().sessionCurrent ??
        (throw StateError('revoke: session is null'));
    final delegations = await _delegationsOf(session);
    final delegation = delegations.where((account) => account.username == ownerAddress).firstOrNull ??
        (throw StateError('revoke: no delegation from $ownerAddress'));

    final removal = await appProviderContainer
        .read(removeDelegatedAccountInteractorProvider)
        .execute(session, delegation)
        .last;
    if (removal.fold((_) => true, (success) => success is! RemoveDelegatedAccountSuccess)) {
      throw StateError('revoke: removal of the delegation from $ownerAddress failed');
    }
  }

  Future<List<DelegatedAccount>> _delegationsOf(Session session) async {
    final load = await appProviderContainer.read(getDelegatedAccountsInteractorProvider).execute(session).last;
    final success = load.fold((_) => null, (success) => success);
    if (success is! GetDelegatedAccountsSuccess) {
      throw StateError('revoke: the delegations could not be read');
    }
    return success.delegatedAccounts;
  }
}
