import 'package:core/core.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_comparator.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_comparator_property.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_filter_condition.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/email/domain/state/mark_as_email_read_state.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/thread/domain/constants/thread_constants.dart';
import 'package:tmail_ui_user/features/thread/domain/state/get_all_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_as_multiple_email_read_state.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/get_emails_in_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/mark_as_multiple_email_read_interactor.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/load_more_state.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/email_context_menu_action_builder.dart';
import 'package:tmail_ui_user/main/actions/app_action.dart';
import 'package:tmail_ui_user/main/actions/email_action.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class ThreadController extends BaseController {

  final mailboxDashBoardController = Get.find<MailboxDashBoardController>();
  final GetEmailsInMailboxInteractor _getEmailsInMailboxInteractor;
  final MarkAsMultipleEmailReadInteractor _markAsMultipleEmailReadInteractor;
  final AppToast _appToast;
  final ResponsiveUtils responsiveUtils;
  final ScrollController listEmailController;

  final _properties = Properties({
    'id', 'subject', 'from', 'to', 'cc', 'bcc', 'keywords', 'receivedAt',
    'sentAt', 'preview', 'hasAttachment', 'replyTo'
  });

  final emailList = <PresentationEmail>[].obs;
  final loadMoreState = LoadMoreState.IDLE.obs;
  final currentSelectMode = SelectMode.INACTIVE.obs;

  int positionCurrent = 0;
  int lastGetTotal = 0;
  MailboxId? _currentMailboxId;

  ThreadController(
    this.responsiveUtils,
    this._getEmailsInMailboxInteractor,
    this.listEmailController,
    this._markAsMultipleEmailReadInteractor,
    this._appToast,
  );

  @override
  void onReady() {
    super.onReady();
    mailboxDashBoardController.selectedMailbox.listen((selectedMailbox) {
      if (_currentMailboxId != selectedMailbox?.id) {
        _currentMailboxId = selectedMailbox?.id;
        refreshGetAllEmailAction();
      } else {
        final actionCurrent = mailboxDashBoardController.mailboxDashBoardAction.value;
        if (actionCurrent is MarkAsEmailReadAction) {
          final emailCurrent = mailboxDashBoardController.selectedEmail.value;
          if (Get.context != null && responsiveUtils.isDesktop(Get.context!) && emailCurrent != null) {
            _updateStateUnReadAllEmail([emailCurrent.id], isUnread: false);
          }
          mailboxDashBoardController.clearMailboxDashBoardAction();
        } else if (actionCurrent is MarkAsMultipleEmailReadAndUnreadAction) {
          _updateStateUnReadAllEmail(actionCurrent.listEmailId, isUnread: actionCurrent.isUnread);
          mailboxDashBoardController.clearMailboxDashBoardAction();
        }
      }
    });
  }

  @override
  void dispose() {
    mailboxDashBoardController.selectedMailbox.close();
    listEmailController.dispose();
    super.dispose();
  }

  @override
  void onData(Either<Failure, Success> newState) {
    super.onData(newState);
  }

  @override
  void onDone() {
    viewState.value.fold(
      (failure) => _resetPositionCurrentAndLoadMoreState(),
      (success) => _updateEmailList(success is GetAllEmailSuccess ? success.emailList : [])
    );
  }

  @override
  void onError(error) {
    _resetPositionCurrentAndLoadMoreState();
  }

  void _updateEmailList(List<PresentationEmail> newListEmail) {
    emailList.value += newListEmail;

    lastGetTotal = emailList.length;

    loadMoreState.value = newListEmail.isEmpty ? LoadMoreState.COMPLETED : LoadMoreState.IDLE;
  }

  EmailFilterCondition? _getFilterConditionCurrent() {
    return EmailFilterCondition(inMailbox: mailboxDashBoardController.selectedMailbox.value?.id);
  }

  Set<Comparator>? _getSortCurrent() {
    return Set()
      ..add(EmailComparator(EmailComparatorProperty.sentAt)
        ..setIsAscending(false));
  }

  void _resetPositionCurrentAndLoadMoreState() {
    if (loadMoreState.value == LoadMoreState.LOADING) {
      positionCurrent -= lastGetTotal;
    }
    loadMoreState.value = LoadMoreState.IDLE;
  }

  void getAllEmailAction(AccountId accountId,
    {
      UnsignedInt? limit,
      int position = 0,
      Set<Comparator>? sort,
      Filter? filter,
      Properties? properties,
    }
  ) async {
    consumeState(_getEmailsInMailboxInteractor.execute(
      accountId,
      limit: limit,
      position: position,
      sort: sort,
      filter: filter,
      properties: properties
    ));
  }

  void refreshGetAllEmailAction() {
    loadMoreState.value = LoadMoreState.IDLE;
    positionCurrent = 0;
    emailList.clear();

    final accountId = mailboxDashBoardController.accountId.value;

    if (accountId != null) {
      getAllEmailAction(
        accountId,
        limit: ThreadConstants.defaultLimit,
        position: positionCurrent,
        sort: _getSortCurrent(),
        properties: _properties,
        filter: _getFilterConditionCurrent());
    }
  }

  void loadMoreEmailAction() {
    loadMoreState.value = LoadMoreState.LOADING;
    positionCurrent += lastGetTotal;

    final accountId = mailboxDashBoardController.accountId.value;

    if (accountId != null) {
      Future.delayed(const Duration(milliseconds: 100), () {
        getAllEmailAction(
          accountId,
          limit: ThreadConstants.defaultLimit,
          position: positionCurrent,
          sort: _getSortCurrent(),
          properties: _properties,
          filter: _getFilterConditionCurrent());
      });
    }
  }

  SelectMode getSelectMode(PresentationEmail presentationEmail, PresentationEmail? selectedEmail) {
    return presentationEmail.id == selectedEmail?.id
      ? SelectMode.ACTIVE
      : SelectMode.INACTIVE;
  }

  void previewEmail(BuildContext context, PresentationEmail presentationEmailSelected) {
    mailboxDashBoardController.setSelectedEmail(presentationEmailSelected);
    if (!responsiveUtils.isDesktop(context)) {
      goToEmail(context);
    }
  }

  void selectEmail(BuildContext context, PresentationEmail presentationEmailSelected) {
    emailList.value = emailList.map((email) => email.id == presentationEmailSelected.id ? email.toggleSelect() : email).toList();
    if (_isUnSelectedAll()) {
      currentSelectMode.value = SelectMode.INACTIVE;
    } else {
      if (currentSelectMode.value == SelectMode.INACTIVE) {
        currentSelectMode.value = SelectMode.ACTIVE;
      }
    }
  }

  List<PresentationEmail> getListEmailSelected() => emailList.where((email) => email.selectMode == SelectMode.ACTIVE).toList();

  bool _isUnSelectedAll() => emailList.every((email) => email.selectMode == SelectMode.INACTIVE);

  bool _isEmailAllRead(List<PresentationEmail> listEmail) => listEmail.every((email) => email.isReadEmail());

  void cancelSelectEmail() {
    emailList.value = emailList.map((email) => email.toSelectedEmail(selectMode: SelectMode.INACTIVE)).toList();
    currentSelectMode.value = SelectMode.INACTIVE;
  }

  void _updateStateUnReadAllEmail(List<EmailId> list, {required bool isUnread}) {
      final newEmailList = emailList
        .map((email) => list.contains(email.id) ? email.markAsReadPresentationEmail(isUnread: isUnread) : email)
        .toList();
      emailList.value = newEmailList;
  }

  void unreadSelectedEmail(List<PresentationEmail> listEmail, {bool fromContextMenuAction = false}) {
    if (fromContextMenuAction) {
      popBack();
    }

    final isUnread = _isEmailAllRead(listEmail);

    final listEmailId = listEmail
        .where((email) => isUnread ? email.isReadEmail() : email.isUnReadEmail())
        .map((email) => email.id)
        .toList();

    final accountId = mailboxDashBoardController.accountId.value;
    final mailboxCurrent = mailboxDashBoardController.selectedMailbox.value;

    if (accountId != null && mailboxCurrent != null) {
      _markAsMultipleEmailReadInteractor
        .execute(accountId, listEmailId, isUnread)
        .then((result) => result.fold(
            (failure) {
              cancelSelectEmail();

              if (failure is MarkAsEmailReadFailure
                  || failure is MarkAsMultipleEmailReadAllFailure
                  || failure is MarkAsMultipleEmailReadFailure) {
                _appToast.showErrorToast(AppLocalizations.of(Get.context!).an_error_occurred);
              }
            },
            (success) {
              cancelSelectEmail();
              final listEmailIdSuccess = _getListEmailIdMarkedAsReadSuccess(success);

              if (success is MarkAsEmailReadSuccess
                  || success is MarkAsMultipleEmailReadAllSuccess
                  || success is MarkAsMultipleEmailReadHasSomeEmailFailure) {
                if (Get.context != null) {
                  _appToast.showSuccessToast(isUnread
                      ? AppLocalizations.of(Get.context!).marked_multiple_item_as_unread(listEmail.length)
                      : AppLocalizations.of(Get.context!).marked_multiple_item_as_read(listEmail.length));
                }

                if (listEmailIdSuccess.isNotEmpty) {
                  _updateStateEmailAndCountUnReadMailbox(MarkAsMultipleEmailReadAndUnreadAction(listEmailIdSuccess, mailboxCurrent, isUnread));
                }
              }
            }));
    }
  }

  List<EmailId> _getListEmailIdMarkedAsReadSuccess(Success success) {
    final listEmailIdSuccess = <EmailId>[];

    if (success is MarkAsEmailReadSuccess) {
      listEmailIdSuccess.add(success.emailId);
    } else if (success is MarkAsMultipleEmailReadAllSuccess) {
      success.resultList.forEach((either) {
        either.map((success) {
          if (success is MarkAsEmailReadSuccess) {
            listEmailIdSuccess.add(success.emailId);
          }
        });
      });
    } else if (success is MarkAsMultipleEmailReadHasSomeEmailFailure) {
      success.resultList.forEach((either) {
        either.map((success) {
          if (success is MarkAsEmailReadSuccess) {
            listEmailIdSuccess.add(success.emailId);
          }
        });
      });
    }

    return listEmailIdSuccess;
  }

  void _updateStateEmailAndCountUnReadMailbox(AppAction? appAction) {
    mailboxDashBoardController.setMailboxDashBoardAction(appAction);
  }

  void openContextMenuSelectedEmail(BuildContext context, ImagePaths imagePaths, List<PresentationEmail> listEmail) {
      (ContextMenuBuilder(context)
        ..addTiles(_contextMenuActionList(context, imagePaths, listEmail)))
    .build();
  }

  List<Widget> _contextMenuActionList(BuildContext context, ImagePaths imagePaths, List<PresentationEmail> listEmail) {
    return [
      _moveToTrashAction(context, imagePaths, listEmail),
      _moveToMailboxAction(context, imagePaths, listEmail),
      _markAsSeenAction(context, imagePaths, listEmail),
      _markAsFlagAction(context, imagePaths, listEmail),
      _moveToSpamAction(context, imagePaths, listEmail),
      SizedBox(height: 40),
    ];
  }

  Widget _markAsSeenAction(BuildContext context, ImagePaths imagePaths, List<PresentationEmail> listEmail) {
    return (EmailContextMenuActionBuilder(
              Key('mark_as_seen_context_menu_action'),
              SvgPicture.asset(imagePaths.icEyeDisable, width: 24, height: 24, fit: BoxFit.fill),
              _isEmailAllRead(listEmail) ? AppLocalizations.of(context).mark_as_unread : AppLocalizations.of(context).mark_as_read,
              listEmail)
          ..onActionClick((data) => unreadSelectedEmail(data, fromContextMenuAction: true)))
        .build();
  }

  Widget _moveToTrashAction(BuildContext context, ImagePaths imagePaths, List<PresentationEmail> listEmail) {
    return (EmailContextMenuActionBuilder(
              Key('move_to_trash_context_menu_action'),
              SvgPicture.asset(imagePaths.icTrash, width: 24, height: 24, fit: BoxFit.fill),
              AppLocalizations.of(context).move_to_trash, listEmail)
          ..onActionClick((data) => {}))
        .build();
  }

  Widget _moveToMailboxAction(BuildContext context, ImagePaths imagePaths, List<PresentationEmail> listEmail) {
    return (EmailContextMenuActionBuilder(
              Key('move_to_mailbox_context_menu_action'),
              SvgPicture.asset(imagePaths.icFolder, width: 24, height: 24, fit: BoxFit.fill),
              AppLocalizations.of(context).move_to_mailbox, listEmail)
          ..onActionClick((data) => {}))
        .build();
  }

  Widget _markAsFlagAction(BuildContext context, ImagePaths imagePaths, List<PresentationEmail> listEmail) {
    return (EmailContextMenuActionBuilder(
              Key('mark_as_flag_context_menu_action'),
              SvgPicture.asset(imagePaths.icFlag, width: 24, height: 24, fit: BoxFit.fill),
              AppLocalizations.of(context).mark_as_flag, listEmail)
          ..onActionClick((data) => {}))
        .build();
  }

  Widget _moveToSpamAction(BuildContext context, ImagePaths imagePaths, List<PresentationEmail> listEmail) {
    return (EmailContextMenuActionBuilder(
              Key('move_to_spam_context_menu_action'),
              SvgPicture.asset(imagePaths.icMailboxSpam, width: 24, height: 24, fit: BoxFit.fill),
              AppLocalizations.of(context).move_to_spam, listEmail)
          ..onActionClick((data) => {}))
        .build();
  }

  bool canComposeEmail() => mailboxDashBoardController.sessionCurrent != null
      && mailboxDashBoardController.userProfile.value != null
      && mailboxDashBoardController.mapMailboxId.containsKey(PresentationMailbox.roleOutbox);

  void openMailboxLeftMenu() {
    mailboxDashBoardController.openDrawer();
  }

  void goToEmail(BuildContext context) async {
    final action = await push(AppRoutes.EMAIL);
    if (action is MarkAsEmailReadAction) {
      _updateStateUnReadAllEmail([action.emailId], isUnread: false);
      mailboxDashBoardController.setMailboxDashBoardAction(action);
    }
    mailboxDashBoardController.clearSelectedEmail();
  }

  void composeEmailAction() {
    if (canComposeEmail()) {
      Get.toNamed(
        AppRoutes.COMPOSER,
        arguments: ComposerArguments(
          session: mailboxDashBoardController.sessionCurrent!,
          userProfile: mailboxDashBoardController.userProfile.value!,
          mapMailboxId: mailboxDashBoardController.mapMailboxId));
    }
  }
}