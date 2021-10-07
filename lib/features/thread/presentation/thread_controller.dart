import 'package:core/core.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_comparator.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_comparator_property.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_filter_condition.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/model/destination_picker_arguments.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_request.dart';
import 'package:tmail_ui_user/features/email/domain/state/mark_as_email_star_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/mark_as_email_read_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/move_to_mailbox_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_star_email_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/thread/domain/constants/thread_constants.dart';
import 'package:tmail_ui_user/features/thread/domain/state/get_all_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_as_multiple_email_read_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/move_multiple_email_to_mailbox_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_as_star_multiple_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/get_emails_in_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/mark_as_multiple_email_read_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/move_multiple_email_to_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/mark_as_star_multiple_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/refresh_changes_emails_in_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/load_more_state.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;

class ThreadController extends BaseController {

  final mailboxDashBoardController = Get.find<MailboxDashBoardController>();
  final GetEmailsInMailboxInteractor _getEmailsInMailboxInteractor;
  final MarkAsMultipleEmailReadInteractor _markAsMultipleEmailReadInteractor;
  final AppToast _appToast;
  final ResponsiveUtils responsiveUtils;
  final ScrollController listEmailController;
  final MoveMultipleEmailToMailboxInteractor _moveMultipleEmailToMailboxInteractor;
  final MarkAsStarEmailInteractor _markAsStarEmailInteractor;
  final MarkAsStarMultipleEmailInteractor _markAsStarMultipleEmailInteractor;
  final RefreshChangesEmailsInMailboxInteractor _refreshChangesEmailsInMailboxInteractor;

  final emailList = <PresentationEmail>[].obs;
  final loadMoreState = LoadMoreState.IDLE.obs;
  final currentSelectMode = SelectMode.INACTIVE.obs;

  int _currentPosition = 0;
  int _totalNumberOfEmails = 0;
  MailboxId? _currentMailboxId;
  jmap.State? _currentEmailState;

  EmailFilterCondition? get _filterCondition => EmailFilterCondition(
    inMailbox: mailboxDashBoardController.selectedMailbox.value?.id);

  Set<Comparator>? get _sortOrder => Set()
    ..add(EmailComparator(EmailComparatorProperty.sentAt)
      ..setIsAscending(false));

  AccountId? get _accountId => mailboxDashBoardController.accountId.value;

