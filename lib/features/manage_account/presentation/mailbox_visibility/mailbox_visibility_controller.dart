import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/base/base_mailbox_controller.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_subscribe_action_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_subscribe_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/subscribe_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/get_all_mailboxes_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/refresh_changes_all_mailboxes_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/subscribe_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/get_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/refresh_all_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/domain/usecases/subscribe_mailbox_interactor.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_categories.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_categories_expand_mode.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree_builder.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class MailboxVisibilityController extends BaseMailboxController {
  GetAllMailboxInteractor? _getAllMailboxInteractor;
  RefreshAllMailboxInteractor? _refreshAllMailboxInteractor;
  SubscribeMailboxInteractor? _subscribeMailboxInteractor;
  final _accountDashBoardController = Get.find<ManageAccountDashBoardController>();
  final _appToast = Get.find<AppToast>();
  final _imagePaths = Get.find<ImagePaths>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();
  final mailboxCategoriesExpandMode = MailboxCategoriesExpandMode.initial().obs;
  final mailboxListScrollController = ScrollController();

  Map<Role, MailboxId> mapDefaultMailboxIdByRole = {};
  Map<MailboxId, PresentationMailbox> mapMailboxById = {};
  PresentationMailbox? outboxMailbox;

  jmap.State? _currentMailboxState;

  MailboxVisibilityController(
    TreeBuilder treeBuilder,
    VerifyNameInteractor verifyNameInteractor,
  ) : super(treeBuilder, verifyNameInteractor);

  @override
  void onInit() {
    super.onInit();
    try {
      _getAllMailboxInteractor = Get.find<GetAllMailboxInteractor>();
      _refreshAllMailboxInteractor = Get.find<RefreshAllMailboxInteractor>();
      _subscribeMailboxInteractor = Get.find<SubscribeMailboxInteractor>();
    } catch (e) {
      logError('MailboxVisibilityController::onInit(): ${e.toString()}');
    }
  }

  @override
  void onDone() {
    viewState.value.fold((failure) {}, (success) {
      if (success is GetAllMailboxSuccess) {
        _currentMailboxState = success.currentMailboxState;
        _buildMailboxTreeHasSubscribed(success.mailboxList);
      } else if (success is RefreshChangesAllMailboxSuccess) {
        _currentMailboxState = success.currentMailboxState;
        _refreshMailboxTreeHasSubscribed(success.mailboxList);
      } else if (success is SubscribeMailboxSuccess) {
        _subscribeMailboxSuccess(success);
      }
    });

  }

  @override
  void onReady() {
    final _session = _accountDashBoardController.sessionCurrent.value;
    final _accountId = _accountDashBoardController.accountId.value;
    if(_session != null && _accountId != null) {
      getAllMailboxAction(_session, _accountId);
    }
    super.onReady();
  }

  void getAllMailboxAction(Session session, AccountId accountId) async {
    if(_getAllMailboxInteractor != null){
      consumeState(_getAllMailboxInteractor!.execute(session, accountId));
    }
  }

  void refreshMailboxChanges({jmap.State? currentMailboxState}) {
    log('MailboxVisibilityController::refreshMailboxChanges(): currentMailboxState: $currentMailboxState');
    final newMailboxState = currentMailboxState ?? _currentMailboxState;
    log('MailboxVisibilityController::refreshMailboxChanges(): newMailboxState: $newMailboxState');
    final session = _accountDashBoardController.sessionCurrent.value;
    final accountId = _accountDashBoardController.accountId.value;
    if (accountId != null && session != null && newMailboxState != null) {
      consumeState(_refreshAllMailboxInteractor!.execute(session, accountId, newMailboxState));
    }
  }

  void _buildMailboxTreeHasSubscribed(List<PresentationMailbox> mailboxList) async {
    final _mailboxList = mailboxList;
    await buildTree(_mailboxList);
  }

  void _refreshMailboxTreeHasSubscribed(List<PresentationMailbox> mailboxList) async {
    final _mailboxList = mailboxList;
    await refreshTree(_mailboxList);
  }

  void subscribeMailbox(MailboxNode mailboxNode) {
    final _mailboxSubscribeState = mailboxNode.item.isSubscribedMailbox
      ? MailboxSubscribeState.disabled : MailboxSubscribeState.enabled;
    final _mailboxSubscribeStateAction = mailboxNode.item.isSubscribedMailbox
      ? MailboxSubscribeAction.unSubscribe : MailboxSubscribeAction.subscribe;
    if (mailboxNode.item.isSubscribedMailbox) {
      _subscribeMailboxAction(
          SubscribeMailboxRequest(
              mailboxNode.item.id,
              _mailboxSubscribeState,
              _mailboxSubscribeStateAction,
          )
      );
    }
  }

  void _subscribeMailboxAction(SubscribeMailboxRequest subscribeMailboxRequest) {
    final _accountId = _accountDashBoardController.accountId.value;
    if (_accountId != null) {
      consumeState(_subscribeMailboxInteractor!.execute(_accountId, subscribeMailboxRequest));
    }
  }

  void toggleMailboxCategories(MailboxCategories categories) {
    switch(categories) {
      case MailboxCategories.exchange:
        final newExpandMode = mailboxCategoriesExpandMode.value.defaultMailbox == ExpandMode.EXPAND ? ExpandMode.COLLAPSE : ExpandMode.EXPAND;
        mailboxCategoriesExpandMode.value.defaultMailbox = newExpandMode;
        mailboxCategoriesExpandMode.refresh();
        break;
      case MailboxCategories.personalMailboxes:
        final newExpandMode = mailboxCategoriesExpandMode.value.personalMailboxes == ExpandMode.EXPAND ? ExpandMode.COLLAPSE : ExpandMode.EXPAND;
        mailboxCategoriesExpandMode.value.personalMailboxes = newExpandMode;
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
      _appToast.showBottomToast(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).toastMsgHideMailboxSuccess,
          actionName: AppLocalizations.of(currentContext!).undo,
          onActionClick: () {
            _subscribeMailboxAction(
              SubscribeMailboxRequest(
                subscribeMailboxSuccess.mailboxId,
                MailboxSubscribeState.enabled,
                MailboxSubscribeAction.undo)
            );
          },
          leadingIcon: SvgPicture.asset(
            _imagePaths.icFolderMailbox,
            width: 24,
            height: 24,
            color: Colors.white,
            fit: BoxFit.fill),
          backgroundColor: AppColor.toastSuccessBackgroundColor,
          textColor: Colors.white,
          textActionColor: Colors.white,
          actionIcon: SvgPicture.asset(_imagePaths.icUndo),
          maxWidth: _responsiveUtils.getMaxWidthToast(currentContext!));
    }

    refreshMailboxChanges(currentMailboxState: subscribeMailboxSuccess.currentMailboxState);
  }
}
