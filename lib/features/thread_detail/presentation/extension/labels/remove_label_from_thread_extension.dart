import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:labels/labels.dart';
import 'package:tmail_ui_user/features/email/domain/state/labels/remove_a_label_from_an_thread_state.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/features/labels/domain/exceptions/label_exceptions.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/labels/add_label_to_thread_extension.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';

extension RemoveLabelFromThreadExtension on ThreadDetailController {
  void removeALabelFromAThread({
    required Session? session,
    required AccountId? accountId,
    required Label label,
    required List<EmailId> emailIds,
  }) {
    final labelDisplay = label.safeDisplayName;

    if (session == null) {
      emitFailure(
        controller: this,
        failure: RemoveALabelFromAThreadFailure(
          exception: NotFoundSessionException(),
          labelDisplay: labelDisplay,
        ),
      );
      return;
    }

    if (accountId == null) {
      emitFailure(
        controller: this,
        failure: RemoveALabelFromAThreadFailure(
          exception: NotFoundAccountIdException(),
          labelDisplay: labelDisplay,
        ),
      );
      return;
    }

    final labelKeyword = label.keyword;
    if (labelKeyword == null) {
      emitFailure(
        controller: this,
        failure: RemoveALabelFromAThreadFailure(
          exception: LabelKeywordIsNull(),
          labelDisplay: labelDisplay,
        ),
      );
      return;
    }

    consumeState(removeALabelFromAThreadInteractor.execute(
      session,
      accountId,
      emailIds,
      labelKeyword,
      label.safeDisplayName,
    ));
  }

  void handleRemoveLabelFromThreadSuccess(
    RemoveALabelFromAThreadSuccess success,
  ) {
    toastManager.showMessageSuccess(success);

    autoSyncLabelToThreadOnMemory(
      emailIds: success.emailIds,
      labelKeyword: success.labelKeyword,
      remove: true,
    );
  }

  void handleRemoveLabelFromThreadFailure(
    RemoveALabelFromAThreadFailure failure,
  ) {
    toastManager.showMessageFailure(failure);
  }
}