  ThreadController(
    this.responsiveUtils,
    this._getEmailsInMailboxInteractor,
    this.listEmailController,
    this._markAsMultipleEmailReadInteractor,
    this._appToast,
    this._moveMultipleEmailToMailboxInteractor,
    this._markAsStarEmailInteractor,
    this._markAsStarMultipleEmailInteractor,
    this._refreshChangesEmailsInMailboxInteractor,
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
        _resetToOriginalValue();
        _getAllEmail();
      }
    });

    mailboxDashBoardController.viewState.listen((state) {
      state.map((success) {
        if (success is MarkAsEmailReadSuccess
            || success is MarkAsMultipleEmailReadAllSuccess
            || success is MarkAsMultipleEmailReadHasSomeEmailFailure
            || success is MoveToMailboxSuccess
            || success is MarkAsStarEmailSuccess) {
          cancelSelectEmail();
          _refreshEmailChanges();
          mailboxDashBoardController.clearState();
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
  void onData(Either<Failure, Success> newState) {
    super.onData(newState);
    newState.map((success) {
      if (success is GetAllEmailSuccess) {
        _getAllEmailSuccess(success);
      }
    });
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
        } else if (failure is MarkAsStarMultipleEmailAllFailure
            || failure is MarkAsStarMultipleEmailFailure) {
          _markAsStarMultipleEmailFailure(failure);
        }
      },
      (success) {
        if (success is MarkAsMultipleEmailReadAllSuccess
            || success is MarkAsMultipleEmailReadHasSomeEmailFailure) {
          _markAsSelectedEmailReadSuccess(success);
        } else if (success is MoveMultipleEmailToMailboxAllSuccess
            || success is MoveMultipleEmailToMailboxHasSomeEmailFailure) {
          _moveSelectedMultipleEmailToMailboxSuccess(success);
        } else if (success is MarkAsStarEmailSuccess) {
          _markAsStarEmailSuccess(success);
        } else if (success is MarkAsStarMultipleEmailAllSuccess
            || success is MarkAsStarMultipleEmailHasSomeEmailFailure) {
          _markAsStarMultipleEmailSuccess(success);
        }
      }
    );
  }

  @override
  void onError(error) {}

  void _getAllEmail() {
    if (_accountId != null) {
      _getAllEmailAction(_accountId!, inMailboxId: _currentMailboxId);
    }
  }

  void _resetToOriginalValue() {
    dispatchState(Right(LoadingState()));
    emailList.value = <PresentationEmail>[];
    loadMoreState.value = LoadMoreState.IDLE;
    _currentPosition = 0;
  }

  void _getAllEmailSuccess(Success success) {
    if (success is GetAllEmailSuccess) {
      _currentEmailState = success.currentEmailState;

      if (loadMoreState.value == LoadMoreState.LOADING) {
        emailList.addAll(success.emailList);
      } else {
        emailList.value = success.emailList;
      }

      _totalNumberOfEmails = emailList.length;
      loadMoreState.value = success.emailList.isEmpty ? LoadMoreState.COMPLETED : LoadMoreState.IDLE;
    }
  }

  void _getAllEmailAction(AccountId accountId, {MailboxId? inMailboxId}) {
    consumeState(_getEmailsInMailboxInteractor.execute(
      accountId,
      limit: ThreadConstants.defaultLimit,
      position: _currentPosition,
      sort: _sortOrder,
      filter: _filterCondition,
      propertiesCreated: ThreadConstants.propertiesDefault,
      propertiesUpdated: ThreadConstants.propertiesUpdatedDefault,
      inMailboxId: inMailboxId ?? _currentMailboxId
    ));
  }

  void refreshAllEmail() {
    dispatchState(Right(LoadingState()));
    loadMoreState.value = LoadMoreState.IDLE;
    _currentPosition = 0;
    _getAllEmail();
  }

  void _refreshEmailChanges() {
    if (_accountId != null && _currentEmailState != null) {
      consumeState(_refreshChangesEmailsInMailboxInteractor.execute(
        _accountId!,
        _currentEmailState!,
        sort: _sortOrder,
        propertiesCreated: ThreadConstants.propertiesDefault,
        propertiesUpdated: ThreadConstants.propertiesUpdatedDefault,
        inMailboxId: _currentMailboxId,
      ));
    }
  }

  void loadMoreEmailAction() {
    loadMoreState.value = LoadMoreState.LOADING;
    _currentPosition += _totalNumberOfEmails;

    if (_accountId != null) {
      _getAllEmailAction(_accountId!);
    }
  }

  void _resetPositionCurrentAndLoadMoreState() {
    if (loadMoreState.value == LoadMoreState.LOADING) {
      _currentPosition -= _totalNumberOfEmails;
    }
    loadMoreState.value = LoadMoreState.IDLE;
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

  bool isAllEmailRead(List<PresentationEmail> listEmail) => listEmail.every((email) => email.isReadEmail());

  bool isAllEmailMarkAsStar(List<PresentationEmail> listEmail) => listEmail.every((email) => email.isFlaggedEmail());

  void cancelSelectEmail() {
    emailList.value = emailList.map((email) => email.toSelectedEmail(selectMode: SelectMode.INACTIVE)).toList();
    currentSelectMode.value = SelectMode.INACTIVE;
  }

  void markAsSelectedEmailRead(List<PresentationEmail> listPresentationEmail, {bool fromContextMenuAction = false}) {
    if (fromContextMenuAction) {
      popBack();
    }

    final readAction = isAllEmailRead(listPresentationEmail) ? ReadActions.markAsUnread : ReadActions.markAsRead;

    final mailboxCurrent = mailboxDashBoardController.selectedMailbox.value;
    if (_accountId != null && mailboxCurrent != null) {
      final listEmail = listPresentationEmail.map((presentationEmail) => presentationEmail.toEmail()).toList();
      consumeState(_markAsMultipleEmailReadInteractor.execute(_accountId!, listEmail, readAction));
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
    if (currentMailbox != null && _accountId != null) {
      popBack();

      final listEmailIds = listEmail.map((email) => email.id).toList();
      final destinationMailbox = await push(
          AppRoutes.DESTINATION_PICKER,
          arguments: DestinationPickerArguments(_accountId!, listEmailIds, currentMailbox)
      );

      if (destinationMailbox != null && destinationMailbox is PresentationMailbox) {
        _moveSelectedEmailMultipleToMailbox(
            _accountId!,
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
    cancelSelectEmail();
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

    _refreshEmailChanges();
  }

  void _undoMoveSelectedMultipleEmailToMailbox(MoveRequest moveRequest) {
    if (_accountId != null) {
      _moveSelectedEmailMultipleToMailbox(_accountId!, moveRequest);
    }
  }

  void openPopupMenuSelectedEmail(BuildContext context, RelativeRect position, List<PopupMenuItem> popupMenuItems) async {
    await showMenu(
      context: context,
      position: position,
      color: Colors.white,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      items: popupMenuItems);
  }

  void markAsStarEmail(PresentationEmail presentationEmail) {
    final mailboxCurrent = mailboxDashBoardController.selectedMailbox.value;
    if (_accountId != null && mailboxCurrent != null) {
      final importantAction = presentationEmail.isFlaggedEmail() ? MarkStarAction.unMarkStar : MarkStarAction.markStar;
      dispatchState(Right(LoadingState()));
      consumeState(_markAsStarEmailInteractor.execute(_accountId!, presentationEmail.toEmail(), importantAction));
    }
  }

  void _markAsStarEmailSuccess(Success success) {
    _refreshEmailChanges();
  }

  void markAsStarSelectedMultipleEmail(List<PresentationEmail> listPresentationEmail, MarkStarAction markStarAction) {
    popBack();

    final mailboxCurrent = mailboxDashBoardController.selectedMailbox.value;
    if (_accountId != null && mailboxCurrent != null) {
      final listEmail = listPresentationEmail.map((presentationEmail) => presentationEmail.toEmail()).toList();
      consumeState(_markAsStarMultipleEmailInteractor.execute(_accountId!, listEmail, markStarAction));
    }
  }

  void _markAsStarMultipleEmailSuccess(Success success) {
    cancelSelectEmail();
    _refreshEmailChanges();

    MarkStarAction? markStarAction;
    int countMarkStarSuccess = 0;

    if (success is MarkAsStarMultipleEmailAllSuccess) {
      markStarAction = success.markStarAction;
      countMarkStarSuccess = success.countMarkStarSuccess;
    } else if (success is MarkAsStarMultipleEmailHasSomeEmailFailure) {
      markStarAction = success.markStarAction;
      countMarkStarSuccess = success.countMarkStarSuccess;
    }

    if (Get.context != null && markStarAction != null) {
      _appToast.showSuccessToast(markStarAction == MarkStarAction.unMarkStar
          ? AppLocalizations.of(Get.context!).marked_unstar_multiple_item(countMarkStarSuccess)
          : AppLocalizations.of(Get.context!).marked_star_multiple_item(countMarkStarSuccess));
    }
  }

  void _markAsStarMultipleEmailFailure(Failure failure) {
    cancelSelectEmail();
    if (Get.context != null) {
      _appToast.showErrorToast(AppLocalizations.of(Get.context!).an_error_occurred);
    }
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