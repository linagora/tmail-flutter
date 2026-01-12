import 'dart:async';

import 'package:core/domain/extensions/datetime_extension.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/bottom_popup/confirmation_dialog_action_sheet_builder.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:labels/model/label.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/mark_star_action.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/email/read_actions.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:model/extensions/list_email_address_extension.dart';
import 'package:model/extensions/presentation_email_extension.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/base/mixin/message_dialog_action_manager.dart';
import 'package:tmail_ui_user/features/base/widget/context_menu/context_menu_item_action.dart';
import 'package:tmail_ui_user/features/base/widget/popup_menu/popup_menu_action_group_widget.dart';
import 'package:tmail_ui_user/features/base/widget/popup_menu/popup_submenu_controller.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/model/destination_picker_arguments.dart';
import 'package:tmail_ui_user/features/email/domain/model/email_print.dart';
import 'package:tmail_ui_user/features/email/domain/model/mark_read_action.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_action.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_to_mailbox_request.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_email_content_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/print_email_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_email_content_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_email_read_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_star_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/print_email_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/presentation_email_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/model/context_item_email_action.dart';
import 'package:tmail_ui_user/features/email/presentation/model/email_loaded.dart';
import 'package:tmail_ui_user/features/email/presentation/model/email_unsubscribe.dart';
import 'package:tmail_ui_user/features/email/presentation/model/popup_menu_item_email_action.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_address_bottom_sheet_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_address_dialog_builder.dart';
import 'package:tmail_ui_user/features/labels/presentation/widgets/label_item_context_menu.dart';
import 'package:tmail_ui_user/features/labels/presentation/widgets/label_list_context_menu.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/create_new_email_rule_filter_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/create_new_email_rule_filter_interactor.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/model/rules_filter_creator_arguments.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/delete_action_type.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/dialog_router.dart';
import 'package:tmail_ui_user/main/routes/navigation_router.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

typedef OpenBottomSheetContextMenuAction = Future<void> Function({
  required BuildContext context,
  required List<ContextMenuItemAction> itemActions,
  required OnContextMenuActionClick onContextMenuActionClick,
  Key? key,
  bool useGroupedActions,
});

typedef OpenPopupMenuActionGroup = Future<void> Function(
  BuildContext context,
  RelativeRect position,
  PopupMenuActionGroupWidget popupMenuWidget,
);

class EmailActionReactor {
  EmailActionReactor(
    this._markAsEmailReadInteractor,
    this._markAsStarEmailInteractor,
    this._createNewEmailRuleFilterInteractor,
    this._printEmailInteractor,
    this._getEmailContentInteractor,
  );

  final MarkAsEmailReadInteractor _markAsEmailReadInteractor;
  final MarkAsStarEmailInteractor _markAsStarEmailInteractor;
  final CreateNewEmailRuleFilterInteractor? _createNewEmailRuleFilterInteractor;
  final PrintEmailInteractor _printEmailInteractor;
  final GetEmailContentInteractor _getEmailContentInteractor;

  static final _isEmailAddressDialogOpened = false.obs;
  static bool get isDialogOpened => _isEmailAddressDialogOpened.value;

  Stream<Either<Failure, Success>> markAsEmailRead(
    Session session,
    AccountId accountId,
    PresentationEmail presentationEmail, {
    required ReadActions readAction,
  }) {
    return _markAsEmailReadInteractor.execute(
      session,
      accountId,
      presentationEmail.id!,
      readAction,
      MarkReadAction.tap,
      presentationEmail.mailboxContain?.mailboxId,
    );
  }

  Stream<Either<Failure, Success>> markAsStarEmail(
    Session session,
    AccountId accountId,
    PresentationEmail presentationEmail, {
    required MarkStarAction markStarAction,
  }) {
    return _markAsStarEmailInteractor.execute(
      session,
      accountId,
      presentationEmail.id!,
      markStarAction,
    );
  }

