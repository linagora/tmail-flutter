import 'package:core/core.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
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
  void onInit() {
    super.onInit();
    dispatchState(Right(LoadingState()));
  }

  @override
  void onReady() {
    super.onReady();
    mailboxDashBoardController.selectedMailbox.listen((selectedMailbox) {
      if (_currentMailboxId != selectedMailbox?.id) {
        _currentMailboxId = selectedMailbox?.id;
        refreshGetAllEmailAction();
      } else {
        mailboxDashBoardController.viewState.value.map((success) {
          if (success is MarkAsEmailReadSuccess ||
              success is MarkAsMultipleEmailReadAllSuccess ||
              success is MarkAsMultipleEmailReadHasSomeEmailFailure) {
            _refreshListEmailMarkAsRead();
          }
        });
      }
    });
  }

  @override
  void onClose() {
    mailboxDashBoardController.selectedMailbox.close();
    listEmailController.dispose();
    super.onClose();
  }

  @override
  void onDone() {
    viewState.value.fold(
      (failure) {
        if (failure is GetAllEmailFailure) {
          _resetPositionCurrentAndLoadMoreState();
        } else if (failure is MarkAsEmailReadFailure ||
            failure is MarkAsMultipleEmailReadAllFailure ||
            failure is MarkAsMultipleEmailReadFailure) {
          _markAsSelectedEmailReadFailure(failure);
        }
      },
      (success) {
        if (success is GetAllEmailSuccess) {
          _getAllEmailSuccess(success);
        } else if (success is MarkAsEmailReadSuccess ||
            success is MarkAsMultipleEmailReadAllSuccess ||
            success is MarkAsMultipleEmailReadHasSomeEmailFailure) {
          _markAsSelectedEmailReadSuccess(success);
        }
      }
    );
  }

  @override
  void onError(error) {
  }

  void _getAllEmailSuccess(Success success) {
    if (success is GetAllEmailSuccess) {
      emailList.addAll(success.emailList);
      lastGetTotal = emailList.length;
      loadMoreState.value = success.emailList.isEmpty ? LoadMoreState.COMPLETED : LoadMoreState.IDLE;
    }
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

  void _getAllEmailAction(AccountId accountId,
    {
      UnsignedInt? limit,
      int position = 0,
      Set<Comparator>? sort,
      Filter? filter,
      Properties? properties,
    }
  ) {
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
      _getAllEmailAction(
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
      _getAllEmailAction(
        accountId,
        limit: ThreadConstants.defaultLimit,
        position: positionCurrent,
        sort: _getSortCurrent(),
        properties: _properties,
        filter: _getFilterConditionCurrent());
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

  bool isEmailAllRead(List<PresentationEmail> listEmail) => listEmail.every((email) => email.isReadEmail());

  void cancelSelectEmail() {
    emailList.value = emailList.map((email) => email.toSelectedEmail(selectMode: SelectMode.INACTIVE)).toList();
    currentSelectMode.value = SelectMode.INACTIVE;
  }

  void _refreshListEmailMarkAsRead() {
      final newLimit = emailList.isNotEmpty ? UnsignedInt(emailList.length) : ThreadConstants.defaultLimit;
      loadMoreState.value = LoadMoreState.IDLE;
      emailList.clear();

      final accountId = mailboxDashBoardController.accountId.value;

      if (accountId != null) {
        _getAllEmailAction(
          accountId,
          limit: newLimit,
          position: 0,
          sort: _getSortCurrent(),
          properties: _properties,
          filter: _getFilterConditionCurrent());
      }
  }

  void markAsSelectedEmailRead(List<PresentationEmail> listEmail, {bool fromContextMenuAction = false}) {
    if (fromContextMenuAction) {
      popBack();
    }

    final readAction = isEmailAllRead(listEmail) ? ReadActions.markAsUnread : ReadActions.markAsRead;

    final listEmailId = listEmail
        .where((email) => readAction == ReadActions.markAsUnread ? email.isReadEmail() : email.isUnReadEmail())
        .map((email) => email.id)
        .toList();

    final accountId = mailboxDashBoardController.accountId.value;
    final mailboxCurrent = mailboxDashBoardController.selectedMailbox.value;
    if (accountId != null && mailboxCurrent != null) {
      consumeState(_markAsMultipleEmailReadInteractor.execute(accountId, listEmailId, readAction));
    }
  }

  void _markAsSelectedEmailReadSuccess(Success success) {
    cancelSelectEmail();

    List<EmailId> listEmailId = <EmailId>[];
    ReadActions? readActions;

    if (success is MarkAsEmailReadSuccess) {
      listEmailId.add(success.emailId);
      readActions = success.readActions;
    } else if (success is MarkAsMultipleEmailReadAllSuccess) {
      success.resultList.forEach((either) {
        either.map((success) {
          if (success is MarkAsEmailReadSuccess) {
            listEmailId.add(success.emailId);
          }
        });
      });
      readActions = success.readActions;
    } else if (success is MarkAsMultipleEmailReadHasSomeEmailFailure) {
      success.resultList.forEach((either) {
        either.map((success) {
          if (success is MarkAsEmailReadSuccess) {
            listEmailId.add(success.emailId);
          }
        });
      });
      readActions = success.readActions;
    }

    if (Get.context != null && readActions != null) {
      _appToast.showSuccessToast(readActions == ReadActions.markAsUnread
          ? AppLocalizations.of(Get.context!).marked_multiple_item_as_unread(listEmailId.length)
          : AppLocalizations.of(Get.context!).marked_multiple_item_as_read(listEmailId.length));
    }

    mailboxDashBoardController.dispatchState(Right(success));
  }

  void _markAsSelectedEmailReadFailure(Failure failure) {
    cancelSelectEmail();
    _appToast.showErrorToast(AppLocalizations.of(Get.context!).an_error_occurred);
  }

  void openContextMenuSelectedEmail(BuildContext context, List<Widget> actionTiles) {
      (ContextMenuBuilder(context)
        ..addTiles(actionTiles))
    .build();
  }

  bool canComposeEmail() => mailboxDashBoardController.sessionCurrent != null
      && mailboxDashBoardController.userProfile.value != null
      && mailboxDashBoardController.mapMailboxId.containsKey(PresentationMailbox.roleOutbox);

  void openMailboxLeftMenu() {
    mailboxDashBoardController.openDrawer();
  }

  void goToEmail(BuildContext context) {
    push(AppRoutes.EMAIL);
  }

  void composeEmailAction() {
    if (canComposeEmail()) {
      push(
        AppRoutes.COMPOSER,
        arguments: ComposerArguments(
          session: mailboxDashBoardController.sessionCurrent!,
          userProfile: mailboxDashBoardController.userProfile.value!,
          mapMailboxId: mailboxDashBoardController.mapMailboxId));
    }
  }
}