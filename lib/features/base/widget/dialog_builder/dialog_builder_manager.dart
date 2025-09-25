import 'package:core/presentation/extensions/color_extension.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/presentation_local_email_draft.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/local_email_draft/local_email_draft_item_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/local_email_draft/local_email_draft_list_dialog_builder.dart';

class DialogBuilderManager {
  static final _instance = DialogBuilderManager._();

  factory DialogBuilderManager() => _instance;

  DialogBuilderManager._();

  final _isOpened = RxBool(false);

  RxBool get isOpened => _isOpened;

  Future<void> showLocalEmailDraftListDialog({
    required List<PresentationLocalEmailDraft> emailDrafts,
    required AccountId? accountId,
    required Session? session,
    required String ownEmailAddress,
    OnEditLocalEmailDraftAction? onEditLocalEmailDraftAction,
    OnRestoreAllLocalEmailDraftsAction? onRestoreAllLocalEmailDraftsAction,
  }) {
    _isOpened.value = true;
    return Get.dialog(
      LocalEmailDraftListDialogBuilder(
        accountId: accountId,
        session: session,
        ownEmailAddress: ownEmailAddress,
        presentationLocalEmailDrafts: emailDrafts,
        onEditLocalEmailDraftAction: onEditLocalEmailDraftAction,
        onRestoreAllLocalEmailDraftsAction: onRestoreAllLocalEmailDraftsAction,
      ),
      barrierColor: AppColor.colorDefaultCupertinoActionSheet,
    ).whenComplete(() => _isOpened.value = false);
  }
}