  Future<({
    MoveToMailboxRequest moveRequest,
    Map<EmailId, bool> emailIdsWithReadStatus
  })?> moveToMailbox(
    Session session,
    AccountId accountId,
    PresentationEmail presentationEmail, {
    required Map<MailboxId, PresentationMailbox> mapMailbox,
    required PresentationMailbox? selectedMailbox,
    required bool isSearchEmailRunning,
  }) async {
    final moveRequest = await _moveToMailbox(
      session,
      accountId,
      presentationEmail,
      mapMailbox: mapMailbox,
      isSearchEmailRunning: isSearchEmailRunning,
      selectedMailbox: selectedMailbox,
    );
    if (moveRequest == null) return null;

    return (
      moveRequest: moveRequest.moveRequest,
      emailIdsWithReadStatus: moveRequest.emailIdsWithReadStatus,
    );
  }

  ({
    MoveToMailboxRequest moveRequest,
    Map<EmailId, bool> emailIdsWithReadStatus
  })? moveToTrash(
    PresentationEmail presentationEmail, {
    required Map<MailboxId, PresentationMailbox> mapMailbox,
    required PresentationMailbox? selectedMailbox,
    required bool isSearchEmailRunning,
    required Map<Role, MailboxId> mapDefaultMailboxIdByRole,
  }) {
    final trashMailboxId = mapDefaultMailboxIdByRole[
      PresentationMailbox.roleTrash
    ];
    final currentMailbox = _getMailboxContain(
      presentationEmail,
      mapMailbox: mapMailbox,
      isSearchEmailRunning: isSearchEmailRunning,
      selectedMailbox: selectedMailbox,
    );
    if (trashMailboxId == null || currentMailbox == null) return null;

    return (
      moveRequest: MoveToMailboxRequest(
        {currentMailbox.id: [presentationEmail.id!]},
        trashMailboxId,
        MoveAction.moving,
        EmailActionType.moveToTrash),
      emailIdsWithReadStatus: {presentationEmail.id!: presentationEmail.hasRead},
    );
  }

  void deleteEmailPermanently(
    PresentationEmail presentationEmail, {
    required void Function(PresentationEmail email) onDeleteEmailRequest,
    required ResponsiveUtils responsiveUtils,
    required ImagePaths imagePaths,
  }) async {
    if (currentContext == null || !currentContext!.mounted) return;
    if (responsiveUtils.isMobile(currentContext!)) {
      await (ConfirmationDialogActionSheetBuilder(currentContext!)
        ..messageText(DeleteActionType.single.getContentDialog(currentContext!))
        ..onCancelAction(AppLocalizations.of(currentContext!).cancel, () => popBack())
        ..onConfirmAction(
          DeleteActionType.single.getConfirmActionName(currentContext!),
          () => onDeleteEmailRequest.call(presentationEmail)
        )
      ).show();
    } else {
      await MessageDialogActionManager().showConfirmDialogAction(
        key: const Key('confirm_dialog_delete_email_permanently'),
        currentContext!,
        title: DeleteActionType.single.getTitleDialog(currentContext!),
        DeleteActionType.single.getContentDialog(currentContext!),
        DeleteActionType.single.getConfirmActionName(currentContext!),
        cancelTitle: AppLocalizations.of(currentContext!).cancel,
        onConfirmAction: () => onDeleteEmailRequest.call(presentationEmail),
        onCloseButtonAction: popBack,
      );
    }
  }

  ({
    MoveToMailboxRequest moveRequest,
    Map<EmailId, bool> emailIdsWithReadStatus
  })? moveToSpam(
    PresentationEmail presentationEmail, {
    required Map<MailboxId, PresentationMailbox> mapMailbox,
    required PresentationMailbox? selectedMailbox,
    required bool isSearchEmailRunning,
    required Map<Role, MailboxId> mapDefaultMailboxIdByRole,
  }) {
    final spamMailboxId = _spamMailboxId(mapDefaultMailboxIdByRole);
    final currentMailbox = _getMailboxContain(
      presentationEmail,
      mapMailbox: mapMailbox,
      isSearchEmailRunning: isSearchEmailRunning,
      selectedMailbox: selectedMailbox,
    );
    if (spamMailboxId == null || currentMailbox == null) return null;

    return (
      moveRequest: MoveToMailboxRequest(
        {currentMailbox.id: [presentationEmail.id!]},
        spamMailboxId,
        MoveAction.moving,
        EmailActionType.moveToSpam),
      emailIdsWithReadStatus: {presentationEmail.id!: presentationEmail.hasRead},
    );
  }

