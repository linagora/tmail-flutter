
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/screen_display_mode.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/local_email_draft.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_all_local_email_draft_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/local_email_draft_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/open_and_close_composer_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/presentation_local_email_draft.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/local_email_draft/local_email_draft_list_dialog_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension RestoreLocalEmailDraftExtension on MailboxDashBoardController {

  void restoreLocalEmailDraft() {
    final getAllLocalEmailDraftInteractor = getBinding<GetAllLocalEmailDraftInteractor>();

    if (accountId.value == null ||
        sessionCurrent == null ||
        getAllLocalEmailDraftInteractor == null) {
      return;
    }

    consumeState(getAllLocalEmailDraftInteractor.execute(
      accountId.value!,
      sessionCurrent!.username,
    ));
  }

  void handlerGetAllLocalEmailDraft(List<LocalEmailDraft> localEmailDrafts) {
    final listPresentationLocalEmailDraft = localEmailDrafts
      .map((localEmailDraft) => localEmailDraft.toPresentation())
      .toList();

    final listLocalEmailDraftSortByTime = listPresentationLocalEmailDraft
      ..sort((a, b) => b.savedTime.compareTo(a.savedTime));

    showLocalEmailDraftListDialog(listLocalEmailDraftSortByTime);
  }

  void showLocalEmailDraftListDialog(List<PresentationLocalEmailDraft> presentationLocalEmailDrafts) {
    Get.dialog(
      PointerInterceptor(
        child: LocalEmailDraftListDialogBuilder(
          accountId: accountId.value,
          session: sessionCurrent,
          ownEmailAddress: ownEmailAddress.value,
          presentationLocalEmailDrafts: presentationLocalEmailDrafts,
          onEditLocalEmailDraftAction: _editLocalEmailDraft,
          onRestoreAllLocalEmailDraftsAction: _restoreAllLocalEmailDrafts,
        ),
      ),
      barrierColor: AppColor.colorDefaultCupertinoActionSheet,
    );
  }

  void _editLocalEmailDraft(PresentationLocalEmailDraft draftLocal) {
    popBack();
    openComposer(ComposerArguments.fromLocalEmailDraft(
      draftLocal.copyWith(displayMode: ScreenDisplayMode.normal),
    ));
  }

  void _restoreAllLocalEmailDrafts(List<PresentationLocalEmailDraft> localDrafts) {
    popBack();


    final listLocalEmailDraftSortByIndex = localDrafts
      ..sort((a, b) => (a.composerIndex ?? 0).compareTo(b.composerIndex ?? 0));

    final listComposerArguments = listLocalEmailDraftSortByIndex
      .map(ComposerArguments.fromLocalEmailDraft)
      .toList();

    openListComposer(listComposerArguments);

    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastSuccessMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).restoreAllLocalDraftsSuccessfully,
      );
    }
  }
}