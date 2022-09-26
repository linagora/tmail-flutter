import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/capability/mail_capability.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:jmap_dart_client/jmap/mail/vacation/vacation_response.dart';
import 'package:model/model.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/base/action/ui_action.dart';
import 'package:tmail_ui_user/features/base/reloadable/reloadable_controller.dart';
import 'package:tmail_ui_user/features/composer/domain/state/save_email_as_drafts_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/send_email_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/update_email_drafts_state.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_bindings.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/email_action_type_extension.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/model/destination_picker_arguments.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_action.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_to_mailbox_request.dart';
import 'package:tmail_ui_user/features/email/domain/state/delete_email_permanently_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/delete_multiple_emails_permanently_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/move_to_mailbox_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/delete_email_permanently_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/delete_multiple_emails_permanently_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_email_read_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_star_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/move_to_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authenticated_account_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/mark_as_mailbox_read_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/mark_as_mailbox_read_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/get_composer_cache_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/remove_email_drafts_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_composer_cache_on_web_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/remove_email_drafts_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/dashboard_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/download/download_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/search_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/composer_overlay_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/download/download_task_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_all_vacation_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/update_vacation_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_vacation_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/update_vacation_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/vacation_response_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/manage_account_arguments.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/features/thread/domain/state/empty_trash_folder_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_as_multiple_email_read_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_as_star_multiple_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/move_multiple_email_to_mailbox_state.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/empty_trash_folder_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/mark_as_multiple_email_read_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/mark_as_star_multiple_email_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/move_multiple_email_to_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/delete_action_type.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/routes/router_arguments.dart';
import 'package:tmail_ui_user/main/utils/email_receive_manager.dart';

class MailboxDashBoardController extends ReloadableController {

  final AppToast _appToast = Get.find<AppToast>();
  final ImagePaths _imagePaths = Get.find<ImagePaths>();
  final RemoveEmailDraftsInteractor _removeEmailDraftsInteractor = Get.find<RemoveEmailDraftsInteractor>();
  final Connectivity _connectivity = Get.find<Connectivity>();
  final ResponsiveUtils _responsiveUtils = Get.find<ResponsiveUtils>();
  final EmailReceiveManager _emailReceiveManager = Get.find<EmailReceiveManager>();
  final SearchController searchController = Get.find<SearchController>();
  final DownloadController downloadController = Get.find<DownloadController>();

  final MoveToMailboxInteractor _moveToMailboxInteractor;
  final DeleteEmailPermanentlyInteractor _deleteEmailPermanentlyInteractor;
  final MarkAsMailboxReadInteractor _markAsMailboxReadInteractor;
  final GetComposerCacheOnWebInteractor _getEmailCacheOnWebInteractor;
  final MarkAsEmailReadInteractor _markAsEmailReadInteractor;
  final MarkAsStarEmailInteractor _markAsStarEmailInteractor;
  final MarkAsMultipleEmailReadInteractor _markAsMultipleEmailReadInteractor;
  final MarkAsStarMultipleEmailInteractor _markAsStarMultipleEmailInteractor;
  final MoveMultipleEmailToMailboxInteractor _moveMultipleEmailToMailboxInteractor;
  final EmptyTrashFolderInteractor _emptyTrashFolderInteractor;
  final DeleteMultipleEmailsPermanentlyInteractor _deleteMultipleEmailsPermanentlyInteractor;

  GetAllVacationInteractor? _getAllVacationInteractor;
  UpdateVacationInteractor? _updateVacationInteractor;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final selectedMailbox = Rxn<PresentationMailbox>();
  final selectedEmail = Rxn<PresentationEmail>();
  final accountId = Rxn<AccountId>();
  final userProfile = Rxn<UserProfile>();
  final dashBoardAction = Rxn<UIAction>();
  final routePath = AppRoutes.MAILBOX_DASHBOARD.obs;
  final appInformation = Rxn<PackageInfo>();
  final currentSelectMode = SelectMode.INACTIVE.obs;
  final filterMessageOption = FilterMessageOption.all.obs;
  final listEmailSelected = <PresentationEmail>[].obs;
  final composerOverlayState = ComposerOverlayState.inActive.obs;
  final viewStateMarkAsReadMailbox = Rx<Either<Failure, Success>>(Right(UIState.idle));
  final vacationResponse = Rxn<VacationResponse>();

  Session? sessionCurrent;
  Map<Role, MailboxId> mapDefaultMailboxIdByRole = {};
  Map<MailboxId, PresentationMailbox> mapMailboxById = {};
  PresentationMailbox? outboxMailbox;
  RouterArguments? routerArguments;

  late StreamSubscription _connectivityStreamSubscription;
  late StreamSubscription _emailReceiveManagerStreamSubscription;
  late StreamSubscription _fileReceiveManagerStreamSubscription;

  final StreamController<Either<Failure, Success>> _progressStateController =
    StreamController<Either<Failure, Success>>.broadcast();
  Stream<Either<Failure, Success>> get progressState => _progressStateController.stream;

