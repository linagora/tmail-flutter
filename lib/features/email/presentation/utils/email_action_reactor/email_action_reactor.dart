import 'dart:async';

import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/domain/extensions/datetime_extension.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/bottom_popup/confirmation_dialog_action_sheet_builder.dart';
import 'package:core/presentation/views/dialog/confirmation_dialog_builder.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/download/download_task_id.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/mark_star_action.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/email/read_actions.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:model/extensions/list_email_address_extension.dart';
import 'package:model/extensions/presentation_email_extension.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/base/mixin/message_dialog_action_mixin.dart';
import 'package:tmail_ui_user/features/base/mixin/popup_context_menu_action_mixin.dart';
import 'package:tmail_ui_user/features/base/widget/popup_item_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/email_action_type_extension.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/model/destination_picker_arguments.dart';
import 'package:tmail_ui_user/features/email/domain/exceptions/email_exceptions.dart';
import 'package:tmail_ui_user/features/email/domain/model/email_print.dart';
import 'package:tmail_ui_user/features/email/domain/model/mark_read_action.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_action.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_to_mailbox_request.dart';
import 'package:tmail_ui_user/features/email/domain/state/download_attachment_for_web_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_email_content_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/download_attachment_for_web_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_email_content_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_email_read_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_star_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/print_email_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/model/email_loaded.dart';
import 'package:tmail_ui_user/features/email/presentation/model/email_unsubscribe.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_action_cupertino_action_sheet_action_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_address_bottom_sheet_builder.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_address_dialog_builder.dart';
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
import 'package:uuid/uuid.dart';

class EmailActionReactor with MessageDialogActionMixin, PopupContextMenuActionMixin {
  const EmailActionReactor(
    this._markAsEmailReadInteractor,
    this._markAsStarEmailInteractor,
    this._createNewEmailRuleFilterInteractor,
    this._printEmailInteractor,
    this._getEmailContentInteractor,
    this._downloadAttachmentForWebInteractor,
  );