  ({
    MoveToMailboxRequest moveRequest,
    Map<EmailId, bool> emailIdsWithReadStatus
  })? unSpam(
    PresentationEmail presentationEmail, {
    required Map<MailboxId, PresentationMailbox> mapMailbox,
    required PresentationMailbox? selectedMailbox,
    required bool isSearchEmailRunning,
    required Map<Role, MailboxId> mapDefaultMailboxIdByRole,
  }) {
    final spamMailboxId = _spamMailboxId(mapDefaultMailboxIdByRole);
    final inboxMailboxId = mapDefaultMailboxIdByRole[
      PresentationMailbox.roleInbox
    ];
    if (spamMailboxId == null || inboxMailboxId == null) return null;

    return (
      moveRequest: MoveToMailboxRequest(
        {spamMailboxId: [presentationEmail.id!]},
        inboxMailboxId,
        MoveAction.moving,
        EmailActionType.unSpam
      ),
      emailIdsWithReadStatus: {presentationEmail.id!: presentationEmail.hasRead},
    );
  }

  MailboxId? _spamMailboxId(
    Map<Role, MailboxId> mapDefaultMailboxIdByRole
  ) {
    return mapDefaultMailboxIdByRole[
      PresentationMailbox.roleSpam
    ] ?? mapDefaultMailboxIdByRole[
      PresentationMailbox.roleJunk
    ];
  }

  Stream<Either<Failure, Success>> quickCreateRule(
    Session session,
    AccountId accountId, {
    required EmailAddress? emailAddress,
  }) async* {
    Get.back();
    final arguments = RulesFilterCreatorArguments(
      accountId,
      session,
      emailAddress: emailAddress,
    );

    final newRuleFilterRequest = PlatformInfo.isWeb
      ? await DialogRouter().pushGeneralDialog(
          routeName: AppRoutes.rulesFilterCreator,
          arguments: arguments,
        )
      : await push(AppRoutes.rulesFilterCreator, arguments: arguments);

    if (newRuleFilterRequest is! CreateNewEmailRuleFilterRequest) return;

    yield* _createNewEmailRuleFilterInteractor?.execute(
      accountId,
      newRuleFilterRequest
    ) ?? const Stream.empty();
  }

  Future<void> unsubscribeEmail(
    PresentationEmail presentationEmail, {
    required EmailUnsubscribe? emailUnsubscribe,
    required void Function(EmailId emailId) onUnsubscribeByHttpsLink,
    required void Function(
      EmailId emailId,
      NavigationRouter navigationRouter,
    ) onUnsubscribeByMailtoLink,
  }) async {
    if (currentContext == null || !currentContext!.mounted) return;

    await MessageDialogActionManager().showConfirmDialogAction(
      currentContext!,
      '',
      AppLocalizations.of(currentContext!).unsubscribe,
      onConfirmAction: () {
        if (emailUnsubscribe?.httpLinks.isNotEmpty == true) {
          onUnsubscribeByHttpsLink(presentationEmail.id!);
          AppUtils.launchLink(emailUnsubscribe!.httpLinks.first);
        } else if (emailUnsubscribe?.mailtoLinks.isNotEmpty == true) {
          final navigationRouter = RouteUtils.generateNavigationRouterFromMailtoLink(
            emailUnsubscribe!.mailtoLinks.first,
          );
          onUnsubscribeByMailtoLink(presentationEmail.id!, navigationRouter);
        }
      },
      showAsBottomSheet: true,
      title: AppLocalizations.of(currentContext!).unsubscribeMail,
      listTextSpan: [
        TextSpan(text: AppLocalizations.of(currentContext!).unsubscribeMailDialogMessage),
        TextSpan(
          text: ' ${presentationEmail.getSenderName()}',
          style: ThemeUtils.textStyleBodyBody2(
            color: AppColor.steelGray400,
            fontWeight: FontWeight.w700,
          ),
        ),
        const TextSpan(text: ' ?'),
      ]
    );
  }

  void archiveMessage(
    PresentationEmail presentationEmail, {
    required void Function(
      PresentationEmail presentationEmail,
    ) onArchiveEmailRequest,  
  }) => onArchiveEmailRequest(presentationEmail);