  MailboxDashBoardController(
    LogoutOidcInteractor logoutOidcInteractor,
    DeleteAuthorityOidcInteractor deleteAuthorityOidcInteractor,
    GetAuthenticatedAccountInteractor getAuthenticatedAccountInteractor,
    this._moveToMailboxInteractor,
    this._deleteEmailPermanentlyInteractor,
    this._markAsMailboxReadInteractor,
    this._getEmailCacheOnWebInteractor,
    this._markAsEmailReadInteractor,
    this._markAsStarEmailInteractor,
    this._markAsMultipleEmailReadInteractor,
    this._markAsStarMultipleEmailInteractor,
    this._moveMultipleEmailToMailboxInteractor,
    this._emptyTrashFolderInteractor,
    this._deleteMultipleEmailsPermanentlyInteractor,
  ) : super(logoutOidcInteractor,
      deleteAuthorityOidcInteractor,
      getAuthenticatedAccountInteractor);

  @override
  void onInit() {
    _registerProgressState();
    _registerNetworkConnectivityState();

    super.onInit();
  }

  @override
  void onReady() {
    log('MailboxDashBoardController::onReady()');
    dispatchRoute(AppRoutes.THREAD);
    _registerPendingEmailAddress();
    _registerPendingFileInfo();
    _setSessionCurrent();
    _getUserProfile();
    _getVacationResponse();
    _getAppVersion();
    super.onReady();
  }

  void _handleComposerCache() async {
    if (kIsWeb && userProfile.value != null) {
      _getEmailCacheOnWebInteractor.execute().fold(
        (failure) {},
        (success) {
          if(success is GetComposerCacheSuccess){
            final ComposerArguments composerArguments = ComposerArguments(
              emailActionType: EmailActionType.edit,
              presentationEmail: PresentationEmail(
                success.composerCache.id,
                subject: success.composerCache.subject,
                from: success.composerCache.from,
                to: success.composerCache.to,
                cc: success.composerCache.cc,
                bcc: success.composerCache.bcc,
              ),
              emailContents: success.composerCache.emailContentList,
            );
            openComposerOverlay(composerArguments);
          }
        },
      );    
    }
  }

  @override
  void onData(Either<Failure, Success> newState) {
    super.onData(newState);
    viewState.value.map((success) {
      if (success is SendingEmailState) {
        if (currentOverlayContext != null && currentContext != null) {
          _appToast.showToastWithIcon(
              currentOverlayContext!,
              message: AppLocalizations.of(currentContext!).your_email_being_sent,
              icon: _imagePaths.icSendToast);
        }
      }
    });
  }

  @override
  void onDone() {
    viewState.value.fold(
      (failure) {
        if (failure is SendEmailFailure) {
          if (currentOverlayContext != null && currentContext != null) {
            _appToast.showToastWithIcon(
                currentOverlayContext!,
                textColor: AppColor.toastErrorBackgroundColor,
                message: AppLocalizations.of(currentContext!).message_has_been_sent_failure,
                icon: _imagePaths.icSendToast);
          }
          clearState();
        } else if (failure is SaveEmailAsDraftsFailure
            || failure is RemoveEmailDraftsFailure
            || failure is UpdateEmailDraftsFailure) {
          clearState();
        } else if (failure is MarkAsMailboxReadAllFailure ||
            failure is MarkAsMailboxReadFailure) {
          _markAsReadMailboxFailure(failure);
        }
      },
      (success) {
        if (success is SendEmailSuccess) {
          if (currentOverlayContext != null && currentContext != null) {
            _appToast.showToastWithIcon(
                currentOverlayContext!,
                textColor: AppColor.primaryColor,
                message: AppLocalizations.of(currentContext!).message_has_been_sent_successfully,
                icon: _imagePaths.icSendToast);
          }
        } else if (success is SaveEmailAsDraftsSuccess) {
          log('MailboxDashBoardController::onDone(): SaveEmailAsDraftsSuccess');
          _saveEmailAsDraftsSuccess(success);
        } else if (success is MoveToMailboxSuccess) {
          _moveToMailboxSuccess(success);
        } else if (success is DeleteEmailPermanentlySuccess) {
          _deleteEmailPermanentlySuccess(success);
        } else if (success is MarkAsMailboxReadAllSuccess ||
            success is MarkAsMailboxReadHasSomeEmailFailure) {
          _markAsReadMailboxSuccess(success);
        } else if (success is GetAllVacationSuccess) {
          if (success.listVacationResponse.isNotEmpty) {
            vacationResponse.value = success.listVacationResponse.first;
          }
        } else if (success is UpdateVacationSuccess) {
          _handleUpdateVacationSuccess(success);
        } else if (success is MarkAsMultipleEmailReadAllSuccess
            || success is MarkAsMultipleEmailReadHasSomeEmailFailure) {
          _markAsReadSelectedMultipleEmailSuccess(success);
        } else if (success is MarkAsStarMultipleEmailAllSuccess
            || success is MarkAsStarMultipleEmailHasSomeEmailFailure) {
          _markAsStarMultipleEmailSuccess(success);
        } else if (success is MoveMultipleEmailToMailboxAllSuccess
            || success is MoveMultipleEmailToMailboxHasSomeEmailFailure) {
          _moveSelectedMultipleEmailToMailboxSuccess(success);
        } else if (success is EmptyTrashFolderSuccess) {
          _emptyTrashFolderSuccess(success);
        } else if (success is DeleteMultipleEmailsPermanentlyAllSuccess
            || success is DeleteMultipleEmailsPermanentlyHasSomeEmailFailure) {
          _deleteMultipleEmailsPermanentlySuccess(success);
        }
      }
    );
  }

