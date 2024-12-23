import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/base/base_mailbox_controller.dart';
import 'package:tmail_ui_user/features/mailbox/domain/constants/mailbox_constants.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_subscribe_action_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_subscribe_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/subscribe_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/subscribe_multiple_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/get_all_mailboxes_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/refresh_changes_all_mailboxes_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/subscribe_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/subscribe_multiple_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/get_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/refresh_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/subscribe_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/subscribe_multiple_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_categories.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree_builder.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/mailbox_visibility/state/mailbox_visibility_state.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class MailboxVisibilityController extends BaseMailboxController {
  SubscribeMailboxInteractor? _subscribeMailboxInteractor;
  SubscribeMultipleMailboxInteractor? _subscribeMultipleMailboxInteractor;
  final _accountDashBoardController = Get.find<ManageAccountDashBoardController>();
  final mailboxListScrollController = ScrollController();

  MailboxVisibilityController(
    TreeBuilder treeBuilder,
    VerifyNameInteractor verifyNameInteractor,
    GetAllMailboxInteractor getAllMailboxInteractor,
    RefreshAllMailboxInteractor refreshAllMailboxInteractor
  ) : super(
    treeBuilder,
    verifyNameInteractor,
    getAllMailboxInteractor: getAllMailboxInteractor,
    refreshAllMailboxInteractor: refreshAllMailboxInteractor
  );

  @override
  void onInit() {
    super.onInit();
    try {
      _subscribeMailboxInteractor = Get.find<SubscribeMailboxInteractor>();
      _subscribeMultipleMailboxInteractor = Get.find<SubscribeMultipleMailboxInteractor>();
    } catch (e) {
      logError('MailboxVisibilityController::onInit(): ${e.toString()}');
    }
  }

  @override
  void handleSuccessViewState(Success success) async {
    super.handleSuccessViewState(success);
    if (success is GetAllMailboxSuccess)  {
      currentMailboxState = success.currentMailboxState;
      _handleBuildTree(success.mailboxList);
    } else if (success is RefreshChangesAllMailboxSuccess) {
      currentMailboxState = success.currentMailboxState;
      await refreshTree(success.mailboxList);
      if (currentContext != null) {
        syncAllMailboxWithDisplayName(currentContext!);
      }
    } else if (success is SubscribeMailboxSuccess) {
      _subscribeMailboxSuccess(success);
    } else if (success is SubscribeMultipleMailboxAllSuccess) {
      _handleUnsubscribeMultipleMailboxAllSuccess(success);
    } else if (success is SubscribeMultipleMailboxHasSomeSuccess) {
      _handleUnsubscribeMultipleMailboxHasSomeSuccess(success);
    }
  }

  @override
  void onReady() {
    final session = _accountDashBoardController.sessionCurrent;
    final accountId = _accountDashBoardController.accountId.value;
    if(session != null && accountId != null) {
      getAllMailbox(session, accountId);
    }
    super.onReady();
  }

  void _handleBuildTree(List<PresentationMailbox> mailboxList) async {
    dispatchState(Right(LoadingBuildTreeMailboxVisibility()));
    await buildTree(mailboxList);
    dispatchState(Right(BuildTreeMailboxVisibilitySuccess()));
    if (currentContext != null) {
      syncAllMailboxWithDisplayName(currentContext!);
    }
  }

  void subscribeMailbox(MailboxNode mailboxNode) {
    final mailboxSubscribeState = mailboxNode.item.isSubscribedMailbox
      ? MailboxSubscribeState.disabled : MailboxSubscribeState.enabled;
    final mailboxSubscribeStateAction = mailboxNode.item.isSubscribedMailbox
      ? MailboxSubscribeAction.unSubscribe : MailboxSubscribeAction.subscribe;
    _subscribeMailboxAction(
        SubscribeMailboxRequest(
          mailboxNode.item.id,
          mailboxSubscribeState,
          mailboxSubscribeStateAction,
        )
    );
  }

  void _subscribeMailboxAction(SubscribeMailboxRequest subscribeMailboxRequest) {
    final accountId = _accountDashBoardController.accountId.value;
    final session = _accountDashBoardController.sessionCurrent;
    if (session != null && accountId != null) {
      final subscribeRequest = generateSubscribeRequest(
        subscribeMailboxRequest.mailboxId,
        subscribeMailboxRequest.subscribeState,
        subscribeMailboxRequest.subscribeAction
      );

      if (subscribeRequest is SubscribeMultipleMailboxRequest) {
        consumeState(_subscribeMultipleMailboxInteractor!.execute(session, accountId, subscribeRequest));
      } else if (subscribeRequest is SubscribeMailboxRequest) {
        consumeState(_subscribeMailboxInteractor!.execute(session, accountId, subscribeRequest));
      }
    }
  }

  void toggleMailboxCategories(MailboxCategories categories) {
    switch(categories) {
      case MailboxCategories.exchange:
        final newExpandMode = mailboxCategoriesExpandMode.value.defaultMailbox == ExpandMode.EXPAND ? ExpandMode.COLLAPSE : ExpandMode.EXPAND;
        mailboxCategoriesExpandMode.value.defaultMailbox = newExpandMode;
        mailboxCategoriesExpandMode.refresh();
        break;
      case MailboxCategories.personalFolders:
        final newExpandMode = mailboxCategoriesExpandMode.value.personalFolders == ExpandMode.EXPAND ? ExpandMode.COLLAPSE : ExpandMode.EXPAND;
        mailboxCategoriesExpandMode.value.personalFolders = newExpandMode;
        mailboxCategoriesExpandMode.refresh();
        break;
      case MailboxCategories.teamMailboxes:
        final newExpandMode = mailboxCategoriesExpandMode.value.teamMailboxes == ExpandMode.EXPAND ? ExpandMode.COLLAPSE : ExpandMode.EXPAND;
        mailboxCategoriesExpandMode.value.teamMailboxes = newExpandMode;
        mailboxCategoriesExpandMode.refresh();
        break;
      case MailboxCategories.appGrid:
        break;
    }
  }

  void _subscribeMailboxSuccess(SubscribeMailboxSuccess subscribeMailboxSuccess) {
    if (subscribeMailboxSuccess.subscribeAction == MailboxSubscribeAction.unSubscribe
        && currentOverlayContext != null
        && currentContext != null) {
        _showToastSubscribeMailboxSuccess(subscribeMailboxSuccess.mailboxId);
    }

    _refreshMailboxChanges(
      newMailboxState: subscribeMailboxSuccess.currentMailboxState,
      properties: MailboxConstants.propertiesDefault
    );
  }

  void _handleUnsubscribeMultipleMailboxHasSomeSuccess(SubscribeMultipleMailboxHasSomeSuccess subscribeMailboxSuccess) {
    if(subscribeMailboxSuccess.subscribeAction == MailboxSubscribeAction.unSubscribe) {
      _showToastSubscribeMailboxSuccess(
        subscribeMailboxSuccess.parentMailboxId,
        listDescendantMailboxIds: subscribeMailboxSuccess.mailboxIdsSubscribe
      );
    }

    _refreshMailboxChanges(
      newMailboxState: subscribeMailboxSuccess.currentMailboxState,
      properties: MailboxConstants.propertiesDefault
    );
  }

  void _handleUnsubscribeMultipleMailboxAllSuccess(SubscribeMultipleMailboxAllSuccess subscribeMailboxSuccess) {
    if(subscribeMailboxSuccess.subscribeAction == MailboxSubscribeAction.unSubscribe) {
      _showToastSubscribeMailboxSuccess(
          subscribeMailboxSuccess.parentMailboxId,
          listDescendantMailboxIds: subscribeMailboxSuccess.mailboxIdsSubscribe
      );
    }

    _refreshMailboxChanges(
      newMailboxState: subscribeMailboxSuccess.currentMailboxState,
      properties: MailboxConstants.propertiesDefault
    );
  }

  void _refreshMailboxChanges({jmap.State? newMailboxState, Properties? properties}) {
    final session = _accountDashBoardController.sessionCurrent;
    final accountId = _accountDashBoardController.accountId.value;
    final mailboxState = newMailboxState ?? currentMailboxState;
    if (session != null && accountId != null && mailboxState != null) {
      refreshMailboxChanges(
        session,
        accountId,
        mailboxState,
        properties: properties
      );
    }
  }

  void _showToastSubscribeMailboxSuccess(
      MailboxId mailboxIdSubscribed,
      {List<MailboxId>? listDescendantMailboxIds}
  ) {
    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).toastMsgHideFolderSuccess,
        actionName: AppLocalizations.of(currentContext!).undo,
        onActionClick: () => _subscribeMailboxAction(
          SubscribeMailboxRequest(
            mailboxIdSubscribed,
            MailboxSubscribeState.enabled,
            MailboxSubscribeAction.subscribe
          )
        ),
        leadingSVGIconColor: Colors.white,
        leadingSVGIcon: imagePaths.icFolderMailbox,
        backgroundColor: AppColor.toastSuccessBackgroundColor,
        textColor: Colors.white,
        actionIcon: SvgPicture.asset(imagePaths.icUndo),
      );
    }
  }

  @override
  void onClose() {
    mailboxListScrollController.dispose();
    super.onClose();
  }
}