  Stream<Either<Failure, Success>> printEmail(
    PresentationEmail presentationEmail, {
    required String ownEmailAddress,
    required EmailLoaded? emailLoaded,
    Session? session,
    AccountId? accountId,
    String? baseDownloadUrl,
    TransformConfiguration? transformConfiguration,
  }) async* {
    try {
      emailLoaded ??= await _getEmailLoaded(
        session,
        accountId,
        presentationEmail.id,
        baseDownloadUrl,
        transformConfiguration,
      );
      
      if (emailLoaded == null) {
        yield Left(PrintEmailFailure());
        return;
      }
    } catch (e) {
      yield Left(PrintEmailFailure(exception: e));
      return;
    }

    if (currentContext == null || !currentContext!.mounted) return;
    final locale = Localizations.localeOf(currentContext!);
    final appLocalizations = AppLocalizations.of(currentContext!);

    yield* _printEmailInteractor.execute(
      EmailPrint(
        appName: appLocalizations.app_name,
        userName: ownEmailAddress,
        attachments: emailLoaded.attachments,
        emailContent: emailLoaded.htmlContent,
        fromPrefix: appLocalizations.from_email_address_prefix,
        toPrefix: appLocalizations.to_email_address_prefix,
        ccPrefix: appLocalizations.cc_email_address_prefix,
        bccPrefix: appLocalizations.bcc_email_address_prefix,
        replyToPrefix: appLocalizations.replyToEmailAddressPrefix,
        titleAttachment: emailLoaded.attachments.length > 1
          ? appLocalizations.attachments.toLowerCase()
          : appLocalizations.attachment.toLowerCase(),
        toAddress: presentationEmail.to?.listEmailAddressToString(isFullEmailAddress: true),
        ccAddress: presentationEmail.cc?.listEmailAddressToString(isFullEmailAddress: true),
        bccAddress: presentationEmail.bcc?.listEmailAddressToString(isFullEmailAddress: true),
        replyToAddress: presentationEmail.replyTo?.listEmailAddressToString(isFullEmailAddress: true),
        sender: presentationEmail.from?.isNotEmpty == true
          ? presentationEmail.from!.first
          : null,
        receiveTime: presentationEmail.getReceivedAt(
          locale.toLanguageTag(),
          pattern: presentationEmail.receivedAt
            ?.value
            .toLocal()
            .toPatternForPrinting(locale.toLanguageTag()),
        ),
        subject: presentationEmail.subject,
      )
    );
  }
   
  void editAsNewEmail(
    PresentationEmail presentationEmail, {
    required void Function(
      PresentationEmail presentationEmail,
    ) onEditAsEmailRequest,  
  }) => onEditAsEmailRequest(presentationEmail);

  void replyEmail(
    PresentationEmail presentationEmail, {
    required void Function(
      PresentationEmail presentationEmail,
      EmailLoaded? emailLoaded,
    ) onReplyEmailRequest,
    required EmailLoaded? emailLoaded,
  }) {
    onReplyEmailRequest(presentationEmail, emailLoaded);
  }

  void replyAll(
    PresentationEmail presentationEmail, {
    required void Function(
      PresentationEmail presentationEmail,
      EmailLoaded? emailLoaded,
    ) onReplyAllRequest,
    required EmailLoaded? emailLoaded,
  }) {
    onReplyAllRequest(presentationEmail, emailLoaded);
  }

  void replyToList(
    PresentationEmail presentationEmail, {
    required void Function(
      PresentationEmail presentationEmail,
      EmailLoaded? emailLoaded,
    ) onReplyToListRequest,
    required EmailLoaded? emailLoaded,
  }) {
    onReplyToListRequest(presentationEmail, emailLoaded);
  }

  void forward(
    PresentationEmail presentationEmail, {
    required void Function(
      PresentationEmail presentationEmail,
      EmailLoaded? emailLoaded,
    ) onForwardRequest,
    required EmailLoaded? emailLoaded,
  }) {
    onForwardRequest(presentationEmail, emailLoaded);
  }