  @override
  void onError(error) {}

  void _registerNetworkConnectivityState() async {
    setNetworkConnectivityState(await _connectivity.checkConnectivity());
    _connectivityStreamSubscription = _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      log('MailboxDashBoardController::_registerNetworkConnectivityState(): ConnectivityResult: ${result.name}');
      setNetworkConnectivityState(result);
      if (userProfile.value == null && result != ConnectivityResult.none) {
        _getUserProfile();
      }
    });
  }

  void _registerPendingEmailAddress() {
    _emailReceiveManagerStreamSubscription =
        _emailReceiveManager.pendingEmailAddressInfo.stream.listen((emailAddress) {
          log('MailboxDashBoardController::_registerPendingEmailAddress(): ${emailAddress?.email}');
          if (emailAddress != null && emailAddress.email?.isNotEmpty == true) {
            _emailReceiveManager.clearPendingEmailAddress();
            final arguments = ComposerArguments(
                emailActionType: EmailActionType.composeFromEmailAddress,
                emailAddress: emailAddress,
                mailboxRole: selectedMailbox.value?.role);
            goToComposer(arguments);
          }
        });
  }

  void _registerPendingFileInfo() {
    _fileReceiveManagerStreamSubscription =
        _emailReceiveManager.pendingFileInfo.stream.listen((listFile) {
          log('MailboxDashBoardController::_registerPendingFileInfo(): ${listFile.length}');
          if (listFile.isNotEmpty && sessionCurrent != null) {
            _emailReceiveManager.clearPendingFileInfo();
            final arguments = ComposerArguments(
              emailActionType: EmailActionType.edit,
              mailboxRole: selectedMailbox.value?.role,
              listSharedMediaFile: listFile,
            );
            goToComposer(arguments);
          }
        });
  }

  void _registerProgressState() async {
    progressState.listen((state) {
      viewStateMarkAsReadMailbox.value = state;
    });
  }

  void _getUserProfile() async {
    userProfile.value = sessionCurrent != null ? UserProfile(sessionCurrent!.username.value) : null;
  }

  void _setSessionCurrent() {
    final arguments = Get.arguments;
    log('MailboxDashBoardController::_setSessionCurrent(): arguments = $arguments');
    if (arguments is Session) {
      sessionCurrent = arguments;
      accountId.value = sessionCurrent?.accounts.keys.first;
      injectAutoCompleteBindings(sessionCurrent, accountId.value);
      injectVacationBindings(sessionCurrent, accountId.value);
    } else {
      if (kIsWeb) {
        reload();
      }
    }
  }

  @override
  void injectVacationBindings(Session? session, AccountId? accountId) {
    try {
      super.injectVacationBindings(session, accountId);
      _getAllVacationInteractor = Get.find<GetAllVacationInteractor>();
      _updateVacationInteractor = Get.find<UpdateVacationInteractor>();
    } catch (e) {
      logError('MailboxDashBoardController::injectVacationBindings(): $e');
    }
  }

  Future<void> _getAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    log('MailboxDashBoardController::_getAppVersion(): ${info.version}');
    appInformation.value = info;
  }

  void _getVacationResponse() {
    if (accountId.value != null && _getAllVacationInteractor != null) {
      consumeState(_getAllVacationInteractor!.execute(accountId.value!));
    }
  }

  MailboxId? getMailboxIdByRole(Role role) {
    return mapDefaultMailboxIdByRole[role];
  }

  void setMapDefaultMailboxIdByRole(Map<Role, MailboxId> newMapMailboxId) {
    mapDefaultMailboxIdByRole = newMapMailboxId;
  }

  void setMapMailboxById(Map<MailboxId, PresentationMailbox> newMapMailboxById) {
    mapMailboxById = newMapMailboxById;
  }

  void setOutboxMailbox(PresentationMailbox? newOutbox) {
    outboxMailbox = newOutbox;
    log('MailboxDashBoardController::setOutboxMailbox(): $newOutbox');
  }

  void setSelectedMailbox(PresentationMailbox? newPresentationMailbox) {
    selectedMailbox.value = newPresentationMailbox;
  }

  void setNewFirstSelectedMailbox(PresentationMailbox? newPresentationMailbox) {
    selectedMailbox.firstRebuild = true;
    selectedMailbox.value = newPresentationMailbox;
  }

  void setSelectedEmail(PresentationEmail? newPresentationEmail) {
    selectedEmail.value = newPresentationEmail;
  }

  void clearSelectedEmail() {
    selectedEmail.value = null;
  }

  void openMailboxMenuDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }

  void closeMailboxMenuDrawer() {
    scaffoldKey.currentState?.openEndDrawer();
  }

  bool get isDrawerOpen => scaffoldKey.currentState?.isDrawerOpen == true;

  bool isSelectionEnabled() => currentSelectMode.value == SelectMode.ACTIVE;

  void searchEmail(BuildContext context, String value) {
    searchController.updateFilterEmail(text: SearchQuery(value));
    dispatchAction(StartSearchEmailAction());
    FocusScope.of(context).unfocus();
    if (_searchInsideEmailDetailedViewIsActive(context)) {
      _closeEmailDetailedView();
    }
    if (value.isEmpty){
      searchController.setEmailReceiveTimeType(null);
    }
    _unSelectedMailbox();
  }

  bool _searchInsideEmailDetailedViewIsActive(BuildContext context) {
    return BuildUtils.isWeb
        && _responsiveUtils.isDesktop(context)
        && routePath.value == AppRoutes.EMAIL;
  }

  void _unSelectedMailbox() {
    selectedMailbox.value = null;
  }

  void _closeEmailDetailedView() {
    dispatchRoute(AppRoutes.THREAD);
    clearSelectedEmail();
  }

  void _saveEmailAsDraftsSuccess(SaveEmailAsDraftsSuccess success) {
    if (currentContext != null && currentOverlayContext != null) {
      _appToast.showToastWithAction(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).drafts_saved,
          AppLocalizations.of(currentContext!).discard,
          () => _discardEmail(success.emailAsDrafts),
          maxWidth: _responsiveUtils.getMaxWidthToast(currentContext!)
      );
    }
  }

  void moveToMailbox(AccountId accountId, MoveToMailboxRequest moveRequest) {
    consumeState(_moveToMailboxInteractor.execute(accountId, moveRequest));
  }

  void _moveToMailboxSuccess(MoveToMailboxSuccess success) {
    if (success.moveAction == MoveAction.moving && currentContext != null && currentOverlayContext != null) {
      _appToast.showToastWithAction(
          currentOverlayContext!,
          success.emailActionType.getToastMessageMoveToMailboxSuccess(currentContext!, destinationPath: success.destinationPath),
          AppLocalizations.of(currentContext!).undo_action, () {
            _revertedToOriginalMailbox(MoveToMailboxRequest(
                [success.emailId],
                success.destinationMailboxId,
                success.currentMailboxId,
                MoveAction.undo,
                success.emailActionType));
          },
          maxWidth: _responsiveUtils.getMaxWidthToast(currentContext!)
      );
    }
  }

  void _revertedToOriginalMailbox(MoveToMailboxRequest newMoveRequest) {
    final currentAccountId = accountId.value;
    if (currentAccountId != null) {
      consumeState(_moveToMailboxInteractor.execute(currentAccountId, newMoveRequest));
    }
  }

  void _discardEmail(Email email) {
    final currentAccountId = accountId.value;
    if (currentAccountId != null) {
      consumeState(_removeEmailDraftsInteractor.execute(currentAccountId, email.id));
    }
  }

  void deleteEmailPermanently(PresentationEmail email) {
    final currentAccountId = accountId.value;
    if (currentAccountId != null) {
      consumeState(_deleteEmailPermanentlyInteractor.execute(currentAccountId, email.id));
    }
  }

  void _deleteEmailPermanentlySuccess(DeleteEmailPermanentlySuccess success) {
    if (currentContext != null && currentOverlayContext != null) {
      _appToast.showToastWithIcon(
          currentOverlayContext!,
          widthToast: _responsiveUtils.isDesktop(currentContext!) ? 360 : null,
          message: AppLocalizations.of(currentContext!).toast_message_delete_a_email_permanently_success,
          icon: _imagePaths.icDeleteToast);
    }
  }

  void markAsEmailRead(PresentationEmail presentationEmail, ReadActions readActions) async {
    if (accountId.value != null) {
      consumeState(_markAsEmailReadInteractor.execute(
          accountId.value!,
          presentationEmail.toEmail(),
          readActions));
    }
  }

  void markAsStarEmail(PresentationEmail presentationEmail, MarkStarAction action) {
    if (accountId.value != null) {
      consumeState(_markAsStarEmailInteractor.execute(
          accountId.value!,
          presentationEmail.toEmail(),
          action));
    }
  }

  void markAsReadSelectedMultipleEmail(List<PresentationEmail> listPresentationEmail, ReadActions readActions) {
    final listEmail = listPresentationEmail
        .map((presentationEmail) => presentationEmail.toEmail())
        .toList();
    log('MailboxDashBoardController::markAsReadSelectedMultipleEmail(): listEmail: ${listEmail.length}');
    if (accountId.value != null) {
      consumeState(_markAsMultipleEmailReadInteractor.execute(
          accountId.value!,
          listEmail,
          readActions));
    }
  }

  void _markAsReadSelectedMultipleEmailSuccess(Success success) {
    ReadActions? readActions;

    if (success is MarkAsMultipleEmailReadAllSuccess) {
      readActions = success.readActions;
    } else if (success is MarkAsMultipleEmailReadHasSomeEmailFailure) {
      readActions = success.readActions;
    }

    if (currentContext != null && readActions != null && currentOverlayContext != null) {
      final message = readActions == ReadActions.markAsUnread
          ? AppLocalizations.of(currentContext!).marked_message_toast(AppLocalizations.of(currentContext!).unread)
          : AppLocalizations.of(currentContext!).marked_message_toast(AppLocalizations.of(currentContext!).read);
      _appToast.showToastWithIcon(
          currentOverlayContext!,
          message: message,
          icon: readActions == ReadActions.markAsUnread
              ? _imagePaths.icUnreadToast
              : _imagePaths.icReadToast);
    }
  }

  void markAsStarSelectedMultipleEmail(List<PresentationEmail> listPresentationEmail, MarkStarAction markStarAction) {
    final listEmail = listPresentationEmail
        .map((presentationEmail) => presentationEmail.toEmail())
        .toList();
    if (accountId.value != null) {
      consumeState(_markAsStarMultipleEmailInteractor.execute(
          accountId.value!,
          listEmail,
          markStarAction));
    }
  }

  void _markAsStarMultipleEmailSuccess(Success success) {
    MarkStarAction? markStarAction;
    int countMarkStarSuccess = 0;

    if (success is MarkAsStarMultipleEmailAllSuccess) {
      markStarAction = success.markStarAction;
      countMarkStarSuccess = success.countMarkStarSuccess;
    } else if (success is MarkAsStarMultipleEmailHasSomeEmailFailure) {
      markStarAction = success.markStarAction;
      countMarkStarSuccess = success.countMarkStarSuccess;
    }

    if (currentContext != null && markStarAction != null && currentOverlayContext != null) {
      final message = markStarAction == MarkStarAction.unMarkStar
          ? AppLocalizations.of(currentContext!).marked_unstar_multiple_item(countMarkStarSuccess)
          : AppLocalizations.of(currentContext!).marked_star_multiple_item(countMarkStarSuccess);
      _appToast.showToastWithIcon(
          currentOverlayContext!,
          message: message,
          icon: markStarAction == MarkStarAction.unMarkStar
              ? _imagePaths.icUnStar
              : _imagePaths.icStar);
    }
  }

  void moveSelectedMultipleEmailToMailbox(
      List<PresentationEmail> listEmails,
      PresentationMailbox mailboxCurrent
  ) async {
    if (accountId.value != null) {
      final destinationMailbox = await push(
          AppRoutes.DESTINATION_PICKER,
          arguments: DestinationPickerArguments(accountId.value!, MailboxActions.moveEmail));

      if (destinationMailbox != null && destinationMailbox is PresentationMailbox) {
        if (destinationMailbox.isTrash) {
          _moveSelectedEmailMultipleToMailboxAction(accountId.value!, MoveToMailboxRequest(
              listEmails.listEmailIds,
              mailboxCurrent.id,
              destinationMailbox.id,
              MoveAction.moving,
              EmailActionType.moveToTrash));
        } else if (destinationMailbox.isSpam) {
          _moveSelectedEmailMultipleToMailboxAction(accountId.value!, MoveToMailboxRequest(
              listEmails.listEmailIds,
              mailboxCurrent.id,
              destinationMailbox.id,
              MoveAction.moving,
              EmailActionType.moveToSpam));
        } else {
          _moveSelectedEmailMultipleToMailboxAction(accountId.value!, MoveToMailboxRequest(
              listEmails.listEmailIds,
              mailboxCurrent.id,
              destinationMailbox.id,
              MoveAction.moving,
              EmailActionType.moveToMailbox,
              destinationPath: destinationMailbox.mailboxPath));
        }
      }
    }
  }

  void _moveSelectedEmailMultipleToMailboxAction(
      AccountId accountId,
      MoveToMailboxRequest moveRequest
  ) {
    consumeState(_moveMultipleEmailToMailboxInteractor.execute(accountId, moveRequest));
  }

  void _moveSelectedMultipleEmailToMailboxSuccess(Success success) {
    String? destinationPath;
    List<EmailId> movedEmailIds = [];
    MailboxId? currentMailboxId;
    MailboxId? destinationMailboxId;
    MoveAction? moveAction;
    EmailActionType? emailActionType;

    if (success is MoveMultipleEmailToMailboxAllSuccess) {
      destinationPath = success.destinationPath;
      movedEmailIds = success.movedListEmailId;
      currentMailboxId = success.currentMailboxId;
      destinationMailboxId = success.destinationMailboxId;
      moveAction = success.moveAction;
      emailActionType = success.emailActionType;
    } else if (success is MoveMultipleEmailToMailboxHasSomeEmailFailure) {
      destinationPath = success.destinationPath;
      movedEmailIds = success.movedListEmailId;
      currentMailboxId = success.currentMailboxId;
      destinationMailboxId = success.destinationMailboxId;
      moveAction = success.moveAction;
      emailActionType = success.emailActionType;
    }

    if (currentContext != null &&
        currentOverlayContext != null &&
        emailActionType != null &&
        moveAction == MoveAction.moving) {
      _appToast.showToastWithAction(
          currentOverlayContext!,
          emailActionType.getToastMessageMoveToMailboxSuccess(
              currentContext!,
              destinationPath: destinationPath),
          AppLocalizations.of(currentContext!).undo_action,
          () {
            final newCurrentMailboxId = destinationMailboxId;
            final newDestinationMailboxId = currentMailboxId;
            if (newCurrentMailboxId != null && newDestinationMailboxId != null) {
              _revertedSelectionEmailToOriginalMailbox(MoveToMailboxRequest(
                  movedEmailIds,
                  newCurrentMailboxId,
                  newDestinationMailboxId,
                  MoveAction.undo,
                  emailActionType!,
                  destinationPath: destinationPath));
            }
          },
          maxWidth: _responsiveUtils.getMaxWidthToast(currentContext!)
      );
    }
  }

  void _revertedSelectionEmailToOriginalMailbox(MoveToMailboxRequest newMoveRequest) {
    if (accountId.value != null) {
      consumeState(_moveMultipleEmailToMailboxInteractor.execute(
          accountId.value!,
          newMoveRequest));
    }
  }

  void moveSelectedMultipleEmailToTrash(List<PresentationEmail> listEmails, PresentationMailbox mailboxCurrent) {
    final trashMailboxId = getMailboxIdByRole(PresentationMailbox.roleTrash);
    if (accountId.value != null && trashMailboxId != null) {
      _moveSelectedEmailMultipleToMailboxAction(accountId.value!, MoveToMailboxRequest(
          listEmails.listEmailIds,
          mailboxCurrent.id,
          trashMailboxId,
          MoveAction.moving,
          EmailActionType.moveToTrash)
      );
    }
  }

  void moveSelectedMultipleEmailToSpam(List<PresentationEmail> listEmail, PresentationMailbox mailboxCurrent) {
    final spamMailboxId = getMailboxIdByRole(PresentationMailbox.roleSpam);
    if (accountId.value != null && spamMailboxId != null) {
      _moveSelectedEmailMultipleToMailboxAction(accountId.value!, MoveToMailboxRequest(
          listEmail.listEmailIds,
          mailboxCurrent.id,
          spamMailboxId,
          MoveAction.moving,
          EmailActionType.moveToSpam)
      );
    }
  }

  void unSpamSelectedMultipleEmail(List<PresentationEmail> listEmail) {
    final spamMailboxId = getMailboxIdByRole(PresentationMailbox.roleSpam);
    final inboxMailboxId = getMailboxIdByRole(PresentationMailbox.roleInbox);
    if (inboxMailboxId != null && accountId.value != null && spamMailboxId != null) {
      _moveSelectedEmailMultipleToMailboxAction(accountId.value!, MoveToMailboxRequest(
          listEmail.listEmailIds,
          spamMailboxId,
          inboxMailboxId,
          MoveAction.moving,
          EmailActionType.unSpam)
      );
    }
  }

  void deleteSelectionEmailsPermanently(
      BuildContext context,
      DeleteActionType actionType,
      {
        List<PresentationEmail>? listEmails,
        PresentationMailbox? mailboxCurrent,
        Function? onCancelSelectionEmail,
      }
  ) {
    if (_responsiveUtils.isMobile(context)) {
      (ConfirmationDialogActionSheetBuilder(context)
        ..messageText(actionType.getContentDialog(
            context,
            count: listEmails?.length,
            mailboxName: mailboxCurrent?.name?.name))
        ..onCancelAction(AppLocalizations.of(context).cancel, () => popBack())
        ..onConfirmAction(
            actionType.getConfirmActionName(context),
            () => _deleteSelectionEmailsPermanentlyAction(
                actionType,
                listEmails: listEmails,
                onCancelSelectionEmail: onCancelSelectionEmail)))
      .show();
    } else {
      showDialog(
          context: context,
          barrierColor: AppColor.colorDefaultCupertinoActionSheet,
          builder: (BuildContext context) => PointerInterceptor(child: (ConfirmDialogBuilder(_imagePaths)
              ..key(const Key('confirm_dialog_delete_emails_permanently'))
              ..title(actionType.getTitleDialog(context))
              ..content(actionType.getContentDialog(
                  context,
                  count: listEmails?.length,
                  mailboxName: mailboxCurrent?.name?.name))
              ..addIcon(SvgPicture.asset(_imagePaths.icRemoveDialog, fit: BoxFit.fill))
              ..colorConfirmButton(AppColor.colorConfirmActionDialog)
              ..styleTextConfirmButton(const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: AppColor.colorActionDeleteConfirmDialog))
              ..onCloseButtonAction(() => popBack())
              ..onConfirmButtonAction(
                  actionType.getConfirmActionName(context),
                  () => _deleteSelectionEmailsPermanentlyAction(
                      actionType,
                      listEmails: listEmails,
                      onCancelSelectionEmail: onCancelSelectionEmail))
              ..onCancelButtonAction(AppLocalizations.of(context).cancel, () => popBack()))
            .build()));
    }
  }

  void _deleteSelectionEmailsPermanentlyAction(
    DeleteActionType actionType, {
    List<PresentationEmail>? listEmails,
    Function? onCancelSelectionEmail,
  }) {
    popBack();

    switch(actionType) {
      case DeleteActionType.all:
        _emptyTrashFolderAction(onCancelSelectionEmail: onCancelSelectionEmail);
        break;
      case DeleteActionType.multiple:
        _deleteMultipleEmailsPermanently(listEmails ?? [], onCancelSelectionEmail: onCancelSelectionEmail);
        break;
      case DeleteActionType.single:
        break;
    }
  }

  void _emptyTrashFolderAction({Function? onCancelSelectionEmail}) {
    onCancelSelectionEmail?.call();

    final trashMailboxId = mapDefaultMailboxIdByRole[PresentationMailbox.roleTrash];
    if (accountId.value != null && trashMailboxId != null) {
      consumeState(_emptyTrashFolderInteractor.execute(accountId.value!, trashMailboxId));
    }
  }

  void _emptyTrashFolderSuccess(EmptyTrashFolderSuccess success) {
    if (currentContext != null && currentOverlayContext != null) {
      _appToast.showToastWithIcon(
          currentOverlayContext!,
          widthToast: _responsiveUtils.isDesktop(currentContext!) ? 360 : null,
          message: AppLocalizations.of(currentContext!).toast_message_empty_trash_folder_success,
          icon: _imagePaths.icDeleteToast);
    }
  }

  void _deleteMultipleEmailsPermanently(List<PresentationEmail> listEmails, {Function? onCancelSelectionEmail}) {
    onCancelSelectionEmail?.call();

    if (accountId.value != null) {
      consumeState(_deleteMultipleEmailsPermanentlyInteractor.execute(
          accountId.value!,
          listEmails.listEmailIds));
    }
  }

  void _deleteMultipleEmailsPermanentlySuccess(Success success) {
    List<EmailId> listEmailIdResult = <EmailId>[];
    if (success is DeleteMultipleEmailsPermanentlyAllSuccess) {
      listEmailIdResult = success.emailIds;
    } else if (success is DeleteMultipleEmailsPermanentlyHasSomeEmailFailure) {
      listEmailIdResult = success.emailIds;
    }

    if (currentContext != null && currentOverlayContext != null && listEmailIdResult.isNotEmpty) {
      _appToast.showToastWithIcon(
          currentOverlayContext!,
          widthToast: _responsiveUtils.isDesktop(currentContext!) ? 360 : null,
          message: AppLocalizations.of(currentContext!).toast_message_delete_multiple_email_permanently_success(listEmailIdResult.length),
          icon: _imagePaths.icDeleteToast);
    }
  }

  void dispatchAction(UIAction action) {
    log('MailboxDashBoardController::dispatchAction(): ${action.runtimeType}');
    dashBoardAction.value = action;
  }

  void openComposerOverlay(RouterArguments? arguments) {
    routerArguments = arguments;
    ComposerBindings().dependencies();
    composerOverlayState.value = ComposerOverlayState.active;
  }

  void closeComposerOverlay() {
    routerArguments = null;
    ComposerBindings().dispose();
    composerOverlayState.value = ComposerOverlayState.inActive;
  }

  void dispatchRoute(String route) {
    routePath.value = route;

    if (routePath.value == AppRoutes.SEARCH_EMAIL) {
      searchController.enableSearch();
    }
  }

  @override
  void handleReloaded(Session session) {
    sessionCurrent = session;
    accountId.value = sessionCurrent?.accounts.keys.first;
    _getUserProfile();
    _handleComposerCache();
    injectAutoCompleteBindings(sessionCurrent, accountId.value);
    injectVacationBindings(sessionCurrent, accountId.value);
    _getVacationResponse();
  }

  UnsignedInt? get maxSizeAttachmentsPerEmail {
    try {
      if (sessionCurrent != null && accountId.value != null) {
        final mailCapability = sessionCurrent!.getCapabilityProperties<MailCapability>(accountId.value!, CapabilityIdentifier.jmapMail);
        final maxSizeAttachmentsPerEmail = mailCapability.maxSizeAttachmentsPerEmail;
        log('MailboxDashBoardController::maxSizeAttachmentsPerEmail(): $maxSizeAttachmentsPerEmail');
        return maxSizeAttachmentsPerEmail;
      }
      return null;
    } catch (e) {
      logError('MailboxDashBoardController::maxSizeAttachmentsPerEmail(): [Exception] $e');
      return null;
    }
  }

  bool filterMessageWithAttachmentIsActive () {
    return filterMessageOption.value == FilterMessageOption.attachments;
  }

  bool filterMessageUnreadIsActive () {
    return filterMessageOption.value == FilterMessageOption.unread;
  }

  bool filterMessageStarredIsActive () {
    return filterMessageOption.value == FilterMessageOption.starred;
  }

  void markAsReadMailboxAction() {
    final currentAccountId = accountId.value;
    final mailboxId = selectedMailbox.value?.id;
    final mailboxName = selectedMailbox.value?.name;
    final countEmailsUnread = selectedMailbox.value?.unreadEmails?.value.value ?? 0;
    if (currentAccountId != null && mailboxId != null && mailboxName != null) {
      markAsReadMailbox(currentAccountId, mailboxId, mailboxName, countEmailsUnread.toInt());
    }
  }

  void markAsReadMailbox(
      AccountId accountId,
      MailboxId mailboxId,
      MailboxName mailboxName,
      int totalEmailsUnread
  ) {
    consumeState(_markAsMailboxReadInteractor.execute(
        accountId,
        mailboxId,
        mailboxName,
        totalEmailsUnread,
        _progressStateController));
  }

  void _markAsReadMailboxSuccess(Success success) {
    viewStateMarkAsReadMailbox.value = Right(UIState.idle);

    if (success is MarkAsMailboxReadAllSuccess) {
      if (currentContext != null && currentOverlayContext != null) {
        _appToast.showToastWithIcon(
            currentOverlayContext!,
            widthToast: _responsiveUtils.isDesktop(currentContext!) ? 360 : null,
            message: AppLocalizations.of(currentContext!)
                .toastMessageMarkAsMailboxReadSuccess(success.mailboxName.name),
            icon: _imagePaths.icReadToast);
      }
    } else if (success is MarkAsMailboxReadHasSomeEmailFailure) {
      if (currentContext != null && currentOverlayContext != null) {
        _appToast.showToastWithIcon(
            currentOverlayContext!,
            widthToast: _responsiveUtils.isDesktop(currentContext!) ? 360 : null,
            message: AppLocalizations.of(currentContext!)
                .toastMessageMarkAsMailboxReadHasSomeEmailFailure(success.mailboxName.name, success.countEmailsRead),
            icon: _imagePaths.icReadToast);
      }
    }
  }

  void _markAsReadMailboxFailure(Failure failure) {
    viewStateMarkAsReadMailbox.value = Right(UIState.idle);
  }

  void goToComposer(ComposerArguments arguments) {
    if (BuildUtils.isWeb) {
      if (composerOverlayState.value == ComposerOverlayState.inActive) {
        openComposerOverlay(arguments);
      }
    } else {
      push(AppRoutes.COMPOSER, arguments: arguments);
    }
  }

  void clearDashBoardAction() {
    dashBoardAction.value = DashBoardAction.idle;
  }

  void goToSettings() async {
    if (isDrawerOpen) {
      closeMailboxMenuDrawer();
    }
    final result = await push(AppRoutes.MANAGE_ACCOUNT,
        arguments: ManageAccountArguments(sessionCurrent));

    if (result is VacationResponse) {
      vacationResponse.value = result;
    }
  }

  void selectQuickSearchFilter({
    required QuickSearchFilter quickSearchFilter,
    bool fromSuggestionBox = false,
  }) => searchController.selectQuickSearchFilter(
    quickSearchFilter: quickSearchFilter,
    userProfile: userProfile.value!,
    fromSuggestionBox: fromSuggestionBox,
  );

  bool checkQuickSearchFilterSelected({
    required QuickSearchFilter quickSearchFilter,
    bool fromSuggestionBox = false,
  }) => searchController.checkQuickSearchFilterSelected(
      quickSearchFilter: quickSearchFilter,
      userProfile: userProfile.value!,
      fromSuggestionBox: fromSuggestionBox,
  );

  Future<List<PresentationEmail>> quickSearchEmails() => searchController.quickSearchEmails(accountId: accountId.value!);

  void addDownloadTask(DownloadTaskState task) {
    downloadController.addDownloadTask(task);
  }

  void updateDownloadTask(
      DownloadTaskId taskId,
      UpdateDownloadTaskStateCallback updateDownloadTaskCallback
  ) {
    downloadController.updateDownloadTaskByTaskId(
        taskId,
        updateDownloadTaskCallback);
  }

  void deleteDownloadTask(DownloadTaskId taskId) {
    downloadController.deleteDownloadTask(taskId);
  }

  void disableVacationResponder() {
    if (accountId.value != null && _updateVacationInteractor != null) {
      final vacationDisabled = vacationResponse.value != null
          ? vacationResponse.value!.copyWith(isEnabled: false)
          : VacationResponse(isEnabled: false);
      consumeState(_updateVacationInteractor!.execute(accountId.value!, vacationDisabled));
    }
  }

  void goToVacationSetting() async {
    final result = await push(AppRoutes.MANAGE_ACCOUNT,
        arguments: ManageAccountArguments(
            sessionCurrent,
            menuSettingCurrent: AccountMenuItem.vacation));

    if (result is VacationResponse) {
      vacationResponse.value = result;
    }
  }

  void _handleUpdateVacationSuccess(UpdateVacationSuccess success) {
    if (success.listVacationResponse.isNotEmpty) {
      if (currentContext != null && currentOverlayContext != null) {
        _appToast.showToastWithIcon(
            currentOverlayContext!,
            message: AppLocalizations.of(currentContext!).yourVacationResponderIsDisabledSuccessfully,
            icon: _imagePaths.icChecked);
      }
      vacationResponse.value = success.listVacationResponse.first;
      log('MailboxDashBoardController::_handleUpdateVacationSuccess(): $vacationResponse');
    }
  }

  void selectQuickSearchFilterAction(QuickSearchFilter filter) {
    selectQuickSearchFilter(quickSearchFilter: filter);
    dispatchAction(StartSearchEmailAction());
  }

  void selectReceiveTimeQuickSearchFilter(EmailReceiveTimeType? emailReceiveTimeType) {
    popBack();

    if (emailReceiveTimeType != null) {
      searchController.updateFilterEmail(emailReceiveTimeType: emailReceiveTimeType);
    } else {
      searchController.updateFilterEmail(emailReceiveTimeType: EmailReceiveTimeType.allTime);
    }
    searchController.setEmailReceiveTimeType(emailReceiveTimeType);
    searchController.updateFilterEmail();
    if (searchController.searchQuery == null){
      searchController.updateFilterEmail(text: SearchQuery.initial());
    }
    dispatchAction(StartSearchEmailAction());
  }

  bool get isMailboxTrash => selectedMailbox.value?.isTrash == true;

  void emptyTrashAction(BuildContext context) {
    dispatchAction(EmptyTrashAction(context));
  }

  @override
  void onClose() {
    _emailReceiveManager.closeEmailReceiveManagerStream();
    _emailReceiveManagerStreamSubscription.cancel();
    _fileReceiveManagerStreamSubscription.cancel();
    _connectivityStreamSubscription.cancel();
    _progressStateController.close();
    Get.delete<DownloadController>();
    super.onClose();
  }
}