import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:model/email/mark_star_action.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_as_star_multiple_email_state.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/extensions/list_email_in_thread_detail_info_extension.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/extensions/presentation_email_map_extension.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/model/email_in_thread_detail_info.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';

typedef OnUpdateMapEmailIds = Map<EmailId, PresentationEmail?> Function(
  Map<EmailId, PresentationEmail?>,
);

typedef OnUpdateListEmailInfo = List<EmailInThreadDetailInfo> Function(
  List<EmailInThreadDetailInfo>,
);

extension HandleThreadActionSuccess on ThreadDetailController {
  void handleMarkThreadAsStarredSuccess(Success success) {
    mailboxDashBoardController.consumeState(Stream.value(Right(success)));

    switch (success) {
      case MarkAsStarMultipleEmailAllSuccess():
        _handleMarkAll(success.markStarAction);
      case MarkAsStarMultipleEmailHasSomeEmailFailure():
        _handleMarkPartial(
          success.markStarAction,
          success.successEmailIds,
        );
      default:
        break;
    }
  }

  void _updateEmailStates({
    required OnUpdateMapEmailIds updateIds,
    required OnUpdateListEmailInfo updateDetails,
  }) {
    emailIdsPresentation.value = updateIds(emailIdsPresentation);
    emailsInThreadDetailInfo.value = updateDetails(emailsInThreadDetailInfo);
  }

  void _handleMarkAll(MarkStarAction action) {
    final remove = action == MarkStarAction.unMarkStar;
    _updateEmailStates(
      updateIds: (current) => current.toggleEmailKeywords(
        keyword: KeyWordIdentifier.emailFlagged,
        remove: remove,
      ),
      updateDetails: (current) => current.toggleEmailKeywords(
        keyword: KeyWordIdentifier.emailFlagged,
        remove: remove,
      ),
    );
  }

  void _handleMarkPartial(
    MarkStarAction action,
    List<EmailId> successEmailIds,
  ) {
    final remove = action == MarkStarAction.unMarkStar;
    _updateEmailStates(
      updateIds: (current) => current.toggleEmailKeywordByIds(
        ids: successEmailIds,
        keyword: KeyWordIdentifier.emailFlagged,
        remove: remove,
      ),
      updateDetails: (current) => current.toggleEmailKeywordByIds(
        targetIds: successEmailIds,
        keyword: KeyWordIdentifier.emailFlagged,
        remove: remove,
      ),
    );
  }
}
