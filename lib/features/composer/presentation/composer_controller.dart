
import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:rich_text_composer/rich_text_composer.dart';
import 'package:super_tag_editor/tag_editor.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/base/state/button_state.dart';
import 'package:tmail_ui_user/features/composer/domain/exceptions/compose_email_exception.dart';
import 'package:tmail_ui_user/features/composer/domain/model/contact_suggestion_source.dart';
import 'package:tmail_ui_user/features/composer/domain/state/download_image_as_base64_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/generate_email_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/get_autocomplete_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/get_device_contact_suggestions_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/save_email_as_drafts_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/send_email_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/update_email_drafts_state.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/create_new_and_save_email_to_drafts_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/create_new_and_send_email_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/download_image_as_base64_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_all_autocomplete_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_autocomplete_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_device_contact_suggestions_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/save_composer_cache_on_web_interactor.dart';
import 'package:tmail_ui_user/features/composer/presentation/controller/rich_text_mobile_tablet_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/controller/rich_text_web_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/email_action_type_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/list_identities_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/list_shared_media_file_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/mixin/drag_drog_file_mixin.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/create_email_request.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/draggable_email_address.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/inline_image.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/prefix_recipient_state.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/screen_display_mode.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/composer_style.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/mobile/from_composer_bottom_sheet_builder.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/saving_message_dialog_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/sending_message_dialog_view.dart';
import 'package:tmail_ui_user/features/email/domain/exceptions/email_exceptions.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_email_content_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/transform_html_email_content_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_email_content_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/transform_html_email_content_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/remove_composer_cache_on_web_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/draggable_app_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_all_identities_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_identities_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/identity_extension.dart';
import 'package:tmail_ui_user/features/network_connection/presentation/network_connection_controller.dart'
  if (dart.library.html) 'package:tmail_ui_user/features/network_connection/presentation/web_network_connection_controller.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/model/sending_email.dart';
import 'package:tmail_ui_user/features/server_settings/domain/state/get_always_read_receipt_setting_state.dart';
import 'package:tmail_ui_user/features/server_settings/domain/usecases/get_always_read_receipt_setting_interactor.dart';
import 'package:tmail_ui_user/features/upload/domain/exceptions/pick_file_exception.dart';
import 'package:tmail_ui_user/features/upload/domain/extensions/list_file_info_extension.dart';
import 'package:tmail_ui_user/features/upload/domain/extensions/file_info_extension.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';
import 'package:tmail_ui_user/features/upload/domain/state/attachment_upload_state.dart';
import 'package:tmail_ui_user/features/upload/domain/state/local_file_picker_state.dart';
import 'package:tmail_ui_user/features/upload/domain/state/local_image_picker_state.dart';
import 'package:tmail_ui_user/features/upload/domain/usecases/local_file_picker_interactor.dart';
import 'package:tmail_ui_user/features/upload/domain/usecases/local_image_picker_interactor.dart';
import 'package:tmail_ui_user/features/upload/presentation/controller/upload_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:universal_html/html.dart' as html;

class ComposerController extends BaseController with DragDropFileMixin {

  final mailboxDashBoardController = Get.find<MailboxDashBoardController>();
  final richTextMobileTabletController = Get.find<RichTextMobileTabletController>();
  final networkConnectionController = Get.find<NetworkConnectionController>();
  final _dynamicUrlInterceptors = Get.find<DynamicUrlInterceptors>();

  final composerArguments = Rxn<ComposerArguments>();
  final isEnableEmailSendButton = false.obs;
  final isInitialRecipient = false.obs;
  final subjectEmail = Rxn<String>();
  final screenDisplayMode = ScreenDisplayMode.normal.obs;
  final toAddressExpandMode = ExpandMode.EXPAND.obs;
  final ccAddressExpandMode = ExpandMode.EXPAND.obs;
  final bccAddressExpandMode = ExpandMode.EXPAND.obs;
  final emailContentsViewState = Rxn<Either<Failure, Success>>();
  final hasRequestReadReceipt = false.obs;
  final fromRecipientState = PrefixRecipientState.disabled.obs;
  final ccRecipientState = PrefixRecipientState.disabled.obs;
  final bccRecipientState = PrefixRecipientState.disabled.obs;
  final identitySelected = Rxn<Identity>();
  final listFromIdentities = RxList<Identity>();

  final LocalFilePickerInteractor _localFilePickerInteractor;
  final LocalImagePickerInteractor _localImagePickerInteractor;
  final GetEmailContentInteractor _getEmailContentInteractor;
  final GetAllIdentitiesInteractor _getAllIdentitiesInteractor;
  final UploadController uploadController;
  final RemoveComposerCacheOnWebInteractor _removeComposerCacheOnWebInteractor;
  final SaveComposerCacheOnWebInteractor _saveComposerCacheOnWebInteractor;
  final RichTextWebController richTextWebController;
  final DownloadImageAsBase64Interactor _downloadImageAsBase64Interactor;
  final TransformHtmlEmailContentInteractor _transformHtmlEmailContentInteractor;
  final GetAlwaysReadReceiptSettingInteractor _getAlwaysReadReceiptSettingInteractor;
  final CreateNewAndSendEmailInteractor _createNewAndSendEmailInteractor;
  final CreateNewAndSaveEmailToDraftsInteractor _createNewAndSaveEmailToDraftsInteractor;

  GetAllAutoCompleteInteractor? _getAllAutoCompleteInteractor;
  GetAutoCompleteInteractor? _getAutoCompleteInteractor;
  GetDeviceContactSuggestionsInteractor? _getDeviceContactSuggestionsInteractor;

  List<EmailAddress> listToEmailAddress = <EmailAddress>[];
  List<EmailAddress> listCcEmailAddress = <EmailAddress>[];
  List<EmailAddress> listBccEmailAddress = <EmailAddress>[];
  ContactSuggestionSource _contactSuggestionSource = ContactSuggestionSource.tMailContact;

  final subjectEmailInputController = TextEditingController();
  final toEmailAddressController = TextEditingController();
  final ccEmailAddressController = TextEditingController();
  final bccEmailAddressController = TextEditingController();
  final searchIdentitiesInputController = TextEditingController();

  final GlobalKey<TagsEditorState> keyToEmailTagEditor = GlobalKey<TagsEditorState>();
  final GlobalKey<TagsEditorState> keyCcEmailTagEditor = GlobalKey<TagsEditorState>();
  final GlobalKey<TagsEditorState> keyBccEmailTagEditor = GlobalKey<TagsEditorState>();
  final GlobalKey headerEditorMobileWidgetKey = GlobalKey();
  final GlobalKey<DropdownButton2State> identityDropdownKey = GlobalKey<DropdownButton2State>();
  final double defaultPaddingCoordinateYCursorEditor = 8;

  FocusNode? subjectEmailInputFocusNode;
  FocusNode? toAddressFocusNode;
  FocusNode? ccAddressFocusNode;
  FocusNode? bccAddressFocusNode;
  FocusNode? searchIdentitiesFocusNode;

  StreamSubscription<html.Event>? _subscriptionOnBeforeUnload;
  StreamSubscription<html.Event>? _subscriptionOnDragEnter;
  StreamSubscription<html.Event>? _subscriptionOnDragOver;
  StreamSubscription<html.Event>? _subscriptionOnDragLeave;
  StreamSubscription<html.Event>? _subscriptionOnDrop;

  final RichTextController keyboardRichTextController = RichTextController();

  final ScrollController scrollController = ScrollController();
  final ScrollController scrollControllerEmailAddress = ScrollController();
  final ScrollController scrollControllerAttachment = ScrollController();
  final ScrollController scrollControllerIdentities = ScrollController();

  List<Attachment> initialAttachments = <Attachment>[];
  String? _textEditorWeb;
  String? _initTextEditor;
  double? maxWithEditor;
  EmailId? _emailIdEditing;
  bool isAttachmentCollapsed = false;
  ButtonState _closeComposerButtonState = ButtonState.enabled;
  ButtonState _saveToDraftButtonState = ButtonState.enabled;
  ButtonState _sendButtonState = ButtonState.enabled;

  late Worker uploadInlineImageWorker;
  late Worker dashboardViewStateWorker;
  late bool _isEmailBodyLoaded;

  ComposerController(
    this._localFilePickerInteractor,
    this._localImagePickerInteractor,
    this._getEmailContentInteractor,
    this._getAllIdentitiesInteractor,
    this.uploadController,
    this._removeComposerCacheOnWebInteractor,
    this._saveComposerCacheOnWebInteractor,
    this.richTextWebController,
    this._downloadImageAsBase64Interactor,
    this._transformHtmlEmailContentInteractor,
    this._getAlwaysReadReceiptSettingInteractor,
    this._createNewAndSendEmailInteractor,
    this._createNewAndSaveEmailToDraftsInteractor,
  );

