
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/local_email_draft.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/local_email_draft_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/presentation_local_email_draft.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/local_email_draft/local_email_draft_list_dialog_builder.dart';

extension RestoreLocalEmailDraftExtension on MailboxDashBoardController {

  void restoreLocalEmailDraft(List<LocalEmailDraft> localEmailDrafts) {
    final listPresentationLocalEmailDraft = localEmailDrafts
      .map((localEmailDraft) => localEmailDraft.toPresentation())
      .toList();
    final listLocalEmailDraftSortByIndex = listPresentationLocalEmailDraft
      ..sort((a, b) => (a.composerIndex ?? 0).compareTo(b.composerIndex ?? 0));

    showLocalEmailDraftListDialog(listLocalEmailDraftSortByIndex);
  }

  void showLocalEmailDraftListDialog(List<PresentationLocalEmailDraft> presentationLocalEmailDrafts) {
    Get.dialog(
      PointerInterceptor(
        child: LocalEmailDraftListDialogBuilder(
          presentationLocalEmailDrafts: presentationLocalEmailDrafts,
        ),
      ),
      barrierColor: AppColor.colorDefaultCupertinoActionSheet,
    );
  }
}