  void handleMoreEmailAction({
    required PresentationEmail presentationEmail,
    required PresentationMailbox? mailboxContain,
    required RelativeRect? position,
    required ResponsiveUtils responsiveUtils,
    required ImagePaths imagePaths,
    required String ownEmailAddress,
    required void Function(
      PresentationEmail presentationEmail,
      EmailActionType action,
    ) handleEmailAction,
    required List<EmailActionType> additionalActions,
    required bool emailIsRead,
    required bool isLabelAvailable,
    required OpenBottomSheetContextMenuAction openBottomSheetContextMenu,
    required OpenPopupMenuActionGroup openPopupMenu,
    List<Label>? labels,
    OnSelectLabelAction? onSelectLabelAction,
  }) {
    if (currentContext == null) return;

    final moreActions = [
      if (additionalActions.contains(EmailActionType.reply))
        EmailActionType.reply,
      if (additionalActions.contains(EmailActionType.forward))
        EmailActionType.forward,
      if (presentationEmail.getCountMailAddressWithoutMe(ownEmailAddress) > 1 &&
          additionalActions.contains(EmailActionType.replyAll))
        EmailActionType.replyAll,
      if (EmailUtils.isReplyToListEnabled(presentationEmail.listPost ?? '') &&
          additionalActions.contains(EmailActionType.replyToList))
        EmailActionType.replyToList,
      if (isLabelAvailable)
        EmailActionType.labelAs,
      if (PlatformInfo.isWeb &&
          PlatformInfo.isCanvasKit &&
          additionalActions.contains(EmailActionType.printAll))
        EmailActionType.printAll,
      if (additionalActions.contains(EmailActionType.moveToMailbox))
        EmailActionType.moveToMailbox,
      if (additionalActions.contains(EmailActionType.markAsStarred) &&
          additionalActions.contains(EmailActionType.unMarkAsStarred))
        presentationEmail.hasStarred
          ? EmailActionType.unMarkAsStarred
          : EmailActionType.markAsStarred,
      if (additionalActions.contains(EmailActionType.moveToTrash) &&
          additionalActions.contains(EmailActionType.deletePermanently))
        _canDeletePermanently(presentationEmail, mailboxContain)
          ? EmailActionType.deletePermanently
          : EmailActionType.moveToTrash,
      if (emailIsRead)
        EmailActionType.markAsUnread
      else
        EmailActionType.markAsRead,
      if (mailboxContain?.isChildOfTeamMailboxes == false)
        if (mailboxContain?.isSpam == true)
          EmailActionType.unSpam
        else
          EmailActionType.moveToSpam,
      if (presentationEmail.from?.isNotEmpty == true)
        EmailActionType.createRule,
      if (!presentationEmail.isSubscribed && presentationEmail.listUnsubscribe != null)
        EmailActionType.unsubscribe,
      if (mailboxContain?.isArchive == false)
        EmailActionType.archiveMessage,
      if (PlatformInfo.isWeb && PlatformInfo.isCanvasKit)
        EmailActionType.downloadMessageAsEML,
      EmailActionType.editAsNewEmail,
    ];

    if (position == null) {
      openBottomSheetContextMenu(
        context: currentContext!,
        itemActions: moreActions
            .map(
              (action) => ContextItemEmailAction(
                action,
                AppLocalizations.of(currentContext!),
                imagePaths,
                key: '${action.name}_action',
                category: action.category,
              ),
            )
            .toList(),
        onContextMenuActionClick: (action) {
          popBack();
          handleEmailAction(presentationEmail, action.action);
        },
        useGroupedActions: true,
      );
    } else {
      final submenuController = PopupSubmenuController();

      final popupMenuItemEmailActions = moreActions.map((actionType) {
        return PopupMenuItemEmailAction(
          actionType,
          AppLocalizations.of(currentContext!),
          imagePaths,
          key: '${actionType.name}_action',
          category: actionType.category,
          submenu: _getEmailActionSubmenu(
            actionType: actionType,
            imagePaths: imagePaths,
            presentationEmail: presentationEmail,
            labels: labels,
            onSelectLabelAction: (label, isSelected) {
              onSelectLabelAction?.call(label, isSelected);
              submenuController.hide();
              popBack();
            },
          ),
        );
      }).toList();

      final popupMenuWidget = PopupMenuActionGroupWidget(
        actions: popupMenuItemEmailActions,
        submenuController: submenuController,
        onActionSelected: (action) {
          if (_shouldHandleAction(action.action)) {
            handleEmailAction(presentationEmail, action.action);
          }
        },
      );

      openPopupMenu(
        currentContext!,
        position,
        popupMenuWidget,
      ).whenComplete(submenuController.hide);
    }
  }

