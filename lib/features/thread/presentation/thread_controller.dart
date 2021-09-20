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
import 'package:tmail_ui_user/features/destination_picker/presentation/model/destination_picker_arguments.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_request.dart';
import 'package:tmail_ui_user/features/email/domain/state/mark_as_email_important_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/mark_as_email_read_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/move_to_mailbox_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_email_important_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/thread/domain/constants/thread_constants.dart';
import 'package:tmail_ui_user/features/thread/domain/state/get_all_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_as_multiple_email_read_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/move_multiple_email_to_mailbox_state.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/get_emails_in_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/mark_as_multiple_email_read_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/move_multiple_email_to_mailbox_interactor.dart';
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
  final MoveMultipleEmailToMailboxInteractor _moveMultipleEmailToMailboxInteractor;
  final MarkAsEmailImportantInteractor _markAsEmailImportantInteractor;

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
    this._moveMultipleEmailToMailboxInteractor,
    this._markAsEmailImportantInteractor,
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
      }
    });

    mailboxDashBoardController.viewState.listen((state) {
      state.map((success) {
        if (success is MarkAsEmailReadSuccess
            || success is MarkAsMultipleEmailReadAllSuccess
            || success is MarkAsMultipleEmailReadHasSomeEmailFailure) {
          _refreshListEmail();
          mailboxDashBoardController.clearState();
        } else if (success is MoveToMailboxSuccess) {
          _refreshListEmail();
          mailboxDashBoardController.clearState();
        }
      });
      } else {
        mailboxDashBoardController.viewState.value.map((success) {
          if (success is MarkAsEmailReadSuccess ||
              success is MarkAsMultipleEmailReadAllSuccess ||
              success is MarkAsMultipleEmailReadHasSomeEmailFailure) {
            _refreshListEmail();
          }
        });
      }
    });

    mailboxDashBoardController.viewState.listen((state) {
      state.map((success) {
        if (success is MarkAsEmailImportantSuccess) {
          _refreshListEmail();
        }
      });
    });
  }

  @override
  void onClose() {
    mailboxDashBoardController.selectedMailbox.close();
    mailboxDashBoardController.viewState.close();
    listEmailController.dispose();
    super.onClose();
  }

  @override
  void onDone() {
    viewState.value.fold(
      (failure) {
        if (failure is GetAllEmailFailure) {
          _resetPositionCurrentAndLoadMoreState();
        } else if (failure is MarkAsMultipleEmailReadAllFailure
            || failure is MarkAsMultipleEmailReadFailure) {
          _markAsSelectedEmailReadFailure(failure);
        }
      },
      (success) {
        if (success is GetAllEmailSuccess) {
          _getAllEmailSuccess(success);
        } else if (success is MarkAsMultipleEmailReadAllSuccess
            || success is MarkAsMultipleEmailReadHasSomeEmailFailure) {
          _markAsSelectedEmailReadSuccess(success);
        } else if (success is MoveMultipleEmailToMailboxAllSuccess
            || success is MoveMultipleEmailToMailboxHasSomeEmailFailure) {
          _moveSelectedMultipleEmailToMailboxSuccess(success);
        } else if (success is MarkAsEmailImportantSuccess) {
          _markAsEmailImportantSuccess(success);
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

      mailboxDashBoardController.viewState.value.map((success) {
        if (success is MarkAsEmailImportantSuccess) {
          _updateValueCurrentEmail();
          mailboxDashBoardController.clearState();
        }
      });
    }
  }

  void _updateValueCurrentEmail() {
    if (mailboxDashBoardController.selectedEmail.value != null) {
      try {
        final newSelectedEmail = emailList.firstWhere(
                (email) => email.id == mailboxDashBoardController.selectedEmail.value!.id,
            orElse: null);
        mailboxDashBoardController.setSelectedEmail(newSelectedEmail);
      } catch(e){}
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
    dispatchState(Right(LoadingState()));
    emailList.value = <PresentationEmail>[];

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

  void _refreshListEmail() {
      currentSelectMode.value = SelectMode.INACTIVE;
      final newLimit = emailList.isNotEmpty ? UnsignedInt(emailList.length) : ThreadConstants.defaultLimit;
      loadMoreState.value = LoadMoreState.IDLE;
      dispatchState(Right(LoadingState()));
      emailList.value = <PresentationEmail>[];

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

  void markAsSelectedEmailRead(List<PresentationEmail> listPresentationEmail, {bool fromContextMenuAction = false}) {
    if (fromContextMenuAction) {
      popBack();
    }

    final readAction = isEmailAllRead(listPresentationEmail) ? ReadActions.markAsUnread : ReadActions.markAsRead;

    final accountId = mailboxDashBoardController.accountId.value;
    final mailboxCurrent = mailboxDashBoardController.selectedMailbox.value;
    if (accountId != null && mailboxCurrent != null) {
      final listEmail = listPresentationEmail.map((presentationEmail) => presentationEmail.toEmail()).toList();
      consumeState(_markAsMultipleEmailReadInteractor.execute(accountId, listEmail, readAction));
    }
  }

  void _markAsSelectedEmailReadSuccess(Success success) {
    cancelSelectEmail();

    mailboxDashBoardController.dispatchState(Right(success));

    ReadActions? readActions;
    int countMarkAsReadSuccess = 0;

    if (success is MarkAsMultipleEmailReadAllSuccess) {
      readActions = success.readActions;
      countMarkAsReadSuccess = success.countMarkAsReadSuccess;
    } else if (success is MarkAsMultipleEmailReadHasSomeEmailFailure) {
      readActions = success.readActions;
      countMarkAsReadSuccess = success.countMarkAsReadSuccess;
    }

    if (Get.context != null && readActions != null) {
      _appToast.showSuccessToast(readActions == ReadActions.markAsUnread
          ? AppLocalizations.of(Get.context!).marked_multiple_item_as_unread(countMarkAsReadSuccess)
          : AppLocalizations.of(Get.context!).marked_multiple_item_as_read(countMarkAsReadSuccess));
    }
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

  void moveSelectedMultipleEmailToMailboxAction(List<PresentationEmail> listEmail) async {
    final currentMailbox = mailboxDashBoardController.selectedMailbox.value;
    final accountId = mailboxDashBoardController.accountId.value;
    if (currentMailbox != null && accountId != null) {
      popBack();

      final listEmailIds = listEmail.map((email) => email.id).toList();
      final destinationMailbox = await push(
          AppRoutes.DESTINATION_PICKER,
          arguments: DestinationPickerArguments(accountId, listEmailIds, currentMailbox)
      );

      if (destinationMailbox != null && destinationMailbox is PresentationMailbox) {
        _moveSelectedEmailMultipleToMailbox(
            accountId,
            MoveRequest(
              listEmailIds,
              currentMailbox.id,
              destinationMailbox.id,
              MoveAction.moveTo,
              destinationPath: destinationMailbox.mailboxPath));
      }
    }
  }

  void _moveSelectedEmailMultipleToMailbox(AccountId accountId, MoveRequest moveRequest) {
    consumeState(_moveMultipleEmailToMailboxInteractor.execute(accountId, moveRequest));
  }

  void _moveSelectedMultipleEmailToMailboxSuccess(Success success) {
    mailboxDashBoardController.dispatchState(Right(success));

    String? destinationPath;
    List<EmailId> movedEmailIds = [];
    MailboxId? currentMailboxId;
    MailboxId? destinationMailboxId;
    MoveAction? moveAction;

    if (success is MoveMultipleEmailToMailboxAllSuccess) {
      destinationPath = success.destinationPath;
      movedEmailIds = success.movedListEmailId;
      currentMailboxId = success.currentMailboxId;
      destinationMailboxId = success.destinationMailboxId;
      moveAction = success.moveAction;
    } else if (success is MoveMultipleEmailToMailboxHasSomeEmailFailure) {
      destinationPath = success.destinationPath;
      movedEmailIds = success.movedListEmailId;
      currentMailboxId = success.currentMailboxId;
      destinationMailboxId = success.destinationMailboxId;
      moveAction = success.moveAction;
    }

    if (Get.context != null && Get.overlayContext != null
        && destinationPath != null && moveAction == MoveAction.moveTo) {
      _appToast.showToastWithAction(
          Get.overlayContext!,
          AppLocalizations.of(Get.context!).moved_to_mailbox(destinationPath),
          AppLocalizations.of(Get.context!).undo_action,
          () {
            final newCurrentMailboxId = destinationMailboxId;
            final newDestinationMailboxId = currentMailboxId;
            if (newCurrentMailboxId != null && newDestinationMailboxId != null) {
              _undoMoveSelectedMultipleEmailToMailbox(MoveRequest(
                  movedEmailIds,
                  newCurrentMailboxId,
                  newDestinationMailboxId,
                  MoveAction.undo,
                  destinationPath: destinationPath));
            }
          }
      );
    }

    _refreshListEmail();
  }

  void _undoMoveSelectedMultipleEmailToMailbox(MoveRequest moveRequest) {
    final accountId = mailboxDashBoardController.accountId.value;

    if (accountId != null) {
      _moveSelectedEmailMultipleToMailbox(accountId, moveRequest);
    }
  }

  void markAsEmailImportant(PresentationEmail presentationEmail) {
    final accountId = mailboxDashBoardController.accountId.value;
    final mailboxCurrent = mailboxDashBoardController.selectedMailbox.value;
    if (accountId != null && mailboxCurrent != null) {
      final importantAction = presentationEmail.isFlaggedEmail() ? ImportantAction.unMarkStar : ImportantAction.markStar;
      consumeState(_markAsEmailImportantInteractor.execute(accountId, presentationEmail.id, importantAction));
    }
  }

  void _markAsEmailImportantSuccess(Success success) {
    _refreshListEmail();
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