  final MarkAsEmailReadInteractor _markAsEmailReadInteractor;
  final MarkAsStarEmailInteractor _markAsStarEmailInteractor;
  final CreateNewEmailRuleFilterInteractor? _createNewEmailRuleFilterInteractor;
  final PrintEmailInteractor _printEmailInteractor;
  final GetEmailContentInteractor _getEmailContentInteractor;
  final DownloadAttachmentForWebInteractor _downloadAttachmentForWebInteractor;

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
      await Get.dialog(
        PointerInterceptor(child: ConfirmationDialogBuilder(
          key: const Key('confirm_dialog_delete_email_permanently'),
          imagePath: imagePaths,
          title: DeleteActionType.single.getTitleDialog(currentContext!),
          textContent: DeleteActionType.single.getContentDialog(currentContext!),
          cancelText: DeleteActionType.single.getConfirmActionName(currentContext!),
          confirmText: AppLocalizations.of(currentContext!).cancel,
          onCancelButtonAction: () => onDeleteEmailRequest.call(presentationEmail),
          onConfirmButtonAction: popBack,
          onCloseButtonAction: popBack,
        )),
        barrierColor: AppColor.colorDefaultCupertinoActionSheet,
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
    final arguments = RulesFilterCreatorArguments(
      accountId,
      session,
      emailAddress: emailAddress,
    );

    final newRuleFilterRequest = PlatformInfo.isWeb
      ? await DialogRouter.pushGeneralDialog(
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

    await showConfirmDialogAction(
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
    VoidCallback? onGetEmailContentFailure,
    Session? session,
    AccountId? accountId,
    String? baseDownloadUrl,
    TransformConfiguration? transformConfiguration,
  }) async* {
    emailLoaded ??= await _getEmailLoaded(
      session,
      accountId,
      presentationEmail.id,
      baseDownloadUrl,
      transformConfiguration,
    );
    
    if (emailLoaded == null) {
      onGetEmailContentFailure?.call();
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
        titleAttachment: appLocalizations.attachments.toLowerCase(),
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

  Stream<Either<Failure, Success>> downloadMessageAsEML(
    Session session,
    AccountId accountId,
    PresentationEmail presentationEmail, {
    required StreamController<Either<Failure, Success>> downloadProgressStateController,
  }) async* {
    final emlAttachment = presentationEmail.createEMLAttachment();
    if (emlAttachment.blobId == null) {
      yield* Stream.value(Left(DownloadAttachmentForWebFailure(
        exception: NotFoundEmailBlobIdException(),
      )));
      return;
    }

    final generateTaskId = DownloadTaskId(const Uuid().v4());
    try {
      final baseDownloadUrl = session.getDownloadUrl(
        jmapUrl: getBinding<DynamicUrlInterceptors>()?.jmapUrl,
      );
      final cancelToken = CancelToken();
      yield* _downloadAttachmentForWebInteractor.execute(
        generateTaskId,
        emlAttachment,
        accountId,
        baseDownloadUrl,
        downloadProgressStateController,
        cancelToken: cancelToken,
        previewerSupported: false,
      );
    } catch (e) {
      logError('SingleEmailController::downloadAttachmentForWeb(): $e');
      yield* Stream.value(Left(DownloadAttachmentForWebFailure(
        attachment: emlAttachment,
        taskId: generateTaskId,
        exception: e,
      )));
    }
  }
   
  void editAsNewEmail(
    PresentationEmail presentationEmail, {
    required void Function(
      PresentationEmail presentationEmail,
    ) onEditAsEmailRequest,  
  }) => onEditAsEmailRequest(presentationEmail);

  Future<void> replyEmail(
    PresentationEmail presentationEmail, {
    required void Function(
      PresentationEmail presentationEmail,
      EmailLoaded? emailLoaded,
    ) onReplyEmailRequest,
    required EmailLoaded? emailLoaded,
  }) async {
    onReplyEmailRequest(presentationEmail, emailLoaded);
  }

  Future<void> replyAll(
    PresentationEmail presentationEmail, {
    required void Function(
      PresentationEmail presentationEmail,
      EmailLoaded? emailLoaded,
    ) onReplyAllRequest,
    required EmailLoaded? emailLoaded,
  }) async {
    onReplyAllRequest(presentationEmail, emailLoaded);
  }

  Future<void> replyToList(
    PresentationEmail presentationEmail, {
    required void Function(
      PresentationEmail presentationEmail,
      EmailLoaded? emailLoaded,
    ) onReplyToListRequest,
    required EmailLoaded? emailLoaded,
  }) async {
    onReplyToListRequest(presentationEmail, emailLoaded);
  }

  Future<void> forward(
    PresentationEmail presentationEmail, {
    required void Function(
      PresentationEmail presentationEmail,
      EmailLoaded? emailLoaded,
    ) onForwardRequest,
    required EmailLoaded? emailLoaded,
  }) async {
    onForwardRequest(presentationEmail, emailLoaded);
  }

  Future<void> handleMoreEmailAction({
    required PresentationEmail presentationEmail,
    required PresentationMailbox? mailboxContain,
    required RelativeRect? position,
    required ResponsiveUtils responsiveUtils,
    required ImagePaths imagePaths,
    required UserName? username,
    required void Function(
      PresentationEmail presentationEmail,
      EmailActionType action,
    ) handleEmailAction,
    required List<EmailActionType> additionalActions,
  }) async {
    if (currentContext == null) return;

    final moreActions = [
      if (additionalActions.contains(EmailActionType.forward))
        EmailActionType.forward,
      if (presentationEmail.getCountMailAddressWithoutMe(username?.value ?? '') > 1 &&
          additionalActions.contains(EmailActionType.replyAll))
        EmailActionType.replyAll,
      if (EmailUtils.isReplyToListEnabled(presentationEmail.listPost ?? '') &&
          additionalActions.contains(EmailActionType.replyToList))
        EmailActionType.replyToList,
      if (PlatformInfo.isWeb &&
          PlatformInfo.isCanvasKit &&
          additionalActions.contains(EmailActionType.printAll))
        EmailActionType.printAll,
      if (additionalActions.contains(EmailActionType.moveToMailbox))
        EmailActionType.moveToMailbox,
      if (!responsiveUtils.isDesktop(currentContext!)) ...[
        presentationEmail.hasStarred
          ? EmailActionType.unMarkAsStarred
          : EmailActionType.markAsStarred,
        _canDeletePermanently(presentationEmail)
          ? EmailActionType.deletePermanently
          : EmailActionType.moveToTrash,
      ],
      if (additionalActions.contains(EmailActionType.markAsStarred) &&
          additionalActions.contains(EmailActionType.unMarkAsStarred))
        presentationEmail.hasStarred
          ? EmailActionType.unMarkAsStarred
          : EmailActionType.markAsStarred,
      EmailActionType.markAsUnread,
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
      openContextMenuAction(
        currentContext!,
        _emailActionMoreActionTile(
          currentContext!,
          presentationEmail,
          moreActions,
          responsiveUtils,
          imagePaths,
          handleEmailAction: handleEmailAction,
        )
      );
    } else {
      Get.dialog(
        PointerInterceptor(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => popBack(),
            child: Container(color: Colors.transparent),
          ),
        ),
        barrierColor: Colors.transparent,
      );
      await openPopupMenuAction(
        currentContext!,
        position,
        _popupMenuEmailActionTile(
          currentContext!,
          presentationEmail,
          moreActions,
          imagePaths,
          handleEmailAction: handleEmailAction,
        )
      );
      popBack();
    }
  }

  bool _canDeletePermanently(PresentationEmail email) {
    return email.mailboxContain?.isTrash
      ?? email.mailboxContain?.isSpam
      ?? false;
  }

  List<Widget> _emailActionMoreActionTile(
    BuildContext context,
    PresentationEmail presentationEmail,
    List<EmailActionType> actionTypes,
    ResponsiveUtils responsiveUtils,
    ImagePaths imagePaths, {
    required void Function(
      PresentationEmail presentationEmail,
      EmailActionType action,
    ) handleEmailAction
  }) {
    return actionTypes.map((action) {
      return (EmailActionCupertinoActionSheetActionBuilder(
        Key('${action.name}_action'),
        SvgPicture.asset(
          action.getIcon(imagePaths),
          width: 24,
          height: 24,
          fit: BoxFit.fill,
          colorFilter: AppColor.colorTextButton.asFilter()
        ),
        action.getTitle(AppLocalizations.of(context)),
        presentationEmail,
        iconLeftPadding: responsiveUtils.isScreenWithShortestSide(context)
          ? const EdgeInsetsDirectional.only(start: 12, end: 16)
          : const EdgeInsetsDirectional.only(end: 12),
        iconRightPadding: responsiveUtils.isScreenWithShortestSide(context)
          ? const EdgeInsetsDirectional.only(end: 12)
          : EdgeInsets.zero
      )
      ..onActionClick((presentationEmail) {
        popBack();
        handleEmailAction(presentationEmail, action);
      })).build();
    }).toList();
  }

  List<PopupMenuEntry> _popupMenuEmailActionTile(
    BuildContext context,
    PresentationEmail presentationEmail,
    List<EmailActionType> actionTypes,
    ImagePaths imagePaths, {
    required void Function(
      PresentationEmail presentationEmail,
      EmailActionType action,
    ) handleEmailAction,
  }) {
    return actionTypes.map((action) {
      return PopupMenuItem(
        key: Key('${action.name}_action'),
        padding: EdgeInsets.zero,
        child: PopupItemWidget(
          iconAction: action.getIcon(imagePaths),
          nameAction: action.getTitle(AppLocalizations.of(context)),
          colorIcon: AppColor.colorTextButton,
          padding: const EdgeInsetsDirectional.only(start: 12),
          styleName: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: Colors.black
          ),
          onCallbackAction: () {
            popBack();
            handleEmailAction(presentationEmail, action);
          }
        )
      );
    }).toList();
  }

  void openEmailAddressDialog(
    Session session,
    AccountId accountId, {
    required EmailAddress emailAddress,
    required ResponsiveUtils responsiveUtils,
    required ImagePaths imagePaths,
    required void Function(EmailAddress emailAddress) onComposeEmailFromEmailAddressRequest,
  }) {
    if (currentContext?.mounted != true) return;

    if (responsiveUtils.isScreenWithShortestSide(currentContext!)) {
      (EmailAddressBottomSheetBuilder(currentContext!, imagePaths, emailAddress)
        ..addOnCloseContextMenuAction(() => popBack())
        ..addOnCopyEmailAddressAction((emailAddress) => _copyEmailAddress(
          currentContext!,
          emailAddress,
        ))
        ..addOnComposeEmailAction((emailAddress) => onComposeEmailFromEmailAddressRequest(emailAddress))
        ..addOnQuickCreatingRuleEmailBottomSheetAction((emailAddress) => quickCreateRule(
          session,
          accountId,
          emailAddress: emailAddress
        ))
      ).show();
    } else {
      Get.dialog(
        PointerInterceptor(
          child: EmailAddressDialogBuilder(
            emailAddress,
            onCloseDialogAction: () => popBack(),
            onCopyEmailAddressAction: (emailAddress) => _copyEmailAddress(
              currentContext!,
              emailAddress,
            ),
            onComposeEmailAction: (emailAddress) => onComposeEmailFromEmailAddressRequest(emailAddress),
            onQuickCreatingRuleEmailDialogAction: (emailAddress) => quickCreateRule(
              session,
              accountId,
              emailAddress: emailAddress,
            )
          )
        ),
        barrierColor: AppColor.colorDefaultCupertinoActionSheet,
      );
    }
  }

  void _copyEmailAddress(BuildContext context, EmailAddress emailAddress) {
    popBack();
    AppUtils.copyEmailAddressToClipboard(context, emailAddress.emailAddress);
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
      ? await DialogRouter.pushGeneralDialog(routeName: AppRoutes.destinationPicker, arguments: arguments)
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
    if (selectedMailbox == null || isSearchEmailRunning) {
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
  ) {
    if (session == null ||
        accountId == null ||
        emailId == null ||
        baseDownloadUrl == null ||
        transformConfiguration == null
    ) {
      return Future.value(null);
    }

    return _getEmailContentInteractor
      .execute(
        session,
        accountId,
        emailId,
        baseDownloadUrl,
        transformConfiguration,
      )
      .last
      .then(
        (value) {
          return value.fold(
            (failure) => null,
            (success) => success is GetEmailContentSuccess
              ? EmailLoaded(
                  htmlContent: success.htmlEmailContent,
                  attachments: List.of(success.attachments ?? []),
                  inlineImages: List.of(success.inlineImages ?? []),
                  emailCurrent: success.emailCurrent,
                )
              : null,
          );
        },
        onError: (error) {
          logError('EmailActionReactor::_getEmailLoaded(): error: $error');
          return null;
        },
      );
  }
}