  bool _shouldHandleAction(EmailActionType action) {
    if (action != EmailActionType.labelAs) {
      return true;
    }

    return PlatformInfo.isWebTouchDevice || PlatformInfo.isMobile;
  }

  Widget? _getEmailActionSubmenu({
    required EmailActionType actionType,
    required ImagePaths imagePaths,
    required PresentationEmail presentationEmail,
    required List<Label>? labels,
    OnSelectLabelAction? onSelectLabelAction,
  }) {
    if (actionType == EmailActionType.labelAs && labels?.isNotEmpty == true) {
      final listLabels = labels ?? [];
      final emailLabels = presentationEmail.getLabelList(listLabels);

      return LabelListContextMenu(
        labelList: listLabels,
        emailLabels: emailLabels,
        imagePaths: imagePaths,
        onSelectLabelAction: (label, isSelected) =>
            onSelectLabelAction?.call(label, isSelected),
      );
    }
    return null;
  }

  bool _canDeletePermanently(
    PresentationEmail email,
    PresentationMailbox? mailboxContain,
  ) {
    return mailboxContain?.isTrash
      ?? mailboxContain?.isSpam
      ?? email.mailboxContain?.isTrash
      ?? email.mailboxContain?.isSpam
      ?? false;
  }

  Future<void> openEmailAddressDialog(
    Session session,
    AccountId accountId, {
    required EmailAddress emailAddress,
    required ResponsiveUtils responsiveUtils,
    required ImagePaths imagePaths,
    required AppToast appToast,
    required void Function(EmailAddress emailAddress) onComposeEmailFromEmailAddressRequest,
    required void Function(Stream<Either<Failure, Success>> quickCreateRuleStream) onQuickCreateRuleRequest,
  }) async {
    if (currentContext?.mounted != true) return;
    if (PlatformInfo.isWeb) {
      _isEmailAddressDialogOpened.value = true;
    }

    if (responsiveUtils.isScreenWithShortestSide(currentContext!)) {
      await Get.bottomSheet(
        EmailAddressBottomSheetBuilder(
          imagePaths: imagePaths,
          emailAddress: emailAddress,
          onCloseDialogAction: popBack,
          onCopyEmailAddressAction: (emailAddress) =>
              _copyEmailAddress(currentContext!, emailAddress, appToast),
          onComposeEmailAction: (emailAddress) =>
              onComposeEmailFromEmailAddressRequest(emailAddress),
          onQuickCreatingRuleEmailDialogAction: (emailAddress) =>
              onQuickCreateRuleRequest(
            quickCreateRule(session, accountId, emailAddress: emailAddress),
          ),
        ),
        useRootNavigator: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadiusDirectional.only(
            topStart: Radius.circular(16.0),
            topEnd: Radius.circular(16.0),
          ),
        ),
        isScrollControlled: true,
        enableDrag: true,
        backgroundColor: Colors.transparent,
      );
    } else {
      await Get.dialog(
        EmailAddressDialogBuilder(
          imagePaths: imagePaths,
          emailAddress: emailAddress,
          onCloseDialogAction: popBack,
          onCopyEmailAddressAction: (emailAddress) =>
              _copyEmailAddress(currentContext!, emailAddress, appToast),
          onComposeEmailAction: (emailAddress) =>
              onComposeEmailFromEmailAddressRequest(emailAddress),
          onQuickCreatingRuleEmailDialogAction: (emailAddress) =>
              onQuickCreateRuleRequest(
            quickCreateRule(session, accountId, emailAddress: emailAddress),
          ),
        ),
        barrierColor: AppColor.colorDefaultCupertinoActionSheet,
      );
    }

