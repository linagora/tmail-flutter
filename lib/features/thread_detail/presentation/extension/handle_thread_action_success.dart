import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:model/email/mark_star_action.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_as_star_multiple_email_state.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/extensions/list_email_in_thread_detail_info_extension.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/extensions/presentation_email_map_extension.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';

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

  void _handleMarkAll(MarkStarAction action) {
    final currentEmailIdsPresentation = emailIdsPresentation;
    emailIdsPresentation.value =
        currentEmailIdsPresentation.toggleEmailKeywords(
      keyword: KeyWordIdentifier.emailFlagged,
      isRemoved: action == MarkStarAction.unMarkStar,
    );

    final currentEmailsInThreadDetailInfo = emailsInThreadDetailInfo;
    log('$runtimeType::_handleMarkAll: currentEmailsInThreadDetailInfo = ${currentEmailsInThreadDetailInfo.length}');
    emailsInThreadDetailInfo.value =
        currentEmailsInThreadDetailInfo.toggleEmailKeywords(
      keyword: KeyWordIdentifier.emailFlagged,
      isRemoved: action == MarkStarAction.unMarkStar,
    );
  }

  void _handleMarkPartial(
    MarkStarAction action,
    List<EmailId> successEmailIds,
  ) {
    final currentEmailIdsPresentation = emailIdsPresentation;
    emailIdsPresentation.value =
        currentEmailIdsPresentation.toggleEmailKeywordByIds(
      ids: successEmailIds,
      keyword: KeyWordIdentifier.emailFlagged,
      isRemoved: action == MarkStarAction.unMarkStar,
    );

    final currentEmailsInThreadDetailInfo = emailsInThreadDetailInfo;
    log('$runtimeType::_handleMarkPartial: currentEmailsInThreadDetailInfo = ${currentEmailsInThreadDetailInfo.length}');
    emailsInThreadDetailInfo.value =
        currentEmailsInThreadDetailInfo.toggleEmailKeywordByIds(
      targetIds: successEmailIds,
      keyword: KeyWordIdentifier.emailFlagged,
      isRemoved: action == MarkStarAction.unMarkStar,
    );
  }
}
