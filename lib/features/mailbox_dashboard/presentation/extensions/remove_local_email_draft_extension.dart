
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/extensions/account_id_extensions.dart';
import 'package:tmail_ui_user/features/caching/utils/cache_utils.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';

extension RemoveLocalEmailDraftExtension on MailboxDashBoardController {

  Future<void> removeLocalEmailDraft(String composerId) async {
    if (accountId.value == null ||
        sessionCurrent == null ||
        removeLocalEmailDraftInteractor == null) {
      return;
    }

    final draftLocalId = _generateDraftLocalId(
      composerId: composerId,
      accountId: accountId.value!,
      userName: sessionCurrent!.username,
    );

    await removeLocalEmailDraftInteractor!.execute(draftLocalId);
  }

  String _generateDraftLocalId({
    required String composerId,
    required AccountId accountId,
    required UserName userName,
  }) {
    return TupleKey(
      composerId,
      accountId.asString,
      userName.value,
    ).encodeKey;
  }
}