    _isEmailAddressDialogOpened.value = false;
  }

  void _copyEmailAddress(
    BuildContext context,
    EmailAddress emailAddress,
    AppToast appToast,
  ) {
    Clipboard.setData(ClipboardData(text: emailAddress.emailAddress));
    appToast.showToastSuccessMessage(
      context,
      AppLocalizations.of(context).email_address_copied_to_clipboard,
    );
  }

  Future<({
    Map<EmailId, bool> emailIdsWithReadStatus,
    MoveToMailboxRequest moveRequest,
  })?> _moveToMailbox(
    Session session,
    AccountId accountId,
    PresentationEmail presentationEmail, {
    required Map<MailboxId, PresentationMailbox> mapMailbox,
    PresentationMailbox? selectedMailbox,
    bool isSearchEmailRunning = false,
  }) async {
    final currentMailbox = _getMailboxContain(
      presentationEmail,
      mapMailbox: mapMailbox,
      selectedMailbox: selectedMailbox,
      isSearchEmailRunning: isSearchEmailRunning,
    );

    if (currentMailbox == null) return null;

    final arguments = DestinationPickerArguments(
      accountId,
      MailboxActions.moveEmail,
      session,
      mailboxIdSelected: currentMailbox.mailboxId
    );

    final destinationMailbox = PlatformInfo.isWeb
      ? await DialogRouter().pushGeneralDialog(routeName: AppRoutes.destinationPicker, arguments: arguments)
      : await push(AppRoutes.destinationPicker, arguments: arguments);

    if (destinationMailbox is PresentationMailbox) {
      return _generateMoveMailboxRequest(
        accountId,
        session,
        presentationEmail,
        currentMailbox,
        destinationMailbox,
      );
    }

    return null;
  }

  PresentationMailbox? _getMailboxContain(
    PresentationEmail presentationEmail, {
    required Map<MailboxId, PresentationMailbox> mapMailbox,
    PresentationMailbox? selectedMailbox,
    bool isSearchEmailRunning = false,
  }) {
    if (selectedMailbox == null ||
        isSearchEmailRunning ||
        selectedMailbox.isFavorite == true) {
      return presentationEmail.findMailboxContain(mapMailbox);
    }

    return selectedMailbox;
  }

  ({
    MoveToMailboxRequest moveRequest,
    Map<EmailId, bool> emailIdsWithReadStatus,
  }) _generateMoveMailboxRequest(
    AccountId accountId,
    Session session,
    PresentationEmail emailSelected,
    PresentationMailbox currentMailbox,
    PresentationMailbox destinationMailbox
  ) {
    if (destinationMailbox.isTrash) {
      return (
        moveRequest: MoveToMailboxRequest(
          {currentMailbox.id: [emailSelected.id!]},
          destinationMailbox.id,
          MoveAction.moving,
          EmailActionType.moveToTrash,
        ), 
        emailIdsWithReadStatus: {emailSelected.id!: emailSelected.hasRead},
      );
    } else if (destinationMailbox.isSpam) {
      return (
        moveRequest: MoveToMailboxRequest(
          {currentMailbox.id: [emailSelected.id!]},
          destinationMailbox.id,
          MoveAction.moving,
          EmailActionType.moveToSpam,
        ), 
        emailIdsWithReadStatus: {emailSelected.id!: emailSelected.hasRead},
      );
    } else {
      return (
        moveRequest: MoveToMailboxRequest(
          {currentMailbox.id: [emailSelected.id!]},
          destinationMailbox.id,
          MoveAction.moving,
          EmailActionType.moveToMailbox,
          destinationPath: destinationMailbox.mailboxPath),
        emailIdsWithReadStatus: {emailSelected.id!: emailSelected.hasRead},
      );
    }
  }

  Future<EmailLoaded?> _getEmailLoaded(
    Session? session,
    AccountId? accountId,
    EmailId? emailId,
    String? baseDownloadUrl,
    TransformConfiguration? transformConfiguration,
  ) async {
    if (session == null ||
        accountId == null ||
        emailId == null ||
        baseDownloadUrl == null ||
        transformConfiguration == null
    ) {
      return Future.value(null);
    }

    final result = await _getEmailContentInteractor.execute(
      session,
      accountId,
      emailId,
      baseDownloadUrl,
      transformConfiguration,
    ).last;

    return result.fold(
      (failure) {
        if (failure is FeatureFailure) {
          throw failure.exception;
        }

        return null;
      },
      (success) {
        if (success is! GetEmailContentSuccess) {
          return null;
        }

        return EmailLoaded(
          htmlContent: success.htmlEmailContent,
          attachments: List.of(success.attachments ?? []),
          inlineImages: List.of(success.inlineImages ?? []),
          emailCurrent: success.emailCurrent,
        );
      },
    );
  }
}