  @override
  void onInit() {
    super.onInit();
    createFocusNodeInput();
    scrollControllerEmailAddress.addListener(_scrollControllerEmailAddressListener);
    _listenStreamEvent();
    if (PlatformInfo.isWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _listenBrowserTabRefresh();
      });
    }
    _getAlwaysReadReceiptSetting();
  }

  @override
  void onReady() {
    _initEmail();
    if (PlatformInfo.isMobile) {
      Future.delayed(const Duration(milliseconds: 500), _checkContactPermission);
    }
    super.onReady();
  }

  @override
  void onClose() {
    _initTextEditor = null;
    _subscriptionOnBeforeUnload?.cancel();
    _subscriptionOnDragEnter?.cancel();
    _subscriptionOnDragOver?.cancel();
    _subscriptionOnDragLeave?.cancel();
    _subscriptionOnDrop?.cancel();
    super.onClose();
  }

  @override
  void dispose() {
    subjectEmailInputFocusNode?.dispose();
    subjectEmailInputFocusNode = null;
    toAddressFocusNode?.dispose();
    toAddressFocusNode = null;
    ccAddressFocusNode?.dispose();
    ccAddressFocusNode = null;
    bccAddressFocusNode?.dispose();
    bccAddressFocusNode = null;
    searchIdentitiesFocusNode?.dispose();
    searchIdentitiesFocusNode = null;
    subjectEmailInputController.dispose();
    toEmailAddressController.dispose();
    ccEmailAddressController.dispose();
    bccEmailAddressController.dispose();
    uploadInlineImageWorker.dispose();
    dashboardViewStateWorker.dispose();
    keyboardRichTextController.dispose();
    scrollController.dispose();
    scrollControllerEmailAddress.removeListener(_scrollControllerEmailAddressListener);
    scrollControllerEmailAddress.dispose();
    scrollControllerAttachment.dispose();
    scrollControllerIdentities.dispose();
    super.dispose();
  }

  @override
  void handleSuccessViewState(Success success) {
    super.handleSuccessViewState(success);
    if (success is GetEmailContentLoading ||
        success is TransformHtmlEmailContentLoading ||
        success is TransformHtmlEmailContentSuccess) {
      emailContentsViewState.value = Right(success);
    } else if (success is LocalFilePickerSuccess) {
      _handlePickFileSuccess(success);
    } else if (success is LocalImagePickerSuccess) {
      _handlePickImageSuccess(success);
    } else if (success is GetEmailContentSuccess) {
      _getEmailContentSuccess(success);
    } else if (success is GetEmailContentFromCacheSuccess) {
      _getEmailContentOffLineSuccess(success);
    } else if (success is GetAllIdentitiesSuccess) {
      _handleGetAllIdentitiesSuccess(success);
    } else if (success is DownloadImageAsBase64Success) {
      final inlineImage = InlineImage(fileInfo: success.fileInfo, base64Uri: success.base64Uri);
      if (PlatformInfo.isWeb) {
        richTextWebController.insertImage(inlineImage);
      } else {
        richTextMobileTabletController.insertImage(inlineImage);
      }
      maxWithEditor = null;
    } else if (success is GetAlwaysReadReceiptSettingSuccess) {
      hasRequestReadReceipt.value = success.alwaysReadReceiptEnabled;
    }
  }

  @override
  void handleFailureViewState(Failure failure) {
    super.handleFailureViewState(failure);
    if (failure is LocalFilePickerFailure) {
      _handlePickFileFailure(failure);
    } else if (failure is LocalImagePickerFailure) {
      _handlePickImageFailure(failure);
    } else if (failure is GetEmailContentFailure ||
        failure is TransformHtmlEmailContentFailure) {
      emailContentsViewState.value = Left(failure);
    } else if (failure is GetAllIdentitiesFailure) {
      if (identitySelected.value == null) {
        _autoFocusFieldWhenLauncher();
      }
    } else if (failure is GetAlwaysReadReceiptSettingFailure) {
      hasRequestReadReceipt.value = true;
    }
  }

  @override
  void handleExceptionAction({Failure? failure, Exception? exception}) {
    super.handleExceptionAction(failure: failure, exception: exception);
    if (failure is GetAllIdentitiesFailure) {
      _handleGetAllIdentitiesFailure(failure);
    }
  }

  void _listenStreamEvent() {
    uploadInlineImageWorker = ever(uploadController.uploadInlineViewState, (state) {
      log('ComposerController::_listenStreamEvent()::uploadInlineImageWorker: $state');
      state.fold((failure) => null, (success) {
        if (success is SuccessAttachmentUploadState) {
          _handleUploadInlineSuccess(success);
        }
      });
    });
  }

  void _listenBrowserTabRefresh() {
    _subscriptionOnBeforeUnload = html.window.onBeforeUnload.listen((event) async {
      await _removeComposerCacheOnWebInteractor.execute();

      if (composerArguments.value == null ||
          mailboxDashBoardController.sessionCurrent == null ||
          mailboxDashBoardController.accountId.value == null
      ) {
        log('ComposerController::_listenBrowserTabRefresh: SESSION or ACCOUNT_ID or ARGUMENTS is NULL');
        return;
      }

      final emailContent = await _getContentInEditor();

      await _saveComposerCacheOnWebInteractor.execute(CreateEmailRequest(
        session: mailboxDashBoardController.sessionCurrent!,
        accountId: mailboxDashBoardController.accountId.value!,
        emailActionType: composerArguments.value!.emailActionType,
        subject: subjectEmail.value ?? '',
        emailContent: emailContent,
        fromSender: composerArguments.value!.presentationEmail?.from ?? {},
        toRecipients: listToEmailAddress.toSet(),
        ccRecipients: listCcEmailAddress.toSet(),
        bccRecipients: listBccEmailAddress.toSet(),
        isRequestReadReceipt: hasRequestReadReceipt.value,
        identity: identitySelected.value,
        attachments: uploadController.attachmentsUploaded,
        inlineAttachments: uploadController.mapInlineAttachments,
        outboxMailboxId: mailboxDashBoardController.outboxMailbox?.mailboxId,
        sentMailboxId: mailboxDashBoardController.mapDefaultMailboxIdByRole[PresentationMailbox.roleSent],
        draftsMailboxId: mailboxDashBoardController.mapDefaultMailboxIdByRole[PresentationMailbox.roleDrafts],
        draftsEmailId: _getDraftEmailId(),
        answerForwardEmailId: composerArguments.value!.presentationEmail?.id,
        unsubscribeEmailId: composerArguments.value!.previousEmailId,
        messageId: composerArguments.value!.messageId,
        references: composerArguments.value!.references,
        emailSendingQueue: composerArguments.value!.sendingEmail
      ));
    });

    _subscriptionOnDragEnter = html.window.onDragEnter.listen((event) {
      mailboxDashBoardController.localFileDraggableAppState.value = DraggableAppState.active;
    });

    _subscriptionOnDragOver = html.window.onDragOver.listen((event) {
      mailboxDashBoardController.localFileDraggableAppState.value = DraggableAppState.active;
    });

    _subscriptionOnDragLeave = html.window.onDragLeave.listen((event) {
      mailboxDashBoardController.localFileDraggableAppState.value = DraggableAppState.inActive;
    });

    _subscriptionOnDrop = html.window.onDrop.listen((event) {
      mailboxDashBoardController.localFileDraggableAppState.value = DraggableAppState.inActive;
    });
  }

  void _scrollControllerEmailAddressListener() {
    if (toEmailAddressController.text.isNotEmpty) {
      keyToEmailTagEditor.currentState?.closeSuggestionBox();
    }
    if (ccEmailAddressController.text.isNotEmpty) {
      keyCcEmailTagEditor.currentState?.closeSuggestionBox();
    }
    if (bccEmailAddressController.text.isNotEmpty) {
      keyBccEmailTagEditor.currentState?.closeSuggestionBox();
    }
  }

  void createFocusNodeInput() {
    toAddressFocusNode = FocusNode();
    subjectEmailInputFocusNode = FocusNode(
      onKey: (focus, event) {
        if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.tab) {
          richTextWebController.editorController.setFocus();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      }
    );
    ccAddressFocusNode = FocusNode();
    bccAddressFocusNode = FocusNode();
    searchIdentitiesFocusNode = FocusNode();

    subjectEmailInputFocusNode?.addListener(() {
      log('ComposerController::createFocusNodeInput():subjectEmailInputFocusNode: ${subjectEmailInputFocusNode?.hasFocus}');
      if (subjectEmailInputFocusNode?.hasFocus == true) {
        if (PlatformInfo.isMobile) {
          htmlEditorApi?.unfocus();
        }
        _collapseAllRecipient();
        _autoCreateEmailTag();
      }
    });
  }

  void onCreatedMobileEditorAction(BuildContext context, HtmlEditorApi editorApi, String? content) {
    if (identitySelected.value != null) {
      initTextEditor(content);
    }
    richTextMobileTabletController.htmlEditorApi = editorApi;
    keyboardRichTextController.onCreateHTMLEditor(
      editorApi,
      onEnterKeyDown: _onEnterKeyDown,
      context: context,
      onFocus: _onEditorFocusOnMobile,
      onChangeCursor: (coordinates) {
        _onChangeCursorOnMobile(coordinates, context);
      },
    );
  }

  void onTapOutsideSubject(PointerDownEvent event) {
    subjectEmailInputFocusNode?.unfocus();
  }

  void onLoadCompletedMobileEditorAction(HtmlEditorApi editorApi, WebUri? url) {
    _isEmailBodyLoaded = true;
    if (identitySelected.value == null) {
      _getAllIdentities();
    }
  }

  void _initEmail() {
    _isEmailBodyLoaded = false;
    final arguments = PlatformInfo.isWeb
      ? mailboxDashBoardController.composerArguments
      : Get.arguments;
    if (arguments is ComposerArguments) {
      composerArguments.value = arguments;

      injectAutoCompleteBindings(
        mailboxDashBoardController.sessionCurrent,
        mailboxDashBoardController.accountId.value
      );

      switch(arguments.emailActionType) {
        case EmailActionType.editDraft:
          _initEmailAddress(
            presentationEmail: arguments.presentationEmail!,
            actionType: EmailActionType.editDraft
          );
          _initSubjectEmail(
            presentationEmail: arguments.presentationEmail!,
            actionType: EmailActionType.editDraft
          );
          _getEmailContentFromEmailId(
            emailId: arguments.presentationEmail!.id!,
            isDraftEmail: arguments.presentationEmail!.isDraft
          );
          _emailIdEditing = arguments.presentationEmail!.id!;
          break;
        case EmailActionType.editSendingEmail:
          _initEmailAddress(
            presentationEmail: arguments.sendingEmail!.presentationEmail,
            actionType: EmailActionType.editSendingEmail
          );
          _initSubjectEmail(
            presentationEmail: arguments.sendingEmail!.presentationEmail,
            actionType: EmailActionType.editSendingEmail
          );
          _getEmailContentFromSendingEmail(arguments.sendingEmail!);
          _emailIdEditing = arguments.sendingEmail!.presentationEmail.id!;
          break;
        case EmailActionType.composeFromContentShared:
          _getEmailContentFromContentShared(arguments.emailContents!);
          break;
        case EmailActionType.composeFromFileShared:
          _addAttachmentFromFileShare(arguments.listSharedMediaFile!);
          break;
        case EmailActionType.composeFromEmailAddress:
          listToEmailAddress.addAll(arguments.listEmailAddress ?? []);
          isInitialRecipient.value = true;
          toAddressExpandMode.value = ExpandMode.COLLAPSE;
          _updateStatusEmailSendButton();
          break;
        case EmailActionType.composeFromMailtoUri:
          if (arguments.subject != null) {
            setSubjectEmail(arguments.subject!);
            subjectEmailInputController.text = arguments.subject!;
          }
          if (arguments.listEmailAddress?.isNotEmpty == true) {
            listToEmailAddress.addAll(arguments.listEmailAddress!);
            isInitialRecipient.value = true;
            toAddressExpandMode.value = ExpandMode.COLLAPSE;
          }
          _getEmailContentFromMailtoUri(arguments.body ?? '');
          _updateStatusEmailSendButton();
          break;
        case EmailActionType.reply:
        case EmailActionType.replyAll:
          _initEmailAddress(
            presentationEmail: arguments.presentationEmail!,
            actionType: arguments.emailActionType,
            mailboxRole: arguments.presentationEmail!.mailboxContain?.role ?? mailboxDashBoardController.selectedMailbox.value?.role
          );
          _initSubjectEmail(
            presentationEmail: arguments.presentationEmail!,
            actionType: arguments.emailActionType
          );
          _transformHtmlEmailContent(arguments.emailContents);
          break;
        case EmailActionType.forward:
          _initSubjectEmail(
            presentationEmail: arguments.presentationEmail!,
            actionType: arguments.emailActionType
          );
          _initAttachments(arguments.attachments ?? []);
          _transformHtmlEmailContent(arguments.emailContents);
          break;
        case EmailActionType.reopenComposerBrowser:
          _initEmailAddress(
            presentationEmail: arguments.presentationEmail!,
            actionType: EmailActionType.reopenComposerBrowser
          );
          _initSubjectEmail(
            presentationEmail: arguments.presentationEmail!,
            actionType: EmailActionType.reopenComposerBrowser
          );
          _initAttachments(arguments.attachments ?? []);
          _getEmailContentFromSessionStorageBrowser(arguments.emailContents!);
          break;
        case EmailActionType.composeFromUnsubscribeMailtoLink:
          if (arguments.subject != null) {
            setSubjectEmail(arguments.subject!);
            subjectEmailInputController.text = arguments.subject!;
          }
          if (arguments.listEmailAddress?.isNotEmpty == true) {
            listToEmailAddress.addAll(arguments.listEmailAddress!);
            isInitialRecipient.value = true;
            toAddressExpandMode.value = ExpandMode.COLLAPSE;
          }
          _getEmailContentFromUnsubscribeMailtoLink(arguments.body ?? '');
          _updateStatusEmailSendButton();
          break;
        default:
          break;
      }
    }
  }

  void _initSubjectEmail({
    required PresentationEmail presentationEmail,
    required EmailActionType actionType
  }) {
    final subjectEmail = presentationEmail.getEmailTitle().trim();
    final newSubject = actionType.getSubjectComposer(currentContext, subjectEmail);
    setSubjectEmail(newSubject);
    subjectEmailInputController.text = newSubject;
  }

  void _initAttachments(List<Attachment> attachments) {
    if (attachments.isNotEmpty) {
      initialAttachments = attachments;
      uploadController.initializeUploadAttachments(attachments);
    }
  }

  void _getAllIdentities() {
    final accountId = mailboxDashBoardController.accountId.value;
    final session = mailboxDashBoardController.sessionCurrent;
    if (accountId != null && session != null) {
      consumeState(_getAllIdentitiesInteractor.execute(session, accountId));
    }
  }

  void _handleGetAllIdentitiesSuccess(GetAllIdentitiesSuccess success) async {
    final listIdentitiesMayDeleted = success.identities?.toListMayDeleted() ?? [];
    if (listIdentitiesMayDeleted.isNotEmpty) {
      listFromIdentities.value = listIdentitiesMayDeleted;

      if (identitySelected.value == null) {
        await _selectIdentity(listIdentitiesMayDeleted.first);
      }
    }
    _autoFocusFieldWhenLauncher();
  }

  void _initEmailAddress({
    required PresentationEmail presentationEmail,
    required EmailActionType actionType,
    Role? mailboxRole,
  }) {
    final recipients = presentationEmail.generateRecipientsEmailAddressForComposer(
      emailActionType: actionType,
      mailboxRole: mailboxRole
    );
    final userName =  mailboxDashBoardController.sessionCurrent?.username;
    if (userName != null) {
      final isSender = presentationEmail.from.asList().every((element) => element.email == userName.value);
      if (isSender) {
        listToEmailAddress = List.from(recipients.value1.toSet());
        listCcEmailAddress = List.from(recipients.value2.toSet());
        listBccEmailAddress = List.from(recipients.value3.toSet());
      } else {
        listToEmailAddress = List.from(recipients.value1.toSet().filterEmailAddress(userName.value));
        listCcEmailAddress = List.from(recipients.value2.toSet().filterEmailAddress(userName.value));
        listBccEmailAddress = List.from(recipients.value3.toSet().filterEmailAddress(userName.value));
      }
    } else {
      listToEmailAddress = List.from(recipients.value1.toSet());
      listCcEmailAddress = List.from(recipients.value2.toSet());
      listBccEmailAddress = List.from(recipients.value3.toSet());
    }

    if (listToEmailAddress.isNotEmpty || listCcEmailAddress.isNotEmpty || listBccEmailAddress.isNotEmpty) {
      isInitialRecipient.value = true;
      toAddressExpandMode.value = ExpandMode.COLLAPSE;
    }

    if (listCcEmailAddress.isNotEmpty) {
      ccRecipientState.value = PrefixRecipientState.enabled;
      ccAddressExpandMode.value = ExpandMode.COLLAPSE;
    }

    if (listBccEmailAddress.isNotEmpty) {
      bccRecipientState.value = PrefixRecipientState.enabled;
      bccAddressExpandMode.value = ExpandMode.COLLAPSE;
    }

    _updateStatusEmailSendButton();
  }

  void updateListEmailAddress(
    PrefixEmailAddress prefixEmailAddress,
    List<EmailAddress> newListEmailAddress
  ) {
    switch(prefixEmailAddress) {
      case PrefixEmailAddress.to:
        listToEmailAddress = List.from(newListEmailAddress);
        break;
      case PrefixEmailAddress.cc:
        listCcEmailAddress = List.from(newListEmailAddress);
        break;
      case PrefixEmailAddress.bcc:
        listBccEmailAddress = List.from(newListEmailAddress);
        break;
      default:
        break;
    }
    _updateStatusEmailSendButton();
  }

  void _updateStatusEmailSendButton() {
    if (listToEmailAddress.isNotEmpty
        || listBccEmailAddress.isNotEmpty
        || listCcEmailAddress.isNotEmpty) {
      isEnableEmailSendButton.value = true;
    } else {
      isEnableEmailSendButton.value = false;
    }
  }

  void handleClickSendButton(BuildContext context) async {
    if (_sendButtonState == ButtonState.disabled) {
      log('ComposerController::handleClickSendButton: SENDING EMAIL');
      return;
    }
    _sendButtonState = ButtonState.disabled;

    clearFocus(context);

    if (toEmailAddressController.text.isNotEmpty
        || ccEmailAddressController.text.isNotEmpty
        || bccEmailAddressController.text.isNotEmpty) {
      _collapseAllRecipient();
      _autoCreateEmailTag();
    }

    if (!isEnableEmailSendButton.value) {
      showConfirmDialogAction(context,
        AppLocalizations.of(context).message_dialog_send_email_without_recipient,
        AppLocalizations.of(context).add_recipients,
        title: AppLocalizations.of(context).sending_failed,
        icon: SvgPicture.asset(imagePaths.icSendToastError, fit: BoxFit.fill),
        hasCancelButton: false,
        showAsBottomSheet: true,
      ).whenComplete(() => _sendButtonState = ButtonState.enabled);
      return;
    }

    final allListEmailAddress = listToEmailAddress + listCcEmailAddress + listBccEmailAddress;
    final listEmailAddressInvalid = allListEmailAddress
        .where((emailAddress) => !EmailUtils.isEmailAddressValid(emailAddress.emailAddress))
        .toList();
    if (listEmailAddressInvalid.isNotEmpty) {
      showConfirmDialogAction(context,
        AppLocalizations.of(context).message_dialog_send_email_with_email_address_invalid,
        AppLocalizations.of(context).fix_email_addresses,
        onConfirmAction: () {
          toAddressExpandMode.value = ExpandMode.EXPAND;
          ccAddressExpandMode.value = ExpandMode.EXPAND;
          bccAddressExpandMode.value = ExpandMode.EXPAND;
        },
        showAsBottomSheet: true,
        title: AppLocalizations.of(context).sending_failed,
        icon: SvgPicture.asset(imagePaths.icSendToastError, fit: BoxFit.fill),
        hasCancelButton: false
      ).whenComplete(() => _sendButtonState = ButtonState.enabled);
      return;
    }

    if (subjectEmail.value == null || subjectEmail.isEmpty == true) {
      showConfirmDialogAction(context,
        AppLocalizations.of(context).message_dialog_send_email_without_a_subject,
        AppLocalizations.of(context).send_anyway,
        onConfirmAction: () => _handleSendMessages(context),
        title: AppLocalizations.of(context).empty_subject,
        showAsBottomSheet: true,
        icon: SvgPicture.asset(imagePaths.icEmpty, fit: BoxFit.fill),
      ).whenComplete(() => _sendButtonState = ButtonState.enabled);
      return;
    }

    if (!uploadController.allUploadAttachmentsCompleted) {
      showConfirmDialogAction(
        context,
        AppLocalizations.of(context).messageDialogSendEmailUploadingAttachment,
        AppLocalizations.of(context).got_it,
        title: AppLocalizations.of(context).sending_failed,
        showAsBottomSheet: true,
        icon: SvgPicture.asset(imagePaths.icSendToastError, fit: BoxFit.fill),
        hasCancelButton: false
      ).whenComplete(() => _sendButtonState = ButtonState.enabled);
      return;
    }

    if (uploadController.isExceededMaxSizeAttachmentsPerEmail()) {
      showConfirmDialogAction(
        context,
        AppLocalizations.of(context).message_dialog_send_email_exceeds_maximum_size(
            filesize(mailboxDashBoardController.maxSizeAttachmentsPerEmail?.value ?? 0, 0)),
        AppLocalizations.of(context).got_it,
        title: AppLocalizations.of(context).sending_failed,
        icon: SvgPicture.asset(imagePaths.icSendToastError, fit: BoxFit.fill),
        hasCancelButton: false
      ).whenComplete(() => _sendButtonState = ButtonState.enabled);
      return;
    }

    _handleSendMessages(context);
  }

  Future<String> _getContentInEditor() async {
    final htmlTextEditor = PlatformInfo.isWeb
      ? _textEditorWeb
      : await htmlEditorApi?.getText();
    if (htmlTextEditor?.isNotEmpty == true) {
      return htmlTextEditor!.removeEditorStartTag();
    } else {
      return '';
    }
  }

  void _handleSendMessages(BuildContext context) async {
    if (composerArguments.value == null ||
        mailboxDashBoardController.sessionCurrent == null ||
        mailboxDashBoardController.accountId.value == null
    ) {
      log('ComposerController::_handleSendMessages: SESSION or ACCOUNT_ID or ARGUMENTS is NULL');
      _sendButtonState = ButtonState.enabled;
      _closeComposerAction();
      return;
    }

    final emailContent = await _getContentInEditor();
    final cancelToken = CancelToken();
    final resultState = await _showSendingMessageDialog(
      emailContent: emailContent,
      cancelToken: cancelToken
    );
    log('ComposerController::_handleSendMessages: resultState = $resultState');
    if (resultState is SendEmailSuccess || mailboxDashBoardController.validateSendingEmailFailedWhenNetworkIsLostOnMobile(resultState)) {
      _sendButtonState = ButtonState.enabled;
      _closeComposerAction(result: resultState);
    } else if (resultState is SendEmailFailure && resultState.exception is SendingEmailCanceledException) {
      _sendButtonState = ButtonState.enabled;
    } else if ((resultState is SendEmailFailure || resultState is GenerateEmailFailure) && context.mounted) {
      _showConfirmDialogWhenSendMessageFailure(
        context: context,
        failure: resultState
      );
    } else {
      _sendButtonState = ButtonState.enabled;
    }
  }

  Future<dynamic> _showSendingMessageDialog({
    required String emailContent,
    CancelToken? cancelToken
  }) {
    final childWidget = PointerInterceptor(
      child: SendingMessageDialogView(
        createEmailRequest: CreateEmailRequest(
          session: mailboxDashBoardController.sessionCurrent!,
          accountId: mailboxDashBoardController.accountId.value!,
          emailActionType: composerArguments.value!.emailActionType,
          subject: subjectEmail.value ?? '',
          emailContent: emailContent,
          fromSender: composerArguments.value!.presentationEmail?.from ?? {},
          toRecipients: listToEmailAddress.toSet(),
          ccRecipients: listCcEmailAddress.toSet(),
          bccRecipients: listBccEmailAddress.toSet(),
          isRequestReadReceipt: hasRequestReadReceipt.value,
          identity: identitySelected.value,
          attachments: uploadController.attachmentsUploaded,
          inlineAttachments: uploadController.mapInlineAttachments,
          outboxMailboxId: mailboxDashBoardController.outboxMailbox?.mailboxId,
          sentMailboxId: mailboxDashBoardController.mapDefaultMailboxIdByRole[PresentationMailbox.roleSent],
          draftsEmailId: composerArguments.value!.emailActionType == EmailActionType.editDraft
            ? composerArguments.value!.presentationEmail?.id
            : null,
          answerForwardEmailId: composerArguments.value!.presentationEmail?.id,
          unsubscribeEmailId: composerArguments.value!.previousEmailId,
          messageId: composerArguments.value!.messageId,
          references: composerArguments.value!.references,
          emailSendingQueue: composerArguments.value!.sendingEmail
        ),
        createNewAndSendEmailInteractor: _createNewAndSendEmailInteractor,
        onCancelSendingEmailAction: _handleCancelSendingMessage,
        cancelToken: cancelToken,
      ),
    );

    return Get.dialog(
      PlatformInfo.isMobile
        ? PopScope(canPop: false, child: childWidget)
        : childWidget,
      barrierDismissible: false,
      barrierColor: AppColor.colorDefaultCupertinoActionSheet,
    );
  }

  void _handleCancelSendingMessage({CancelToken? cancelToken}) {
    cancelToken?.cancel([SendingEmailCanceledException()]);
  }

  void _showConfirmDialogWhenSendMessageFailure({
    required BuildContext context,
    required FeatureFailure failure
  }) {
    showConfirmDialogAction(
      context,
      title: '',
      AppLocalizations.of(context).warningMessageWhenSendEmailFailure,
      AppLocalizations.of(context).edit,
      cancelTitle: AppLocalizations.of(context).closeAnyway,
      alignCenter: true,
      onConfirmAction: () {
        _sendButtonState = ButtonState.enabled;
        _autoFocusFieldWhenLauncher();
      },
      onCancelAction: () async {
        _sendButtonState = ButtonState.enabled;
        await Future.delayed(
          const Duration(milliseconds: 100),
          _closeComposerAction
        );
      },
      icon: SvgPicture.asset(
        imagePaths.icQuotasWarning,
        width: 40,
        height: 40,
        colorFilter: AppColor.colorBackgroundQuotasWarning.asFilter(),
      ),
      messageStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
        fontSize: 14,
        color: AppColor.colorTextBody
      ),
      actionStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
        fontSize: 17,
        color: Colors.white
      ),
      cancelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
        fontSize: 17,
        color: Colors.black
      )
    );
  }

  void _checkContactPermission() async {
    final permissionStatus = await Permission.contacts.status;
    if (permissionStatus.isGranted) {
      _contactSuggestionSource = ContactSuggestionSource.all;
    } else if (!permissionStatus.isPermanentlyDenied) {
      final requestedPermission = await Permission.contacts.request();
      _contactSuggestionSource = requestedPermission == PermissionStatus.granted
          ? ContactSuggestionSource.all
          : _contactSuggestionSource;
    }
  }

  Future<List<EmailAddress>> getAutoCompleteSuggestion(String word) async {
    log('ComposerController::getAutoCompleteSuggestion(): $word | $_contactSuggestionSource');
    _getAllAutoCompleteInteractor = getBinding<GetAllAutoCompleteInteractor>();
    _getAutoCompleteInteractor = getBinding<GetAutoCompleteInteractor>();
    _getDeviceContactSuggestionsInteractor = getBinding<GetDeviceContactSuggestionsInteractor>();

    if (_contactSuggestionSource == ContactSuggestionSource.all) {
      if (_getAllAutoCompleteInteractor != null) {
        return await _getAllAutoCompleteInteractor!
          .execute(AutoCompletePattern(word: word, accountId: mailboxDashBoardController.accountId.value))
          .then((value) => value.fold(
            (failure) => <EmailAddress>[],
            (success) => _getAutoCompleteSuccess(success, word)
          ));
      } else if (_getDeviceContactSuggestionsInteractor != null) {
        return await _getDeviceContactSuggestionsInteractor!
          .execute(AutoCompletePattern(word: word, accountId: mailboxDashBoardController.accountId.value))
          .then((value) => value.fold(
            (failure) => <EmailAddress>[],
            (success) => _getAutoCompleteSuccess(success, word)
          ));
      } else {
        return <EmailAddress>[];
      }
    } else {
      if (_getAutoCompleteInteractor == null) {
        return <EmailAddress>[];
      } else {
        return await _getAutoCompleteInteractor!
          .execute(AutoCompletePattern(word: word, accountId: mailboxDashBoardController.accountId.value))
          .then((value) => value.fold(
            (failure) => <EmailAddress>[],
            (success) => _getAutoCompleteSuccess(success, word)
          ));
      }
    }
  }

  List<EmailAddress> _getAutoCompleteSuccess(Success success, String word) {
    if (success is GetAutoCompleteSuccess) {
      if (success.listEmailAddress.isEmpty == true && GetUtils.isEmail(word)) {
        final unknownEmailAddress = EmailAddress(word, word);
        return <EmailAddress>[unknownEmailAddress];
      }
      if (GetUtils.isEmail(word)) {
        bool isContainsTypedEmail = success.listEmailAddress.any((emailAddress) => emailAddress.email == word);
        if (!isContainsTypedEmail) {
          final unknownEmailAddress = EmailAddress(word, word);
          success.listEmailAddress.insert(0, unknownEmailAddress);
          return success.listEmailAddress;
        }
      }
      return success.listEmailAddress;
    } else if (success is GetDeviceContactSuggestionsSuccess) {
      if (success.listEmailAddress.isEmpty == true && GetUtils.isEmail(word)) {
        final unknownEmailAddress = EmailAddress(word, word);
        return <EmailAddress>[unknownEmailAddress];
      }
      if (GetUtils.isEmail(word)) {
        bool isContainsTypedEmail = success.listEmailAddress.any((emailAddress) => emailAddress.email == word);
        if (!isContainsTypedEmail) {
          final unknownEmailAddress = EmailAddress(word, word);
          success.listEmailAddress.insert(0, unknownEmailAddress);
          return success.listEmailAddress;
        }
      }
      return success.listEmailAddress;
    } else {
      return <EmailAddress>[];
    }
  }

  void openPickAttachmentMenu(BuildContext context, List<Widget> actionTiles) {
    clearFocus(context);

    (ContextMenuBuilder(context)
        ..addHeader((ContextMenuHeaderBuilder(const Key('attachment_picker_context_menu_header_builder'))
              ..addLabel(AppLocalizations.of(context).pick_attachments))
            .build())
        ..addTiles(actionTiles)
        ..addOnCloseContextMenuAction(() => popBack()))
      .build();
  }

  void openFilePickerByType(BuildContext context, FileType fileType) async {
    if (!kIsWeb) {
      popBack();
    }
    consumeState(_localFilePickerInteractor.execute(fileType: fileType));
  }

  void _handlePickFileFailure(LocalFilePickerFailure failure) {
    if (currentOverlayContext != null && currentContext != null && failure.exception is! PickFileCanceledException) {
      appToast.showToastErrorMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).thisFileCannotBePicked);
    }
  }

  void _handlePickImageFailure(LocalImagePickerFailure failure) {
    if (currentOverlayContext != null && currentContext != null && failure.exception is! PickFileCanceledException) {
      appToast.showToastErrorMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).cannotSelectThisImage);
    }
  }

  void _handlePickFileSuccess(LocalFilePickerSuccess success) {
    uploadController.validateTotalSizeAttachmentsBeforeUpload(
      totalSizePreparedFiles: success.pickedFiles.totalSize,
      onValidationSuccess: () => _uploadAttachmentsAction(pickedFiles: success.pickedFiles)
    );
  }

  void _handlePickImageSuccess(LocalImagePickerSuccess success) {
    uploadController.validateTotalSizeInlineAttachmentsBeforeUpload(
      totalSizePreparedFiles: success.fileInfo.fileSize,
      onValidationSuccess: () => _uploadAttachmentsAction(pickedFiles: [success.fileInfo.withInline()])
    );
  }

  void _uploadAttachmentsAction({required List<FileInfo> pickedFiles}) {
    final session = mailboxDashBoardController.sessionCurrent;
    final accountId = mailboxDashBoardController.accountId.value;
    if (session != null && accountId != null) {
      final uploadUri = session.getUploadUri(accountId, jmapUrl: _dynamicUrlInterceptors.jmapUrl);
      uploadController.justUploadAttachmentsAction(
        uploadFiles: pickedFiles,
        uploadUri: uploadUri,
      );
    } else {
      log('ComposerController::_uploadAttachmentsAction: SESSION OR ACCOUNT_ID is NULL');
    }
  }

  void deleteAttachmentUploaded(UploadTaskId uploadId) {
    uploadController.deleteFileUploaded(uploadId);
  }

  Future<bool> _validateEmailChange({
    required BuildContext context,
    required EmailActionType emailActionType,
    PresentationEmail? presentationEmail,
    Role? mailboxRole,
  }) async {
    final newEmailBody = await _getContentInEditor();
    final oldEmailBody = _initTextEditor ?? '';
    log('ComposerController::_validateEmailChange: newEmailBody = $newEmailBody | oldEmailBody = $oldEmailBody');
    final isEmailBodyChanged = !oldEmailBody.trim().isSame(newEmailBody.trim());

    final newEmailSubject = subjectEmail.value ?? '';
    final oldEmailSubject = emailActionType == EmailActionType.editDraft
      ? presentationEmail?.getEmailTitle().trim() ?? ''
      : '';
    final isEmailSubjectChanged = !oldEmailSubject.trim().isSame(newEmailSubject.trim());

    final recipients = presentationEmail
      ?.generateRecipientsEmailAddressForComposer(
          emailActionType: emailActionType,
          mailboxRole: mailboxRole
        ) ?? const Tuple3(<EmailAddress>[], <EmailAddress>[], <EmailAddress>[]);

    final newToEmailAddress = listToEmailAddress;
    final oldToEmailAddress = emailActionType == EmailActionType.editDraft ? recipients.value1 : [];
    final isToEmailAddressChanged = !oldToEmailAddress.isSame(newToEmailAddress);

    final newCcEmailAddress = listCcEmailAddress;
    final oldCcEmailAddress = emailActionType == EmailActionType.editDraft ? recipients.value2 : [];
    final isCcEmailAddressChanged = !oldCcEmailAddress.isSame(newCcEmailAddress);

    final newBccEmailAddress = listBccEmailAddress;
    final oldBccEmailAddress = emailActionType == EmailActionType.editDraft ? recipients.value3 : [];
    final isBccEmailAddressChanged = !oldBccEmailAddress.isSame(newBccEmailAddress);

    final isAttachmentsChanged = !initialAttachments.isSame(uploadController.attachmentsUploaded.toList());
    log('ComposerController::_validateChangeEmail: isEmailBodyChanged = $isEmailBodyChanged | isEmailSubjectChanged = $isEmailSubjectChanged | isToEmailAddressChanged = $isToEmailAddressChanged | isCcEmailAddressChanged = $isCcEmailAddressChanged | isBccEmailAddressChanged = $isBccEmailAddressChanged | isAttachmentsChanged = $isAttachmentsChanged');
    if (isEmailBodyChanged || isEmailSubjectChanged
        || isToEmailAddressChanged || isCcEmailAddressChanged
        || isBccEmailAddressChanged || isAttachmentsChanged) {
      return true;
    }

    return false;
  }

  void handleClickSaveAsDraftsButton(BuildContext context) async {
    if (_saveToDraftButtonState == ButtonState.disabled) {
      log('ComposerController::handleClickSaveAsDraftsButton: Saving to draft');
      return;
    }

    _saveToDraftButtonState = ButtonState.disabled;

    if (composerArguments.value == null ||
        mailboxDashBoardController.sessionCurrent == null ||
        mailboxDashBoardController.accountId.value == null ||
        mailboxDashBoardController.mapDefaultMailboxIdByRole[PresentationMailbox.roleDrafts] == null
    ) {
      log('ComposerController::handleClickSaveAsDraftsButton: SESSION or ACCOUNT_ID or ARGUMENTS is NULL');
      _saveToDraftButtonState = ButtonState.enabled;
      return;
    }

    final emailContent = await _getContentInEditor();
    final cancelToken = CancelToken();
    final resultState = await _showSavingMessageToDraftsDialog(
      emailContent: emailContent,
      draftEmailId: _emailIdEditing,
      cancelToken: cancelToken
    );

    if (resultState is SaveEmailAsDraftsSuccess) {
      _saveToDraftButtonState = ButtonState.enabled;
      _emailIdEditing = resultState.emailId;
      mailboxDashBoardController.consumeState(Stream.value(Right<Failure, Success>(resultState)));
    } else if (resultState is UpdateEmailDraftsSuccess) {
      _saveToDraftButtonState = ButtonState.enabled;
      _emailIdEditing = resultState.emailId;
      mailboxDashBoardController.consumeState(Stream.value(Right<Failure, Success>(resultState)));
    } else if ((resultState is SaveEmailAsDraftsFailure && resultState.exception is SavingEmailToDraftsCanceledException) ||
        (resultState is UpdateEmailDraftsFailure && resultState.exception is SavingEmailToDraftsCanceledException)) {
      _saveToDraftButtonState = ButtonState.enabled;
    } else if ((resultState is SaveEmailAsDraftsFailure ||
        resultState is UpdateEmailDraftsFailure ||
        resultState is GenerateEmailFailure) &&
        context.mounted
    ) {
      _showConfirmDialogWhenSaveMessageToDraftsFailure(
        context: context,
        failure: resultState,
        onConfirmAction: () {
          _saveToDraftButtonState = ButtonState.enabled;
          _autoFocusFieldWhenLauncher();
        },
        onCancelAction: () async {
          _saveToDraftButtonState = ButtonState.enabled;
          await Future.delayed(
            const Duration(milliseconds: 100),
            _closeComposerAction
          );
        }
      );
    } else {
      _saveToDraftButtonState = ButtonState.enabled;
    }
  }

  void _addAttachmentFromFileShare(List<SharedMediaFile> listSharedMediaFile) {
    final listFileInfo = listSharedMediaFile.toListFileInfo(isShared: true);

    final tupleListFileInfo = partition(listFileInfo, (fileInfo) => fileInfo.isInline == true);
    final listAttachments = tupleListFileInfo.value2;

    uploadController.validateTotalSizeAttachmentsBeforeUpload(
      totalSizePreparedFiles: listFileInfo.totalSize,
      totalSizePreparedFilesWithDispositionAttachment: listAttachments.totalSize,
      onValidationSuccess: () => _uploadAttachmentsAction(pickedFiles: listFileInfo)
    );
  }

  void _getEmailContentFromSendingEmail(SendingEmail sendingEmail) {
    consumeState(Stream.value(
      Right(GetEmailContentSuccess(
        htmlEmailContent: sendingEmail.presentationEmail.emailContentList.asHtmlString,
        attachments: sendingEmail.email.allAttachments,
        emailCurrent: sendingEmail.email
      ))
    ));
  }

  void _getEmailContentFromSessionStorageBrowser(String content) {
    consumeState(Stream.value(
      Right(GetEmailContentSuccess(
        htmlEmailContent: content,
        attachments: [],
      ))
    ));
  }

  void _getEmailContentFromContentShared(String content) {
    consumeState(Stream.value(
      Right(GetEmailContentSuccess(
        htmlEmailContent: content,
        attachments: [],
      ))
    ));
  }

  void _getEmailContentFromMailtoUri(String content) {
    log('ComposerController::_getEmailContentFromMailtoUri:content: $content');
    consumeState(Stream.value(
      Right(GetEmailContentSuccess(
        htmlEmailContent: content,
        attachments: [],
      ))
    ));
  }

  void _getEmailContentFromUnsubscribeMailtoLink(String content) {
    log('ComposerController::_getEmailContentFromUnsubscribeMailtoLink:content: $content');
    consumeState(Stream.value(
      Right(GetEmailContentSuccess(
        htmlEmailContent: content,
        attachments: [],
      ))
    ));
  }

  void _getEmailContentFromEmailId({required EmailId emailId, bool isDraftEmail = false}) {
    final session = mailboxDashBoardController.sessionCurrent;
    final accountId = mailboxDashBoardController.accountId.value;
    if (session != null && accountId != null) {
      consumeState(_getEmailContentInteractor.execute(
        session,
        accountId,
        emailId,
        mailboxDashBoardController.baseDownloadUrl,
        TransformConfiguration.forDraftsEmail()
      ));
    }
  }

  void _getEmailContentOffLineSuccess(GetEmailContentFromCacheSuccess success) {
    _initAttachments(success.attachments);
    emailContentsViewState.value = Right(success);
  }

  void _getEmailContentSuccess(GetEmailContentSuccess success) {
    _initAttachments(success.attachments);
    emailContentsViewState.value = Right(success);
  }

  void _transformHtmlEmailContent(String? emailContent) {
    emailContentsViewState(Right(TransformHtmlEmailContentLoading()));
    if (emailContent?.isEmpty == true) {
      consumeState(Stream.value(Left(TransformHtmlEmailContentFailure(EmptyEmailContentException()))));
    } else {
      consumeState(_transformHtmlEmailContentInteractor.execute(
        emailContent!,
        TransformConfiguration.forReplyForwardEmail()
      ));
    }
  }

  String getEmailAddressSender() {
    final arguments = composerArguments.value;
    if (arguments != null) {
      if (arguments.emailActionType == EmailActionType.editDraft) {
        return arguments.presentationEmail?.firstEmailAddressInFrom ?? '';
      } else {
        return mailboxDashBoardController.sessionCurrent?.username.value ?? '';
      }
    }
    return '';
  }

  void clearFocus(BuildContext context) {
    log('ComposerController::clearFocus:');
    if (PlatformInfo.isMobile) {
      htmlEditorApi?.unfocus();
      KeyboardUtils.hideSystemKeyboardMobile();
    }
    FocusScope.of(context).unfocus();
  }

  void _closeComposerAction({dynamic result}) {
    if (PlatformInfo.isWeb) {
      mailboxDashBoardController.closeComposerOverlay(result: result);
    } else {
      popBack(result: result);
    }
  }

  void displayScreenTypeComposerAction(ScreenDisplayMode displayMode) async {
    createFocusNodeInput();
    _updateTextForEditor();
    screenDisplayMode.value = displayMode;

    await Future.delayed(
      const Duration(milliseconds: 300),
      _autoFocusFieldWhenLauncher);
  }

  void _updateTextForEditor() async {
    final textCurrent = await richTextWebController.editorController.getText();
    richTextWebController.editorController.setText(textCurrent);
  }

  void deleteComposer() {
    FocusManager.instance.primaryFocus?.unfocus();
    mailboxDashBoardController.closeComposerOverlay();
  }

  void addEmailAddressType(PrefixEmailAddress prefixEmailAddress) {
    switch(prefixEmailAddress) {
      case PrefixEmailAddress.from:
        fromRecipientState.value = PrefixRecipientState.enabled;
        break;
      case PrefixEmailAddress.cc:
        ccRecipientState.value = PrefixRecipientState.enabled;
        break;
      case PrefixEmailAddress.bcc:
        bccRecipientState.value = PrefixRecipientState.enabled;
        break;
      default:
        break;
    }
  }

  void deleteEmailAddressType(PrefixEmailAddress prefixEmailAddress) {
    updateListEmailAddress(prefixEmailAddress, <EmailAddress>[]);
    switch(prefixEmailAddress) {
      case PrefixEmailAddress.cc:
        ccRecipientState.value = PrefixRecipientState.disabled;
        ccAddressFocusNode = FocusNode();
        ccEmailAddressController.clear();
        break;
      case PrefixEmailAddress.bcc:
        bccRecipientState.value = PrefixRecipientState.disabled;
        bccAddressFocusNode = FocusNode();
        bccEmailAddressController.clear();
        break;
      default:
        break;
    }
  }

  void onEditorFocusChange(bool isFocus) {
    if (isFocus) {
      _collapseAllRecipient();
      _autoCreateEmailTag();
    }
  }

  void _collapseAllRecipient() {
    toAddressExpandMode.value = ExpandMode.COLLAPSE;
    ccAddressExpandMode.value = ExpandMode.COLLAPSE;
    bccAddressExpandMode.value = ExpandMode.COLLAPSE;
  }

  void _autoCreateEmailTag() {
    final inputToEmail = toEmailAddressController.text;
    final inputCcEmail = ccEmailAddressController.text;
    final inputBccEmail = bccEmailAddressController.text;

    if (inputToEmail.isNotEmpty) {
      _autoCreateToEmailTag(inputToEmail);
    }
    if (inputCcEmail.isNotEmpty) {
      _autoCreateCcEmailTag(inputCcEmail);
    }
    if (inputBccEmail.isNotEmpty) {
      _autoCreateBccEmailTag(inputBccEmail);
    }
  }

  bool _isDuplicatedRecipient(String inputEmail, List<EmailAddress> listEmailAddress) {
    return listEmailAddress
      .map((emailAddress) => emailAddress.email)
      .whereNotNull()
      .contains(inputEmail);
  }

  void _autoCreateToEmailTag(String inputEmail) {
    if (!_isDuplicatedRecipient(inputEmail, listToEmailAddress)) {
      final emailAddress = EmailAddress(null, inputEmail);
      listToEmailAddress.add(emailAddress);
      isInitialRecipient.value = true;
      isInitialRecipient.refresh();
      _updateStatusEmailSendButton();
    }
    log('ComposerController::_autoCreateToEmailTag(): STATE: ${keyToEmailTagEditor.currentState}');
    keyToEmailTagEditor.currentState?.resetTextField();
    Future.delayed(const Duration(milliseconds: 300), () {
      keyToEmailTagEditor.currentState?.closeSuggestionBox();
    });
  }

  void _autoCreateCcEmailTag(String inputEmail) {
    if (!_isDuplicatedRecipient(inputEmail, listCcEmailAddress)) {
      final emailAddress = EmailAddress(null, inputEmail);
      listCcEmailAddress.add(emailAddress);
      isInitialRecipient.value = true;
      isInitialRecipient.refresh();
      _updateStatusEmailSendButton();
    }
    keyCcEmailTagEditor.currentState?.resetTextField();
    Future.delayed(const Duration(milliseconds: 300), () {
      keyCcEmailTagEditor.currentState?.closeSuggestionBox();
    });
  }

  void _autoCreateBccEmailTag(String inputEmail) {
    if (!_isDuplicatedRecipient(inputEmail, listBccEmailAddress)) {
      final emailAddress = EmailAddress(null, inputEmail);
      listBccEmailAddress.add(emailAddress);
      isInitialRecipient.value = true;
      isInitialRecipient.refresh();
      _updateStatusEmailSendButton();
    }
    keyBccEmailTagEditor.currentState?.resetTextField();
    Future.delayed(const Duration(milliseconds: 300), () {
      keyBccEmailTagEditor.currentState?.closeSuggestionBox();
    });
  }

  void _closeSuggestionBox() {
    if (toEmailAddressController.text.isEmpty) {
      keyToEmailTagEditor.currentState?.closeSuggestionBox();
    }
    if (ccEmailAddressController.text.isEmpty) {
      keyCcEmailTagEditor.currentState?.closeSuggestionBox();
    }
    if (bccEmailAddressController.text.isEmpty) {
      keyBccEmailTagEditor.currentState?.closeSuggestionBox();
    }
  }

  void showFullEmailAddress(PrefixEmailAddress prefixEmailAddress) {
    switch(prefixEmailAddress) {
      case PrefixEmailAddress.to:
        toAddressExpandMode.value = ExpandMode.EXPAND;
        break;
      case PrefixEmailAddress.cc:
        ccAddressExpandMode.value = ExpandMode.EXPAND;
        break;
      case PrefixEmailAddress.bcc:
        bccAddressExpandMode.value = ExpandMode.EXPAND;
        break;
      default:
        break;
    }
  }

  void onEmailAddressFocusChange(PrefixEmailAddress prefixEmailAddress, bool isFocus) {
    if (isFocus) {
      switch(prefixEmailAddress) {
        case PrefixEmailAddress.to:
          toAddressExpandMode.value = ExpandMode.EXPAND;
          break;
        case PrefixEmailAddress.cc:
          ccAddressExpandMode.value = ExpandMode.EXPAND;
          break;
        case PrefixEmailAddress.bcc:
          bccAddressExpandMode.value = ExpandMode.EXPAND;
          break;
        default:
          break;
      }
      _closeSuggestionBox();
      if (PlatformInfo.isMobile) {
        htmlEditorApi?.unfocus();
      }
    } else {
      switch(prefixEmailAddress) {
        case PrefixEmailAddress.to:
          toAddressExpandMode.value = ExpandMode.COLLAPSE;
          final inputToEmail = toEmailAddressController.text;
          if (inputToEmail.isNotEmpty) {
            _autoCreateToEmailTag(inputToEmail);
          }
          break;
        case PrefixEmailAddress.cc:
          ccAddressExpandMode.value = ExpandMode.COLLAPSE;
          final inputCcEmail = ccEmailAddressController.text;
          if (inputCcEmail.isNotEmpty) {
            _autoCreateCcEmailTag(inputCcEmail);
          }
          break;
        case PrefixEmailAddress.bcc:
          bccAddressExpandMode.value = ExpandMode.COLLAPSE;
          final inputBccEmail = bccEmailAddressController.text;
          if (inputBccEmail.isNotEmpty) {
            _autoCreateBccEmailTag(inputBccEmail);
          }
          break;
        default:
          break;
      }
    }
  }

  Future<void> _selectIdentity(Identity? newIdentity) async {
    final formerIdentity = identitySelected.value;
    identitySelected.value = newIdentity;
    if (newIdentity != null) {
      await _applyIdentityForAllFieldComposer(formerIdentity, newIdentity);
    }
  }

  Future<void> _applyIdentityForAllFieldComposer(
    Identity? formerIdentity,
    Identity newIdentity
  ) async {
    if (formerIdentity != null) {
      if (formerIdentity.bcc?.isNotEmpty == true) {
        _removeBccEmailAddressFromFormerIdentity(formerIdentity.bcc!);
      }
      await _removeSignature();
    }

    if (newIdentity.bcc?.isNotEmpty == true) {
      _applyBccEmailAddressFromIdentity(newIdentity.bcc!);
    }

    if (newIdentity.signatureAsString.isNotEmpty == true) {
      await _applySignature(newIdentity.signatureAsString.asSignatureHtml());
    }
  }

  void _applyBccEmailAddressFromIdentity(Set<EmailAddress> listEmailAddress) {
    if (bccRecipientState.value == PrefixRecipientState.disabled) {
      bccRecipientState.value = PrefixRecipientState.enabled;
    }
    listBccEmailAddress = listEmailAddress.toList();
    toAddressExpandMode.value = ExpandMode.COLLAPSE;
    ccAddressExpandMode.value = ExpandMode.COLLAPSE;
    bccAddressExpandMode.value = ExpandMode.COLLAPSE;
    _updateStatusEmailSendButton();
  }

  void _removeBccEmailAddressFromFormerIdentity(Set<EmailAddress> listEmailAddress) {
    listBccEmailAddress = listBccEmailAddress
        .where((address) => !listEmailAddress.contains(address))
        .toList();
    if (listBccEmailAddress.isEmpty) {
      bccRecipientState.value = PrefixRecipientState.disabled;
    }
    toAddressExpandMode.value = ExpandMode.COLLAPSE;
    ccAddressExpandMode.value = ExpandMode.COLLAPSE;
    bccAddressExpandMode.value = ExpandMode.COLLAPSE;
    _updateStatusEmailSendButton();
  }

  Future<void> _applySignature(String signature) async {
    if (PlatformInfo.isWeb) {
      richTextWebController.editorController.insertSignature(signature);
    } else {
      await htmlEditorApi?.insertSignature(signature, allowCollapsed: false);
    }
  }

  Future<void> _removeSignature() async {
    log('ComposerController::_removeSignature():');
    if (PlatformInfo.isWeb) {
      richTextWebController.editorController.removeSignature();
    } else {
      await htmlEditorApi?.removeSignature();
    }
  }

  void insertImage(BuildContext context, double maxWith) async {
    clearFocus(context);

    if (responsiveUtils.isMobile(context)) {
      maxWithEditor = maxWith - 40;
    } else {
      maxWithEditor = maxWith - 70;
    }

    consumeState(_localImagePickerInteractor.execute());
  }

  void _handleUploadInlineSuccess(SuccessAttachmentUploadState uploadState) {
    uploadController.clearUploadInlineViewState();

    final baseDownloadUrl = mailboxDashBoardController.sessionCurrent?.getDownloadUrl(jmapUrl: _dynamicUrlInterceptors.jmapUrl);
    final accountId = mailboxDashBoardController.accountId.value;

    if (baseDownloadUrl != null && accountId != null) {
      final imageUrl = uploadState.attachment.getDownloadUrl(baseDownloadUrl, accountId);
      log('ComposerController::_handleUploadInlineSuccess(): imageUrl: $imageUrl');
      consumeState(_downloadImageAsBase64Interactor.execute(
        imageUrl,
        uploadState.attachment.cid!,
        uploadState.fileInfo,
        maxWidth: maxWithEditor,
      ));
    }
  }

  void handleClickDeleteComposer(BuildContext context) {
    clearFocus(context);
    _closeComposerAction();
  }

  void _onEditorFocusOnMobile() {
    _collapseAllRecipient();
    _autoCreateEmailTag();
  }

  void _onChangeCursorOnMobile(List<int>? coordinates, BuildContext context) {
    final headerEditorMobileWidgetRenderObject = headerEditorMobileWidgetKey.currentContext?.findRenderObject();
    if (headerEditorMobileWidgetRenderObject is RenderBox?) {
      final headerEditorMobileSize = headerEditorMobileWidgetRenderObject?.size;
      if (coordinates?[1] != null && coordinates?[1] != 0) {
        final coordinateY = max((coordinates?[1] ?? 0) - defaultPaddingCoordinateYCursorEditor, 0);
        final realCoordinateY = coordinateY + (headerEditorMobileSize?.height ?? 0);
        final outsideHeight = Get.height - ComposerStyle.keyboardMaxHeight - ComposerStyle.keyboardToolBarHeight;
        final webViewEditorClientY = max(outsideHeight, 0) + scrollController.position.pixels;
        if (scrollController.position.pixels >= realCoordinateY) {
          _scrollToCursorEditor(
            realCoordinateY.toDouble(),
            headerEditorMobileSize?.height ?? 0,
            context,
          );
        } else if ((realCoordinateY) >= webViewEditorClientY) {
          _scrollToCursorEditor(
            realCoordinateY.toDouble(),
            headerEditorMobileSize?.height ?? 0,
            context,
          );
        }
      }
    }
  }

  void _scrollToCursorEditor(
    double realCoordinateY,
    double headerEditorMobileHeight,
    BuildContext context,
  ) {
    scrollController.jumpTo(
      realCoordinateY - (responsiveUtils.isLandscapeMobile(context) ? 0 : headerEditorMobileHeight / 2),
    );
  }

  void _onEnterKeyDown() {
    if(scrollController.position.pixels < scrollController.position.maxScrollExtent) {
      scrollController.animateTo(
        scrollController.position.pixels + 20,
        duration: const Duration(milliseconds: 1),
        curve: Curves.linear,
      );
    }
  }

  void toggleRequestReadReceipt() {
    hasRequestReadReceipt.toggle();
  }

  void _autoFocusFieldWhenLauncher() {
    if (_hasInputFieldFocused) {
      log('ComposerController::_autoFocusFieldWhenLauncher: INPUT_FIELD_FOCUS = true');
      return;
    }

    if (FocusManager.instance.primaryFocus?.hasFocus == true) {
      FocusManager.instance.primaryFocus?.unfocus();
    }

    if (listToEmailAddress.isEmpty) {
      toAddressFocusNode?.requestFocus();
    } else if (subjectEmailInputController.text.isEmpty) {
      subjectEmailInputFocusNode?.requestFocus();
    } else if (PlatformInfo.isWeb) {
      richTextWebController.editorController.setFocus();
    }
  }

  bool get _hasInputFieldFocused =>
    toAddressFocusNode?.hasFocus == true ||
    ccAddressFocusNode?.hasFocus == true ||
    bccAddressFocusNode?.hasFocus == true ||
    subjectEmailInputFocusNode?.hasFocus == true;

  void handleInitHtmlEditorWeb(String initContent) {
    log('ComposerController::handleInitHtmlEditorWeb:');
    _isEmailBodyLoaded = true;
    richTextWebController.editorController.setFullScreen();
    richTextWebController.editorController.setOnDragDropEvent();
    onChangeTextEditorWeb(initContent);
    richTextWebController.setEnableCodeView();
    if (identitySelected.value == null) {
      _getAllIdentities();
    }
  }

  void handleOnFocusHtmlEditorWeb() {
    FocusManager.instance.primaryFocus?.unfocus();
    richTextWebController.editorController.setFocus();
    richTextWebController.closeAllMenuPopup();
  }

  void handleOnUnFocusHtmlEditorWeb() {
    onEditorFocusChange(false);
  }

  void handleOnMouseDownHtmlEditorWeb(BuildContext context) {
    Navigator.maybePop(context);
    FocusScope.of(context).unfocus();
    onEditorFocusChange(true);
  }

  FocusNode? getNextFocusOfToEmailAddress() {
    if (ccRecipientState.value == PrefixRecipientState.enabled) {
      return ccAddressFocusNode;
    } else if (bccRecipientState.value == PrefixRecipientState.enabled) {
      return bccAddressFocusNode;
    } else {
      return subjectEmailInputFocusNode;
    }
  }

  FocusNode? getNextFocusOfCcEmailAddress() {
    if (bccRecipientState.value == PrefixRecipientState.enabled) {
      return bccAddressFocusNode;
    } else {
      return subjectEmailInputFocusNode;
    }
  }

  void handleFocusNextAddressAction() {
    _autoCreateEmailTag();
  }

  bool get isNetworkConnectionAvailable => networkConnectionController.isNetworkConnectionAvailable();

  String? get textEditorWeb => _textEditorWeb;

  HtmlEditorApi? get htmlEditorApi => richTextMobileTabletController.htmlEditorApi;

  void onChangeTextEditorWeb(String? text) {
    if (identitySelected.value != null) {
      initTextEditor(text);
    }
    _textEditorWeb = text;
  }

  void initTextEditor(String? text) {
    _initTextEditor ??= text;
  }

  void setSubjectEmail(String subject) => subjectEmail.value = subject;

  void removeDraggableEmailAddress(DraggableEmailAddress draggableEmailAddress) {
    log('ComposerController::removeDraggableEmailAddress: $draggableEmailAddress');
    switch(draggableEmailAddress.prefix) {
      case PrefixEmailAddress.to:
        listToEmailAddress.remove(draggableEmailAddress.emailAddress);
        toAddressExpandMode.value = ExpandMode.EXPAND;
        break;
      case PrefixEmailAddress.cc:
        listCcEmailAddress.remove(draggableEmailAddress.emailAddress);
        ccAddressExpandMode.value = ExpandMode.EXPAND;
        break;
      case PrefixEmailAddress.bcc:
        listBccEmailAddress.remove(draggableEmailAddress.emailAddress);
        bccAddressExpandMode.value = ExpandMode.EXPAND;
        break;
      default:
        break;
    }
    isInitialRecipient.value = true;
    isInitialRecipient.refresh();

    _updateStatusEmailSendButton();
  }

  void onAttachmentDropZoneListener(Attachment attachment) {
    log('ComposerController::onAttachmentDropZoneListener: attachment = $attachment');
    uploadController.validateTotalSizeAttachmentsBeforeUpload(
      totalSizePreparedFiles: attachment.size?.value ?? 0,
      onValidationSuccess: () => uploadController.initializeUploadAttachments([attachment])
    );
  }

  void _handleGetAllIdentitiesFailure(GetAllIdentitiesFailure failure) async {
    log('ComposerController::_handleGetAllIdentitiesFailure:failure: $failure');
    if (composerArguments.value?.emailActionType == EmailActionType.editSendingEmail && PlatformInfo.isMobile) {
      final signatureContent = await htmlEditorApi?.getSignatureContent();
      log('ComposerController::_handleGetAllIdentitiesFailure:signatureContent: $signatureContent');
      if (signatureContent?.isNotEmpty == true) {
        await _applySignature(signatureContent!);
      }
    }
  }

  Future<void> onChangeIdentity(Identity? newIdentity) async {
    await _selectIdentity(newIdentity);
  }

  void _searchIdentities(String searchText) {
    if (searchText.isEmpty) {
      _getAllIdentities();
    } else {
      listFromIdentities.value = listFromIdentities
        .where((identity) => identity.name?.toLowerCase().contains(searchText.toLowerCase()) == true)
        .toList();
    }
  }

  void openSelectIdentityBottomSheet(BuildContext context) {
    (
      FromComposerBottomSheetBuilder(
        context,
        imagePaths,
        listFromIdentities,
        scrollControllerIdentities,
        searchIdentitiesInputController
      )
      ..onCloseAction(() => popBack())
      ..onChangeIdentityAction((identity) {
        onChangeIdentity(identity);
        popBack();
      })
      ..onTextSearchChangedAction((searchText) => _searchIdentities(searchText))
    ).build();
  }

  void handleClickCloseComposer(BuildContext context) async {
    log('ComposerController::handleClickCloseComposer:');
    if (_closeComposerButtonState == ButtonState.disabled) {
      log('ComposerController::handleClickCloseComposer: _closeComposerButtonState = disabled');
      return;
    }

    _closeComposerButtonState = ButtonState.disabled;

    if (composerArguments.value == null) {
      log('ComposerController::handleClickCloseComposer: ARGUMENTS is NULL');
      clearFocus(context);
      _closeComposerAction();
      return;
    }

    final isChanged = await _validateEmailChange(
      context: context,
      emailActionType: composerArguments.value!.emailActionType,
      presentationEmail: composerArguments.value!.presentationEmail,
      mailboxRole: composerArguments.value!.mailboxRole
    );

    if (isChanged && context.mounted) {
      clearFocus(context);
      _showConfirmDialogSaveMessage(context);
      return;
    }

    if (!_isEmailBodyLoaded && context.mounted) {
      log('ComposerController::handleClickCloseComposer: EDITOR NOT LOADED');
      _closeComposerButtonState = ButtonState.enabled;
      clearFocus(context);
      _closeComposerAction();
      return;
    }

    if (context.mounted) {
      _closeComposerButtonState = ButtonState.enabled;
      clearFocus(context);
      _closeComposerAction();
    }
  }

  void _showConfirmDialogSaveMessage(BuildContext context) {
    showConfirmDialogAction(
      context,
      title: AppLocalizations.of(context).saveMessage.capitalizeFirstEach,
      AppLocalizations.of(context).warningMessageWhenClickCloseComposer,
      AppLocalizations.of(context).save,
      cancelTitle: AppLocalizations.of(context).discardChanges,
      alignCenter: true,
      onConfirmAction: () async => await Future.delayed(
        const Duration(milliseconds: 100),
        () => _handleSaveMessageToDraft(context)
      ),
      onCancelAction: () async {
        _closeComposerButtonState = ButtonState.enabled;
        await Future.delayed(
          const Duration(milliseconds: 100),
          _closeComposerAction
        );
      },
      onCloseButtonAction: () {
        _closeComposerButtonState = ButtonState.enabled;
        popBack();
        _autoFocusFieldWhenLauncher();
      },
      marginIcon: EdgeInsets.zero,
      icon: SvgPicture.asset(
        imagePaths.icQuotasWarning,
        width: 40,
        height: 40,
        colorFilter: AppColor.colorBackgroundQuotasWarning.asFilter(),
      ),
      titleStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black
      ),
      messageStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
        fontSize: 14,
        color: AppColor.colorTextBody
      ),
      actionStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
        fontSize: 17,
        color: Colors.white
      ),
      cancelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
        fontSize: 17,
        color: Colors.black
      )
    );
  }

  void _getAlwaysReadReceiptSetting() {
    final accountId = mailboxDashBoardController.accountId.value;
    if (accountId != null) {
      consumeState(_getAlwaysReadReceiptSettingInteractor.execute(accountId));
    }
  }

  void handleOnDragEnterHtmlEditorWeb() {
    mailboxDashBoardController.localFileDraggableAppState.value = DraggableAppState.active;
  }

  void onLocalFileDropZoneListener({
    required BuildContext context,
    required DropDoneDetails details,
    required double maxWidth
  }) async {
    if (responsiveUtils.isMobile(context)) {
      maxWithEditor = maxWidth - 40;
    } else {
      maxWithEditor = maxWidth - 70;
    }

    final listFileInfo = await onDragDone(context: context, details: details);

    if (listFileInfo.isEmpty && context.mounted) {
      appToast.showToastErrorMessage(
        context,
        AppLocalizations.of(context).can_not_upload_this_file_as_attachments
      );
      return;
    }

    final listAttachments = listFileInfo
      .where((fileInfo) => fileInfo.isInline != true)
      .toList();

    uploadController.validateTotalSizeAttachmentsBeforeUpload(
      totalSizePreparedFiles: listFileInfo.totalSize,
      totalSizePreparedFilesWithDispositionAttachment: listAttachments.totalSize,
      onValidationSuccess: () => _uploadAttachmentsAction(pickedFiles: listFileInfo)
    );
  }

  void _handleSaveMessageToDraft(BuildContext context) async {
    if (composerArguments.value == null ||
        mailboxDashBoardController.sessionCurrent == null ||
        mailboxDashBoardController.accountId.value == null ||
        mailboxDashBoardController.mapDefaultMailboxIdByRole[PresentationMailbox.roleDrafts] == null
    ) {
      log('ComposerController::_handleSaveMessageToDraft: SESSION or ACCOUNT_ID or ARGUMENTS is NULL');
      _closeComposerButtonState = ButtonState.enabled;
      _closeComposerAction();
      return;
    }

    final emailContent = await _getContentInEditor();
    final draftEmailId = _getDraftEmailId();
    log('ComposerController::_handleSaveMessageToDraft: draftEmailId = $draftEmailId');
    final cancelToken = CancelToken();
    final resultState = await _showSavingMessageToDraftsDialog(
      emailContent: emailContent,
      draftEmailId: draftEmailId,
      cancelToken: cancelToken
    );

    if (resultState is SaveEmailAsDraftsSuccess || resultState is UpdateEmailDraftsSuccess) {
      _closeComposerButtonState = ButtonState.enabled;
      _closeComposerAction(result: resultState);
    } else if ((resultState is SaveEmailAsDraftsFailure && resultState.exception is SavingEmailToDraftsCanceledException) ||
        (resultState is UpdateEmailDraftsFailure && resultState.exception is SavingEmailToDraftsCanceledException)) {
      _closeComposerButtonState = ButtonState.enabled;
      _closeComposerAction();
    } else if ((resultState is SaveEmailAsDraftsFailure ||
        resultState is UpdateEmailDraftsFailure ||
        resultState is GenerateEmailFailure) &&
        context.mounted
    ) {
      _showConfirmDialogWhenSaveMessageToDraftsFailure(
        context: context,
        failure: resultState
      );
    } else {
      _closeComposerButtonState = ButtonState.enabled;
    }
  }

  EmailId? _getDraftEmailId() {
    if (_emailIdEditing != null &&
        _emailIdEditing != composerArguments.value!.presentationEmail?.id) {
      return _emailIdEditing;
    } else if (composerArguments.value!.emailActionType == EmailActionType.editDraft) {
      return composerArguments.value!.presentationEmail?.id;
    } else {
      return null;
    }
  }

  Future<dynamic> _showSavingMessageToDraftsDialog({
    required String emailContent,
    EmailId? draftEmailId,
    CancelToken? cancelToken,
  }) {
    final childWidget = PointerInterceptor(
      child: SavingMessageDialogView(
        createEmailRequest: CreateEmailRequest(
          session: mailboxDashBoardController.sessionCurrent!,
          accountId: mailboxDashBoardController.accountId.value!,
          emailActionType: composerArguments.value!.emailActionType,
          subject: subjectEmail.value ?? '',
          emailContent: emailContent,
          fromSender: composerArguments.value!.presentationEmail?.from ?? {},
          toRecipients: listToEmailAddress.toSet(),
          ccRecipients: listCcEmailAddress.toSet(),
          bccRecipients: listBccEmailAddress.toSet(),
          isRequestReadReceipt: hasRequestReadReceipt.value,
          identity: identitySelected.value,
          attachments: uploadController.attachmentsUploaded,
          inlineAttachments: uploadController.mapInlineAttachments,
          sentMailboxId: mailboxDashBoardController.mapDefaultMailboxIdByRole[PresentationMailbox.roleSent],
          draftsMailboxId: mailboxDashBoardController.mapDefaultMailboxIdByRole[PresentationMailbox.roleDrafts],
          draftsEmailId: draftEmailId,
          answerForwardEmailId: composerArguments.value!.presentationEmail?.id,
          unsubscribeEmailId: composerArguments.value!.previousEmailId,
          messageId: composerArguments.value!.messageId,
          references: composerArguments.value!.references,
          emailSendingQueue: composerArguments.value!.sendingEmail
        ),
        createNewAndSaveEmailToDraftsInteractor: _createNewAndSaveEmailToDraftsInteractor,
        onCancelSavingEmailToDraftsAction: _handleCancelSavingMessageToDrafts,
        cancelToken: cancelToken,
      ),
    );
    return Get.dialog(
      PlatformInfo.isMobile
        ? PopScope(canPop: false, child: childWidget)
        : childWidget,
      barrierDismissible: false,
      barrierColor: AppColor.colorDefaultCupertinoActionSheet,
    );
  }

  void _handleCancelSavingMessageToDrafts({CancelToken? cancelToken}) {
    cancelToken?.cancel([SavingEmailToDraftsCanceledException()]);
  }

  void _showConfirmDialogWhenSaveMessageToDraftsFailure({
    required BuildContext context,
    required FeatureFailure failure,
    VoidCallback? onConfirmAction,
    VoidCallback? onCancelAction,
  }) {
    showConfirmDialogAction(
      context,
      title: '',
      AppLocalizations.of(context).warningMessageWhenSaveEmailToDraftsFailure,
      AppLocalizations.of(context).edit,
      cancelTitle: AppLocalizations.of(context).closeAnyway,
      alignCenter: true,
      onConfirmAction: onConfirmAction ?? () {
        _closeComposerButtonState = ButtonState.enabled;
        _autoFocusFieldWhenLauncher();
      },
      onCancelAction: onCancelAction ?? () async {
        _closeComposerButtonState = ButtonState.enabled;
        await Future.delayed(
          const Duration(milliseconds: 100),
          _closeComposerAction
        );
      },
      icon: SvgPicture.asset(
        imagePaths.icQuotasWarning,
        width: 40,
        height: 40,
        colorFilter: AppColor.colorBackgroundQuotasWarning.asFilter(),
      ),
      messageStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
        fontSize: 14,
        color: AppColor.colorTextBody
      ),
      actionStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
        fontSize: 17,
        color: Colors.white
      ),
      cancelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
        fontSize: 17,
        color: Colors.black
      )
    );
  }

  void handleEnableRecipientsInputAction(bool isEnabled) {
    fromRecipientState.value = isEnabled ? PrefixRecipientState.disabled : PrefixRecipientState.enabled;
    ccRecipientState.value = isEnabled ? PrefixRecipientState.disabled : PrefixRecipientState.enabled;
    bccRecipientState.value = isEnabled ? PrefixRecipientState.disabled : PrefixRecipientState.enabled;
  }
}