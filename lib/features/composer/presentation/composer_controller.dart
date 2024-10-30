
import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:core/core.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
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
import 'package:html/parser.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/email/individual_header_identifier.dart';
import 'package:model/model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:rich_text_composer/rich_text_composer.dart';
import 'package:super_tag_editor/tag_editor.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/base/before_reconnect_handler.dart';
import 'package:tmail_ui_user/features/base/before_reconnect_manager.dart';
import 'package:tmail_ui_user/features/base/mixin/auto_complete_result_mixin.dart';
import 'package:tmail_ui_user/features/base/state/base_ui_state.dart';
import 'package:tmail_ui_user/features/base/state/button_state.dart';
import 'package:tmail_ui_user/features/composer/domain/exceptions/compose_email_exception.dart';
import 'package:tmail_ui_user/features/composer/domain/model/contact_suggestion_source.dart';
import 'package:tmail_ui_user/features/composer/domain/state/download_image_as_base64_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/generate_email_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/restore_email_inline_images_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/save_email_as_drafts_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/send_email_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/update_email_drafts_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/upload_attachment_state.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/create_new_and_save_email_to_drafts_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/create_new_and_send_email_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/download_image_as_base64_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_all_autocomplete_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_autocomplete_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_device_contact_suggestions_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/restore_email_inline_images_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/save_composer_cache_on_web_interactor.dart';
import 'package:tmail_ui_user/features/composer/presentation/controller/rich_text_mobile_tablet_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/controller/rich_text_web_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/email_action_type_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/get_draft_mailbox_id_for_composer_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/get_outbox_mailbox_id_for_composer_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/get_sent_mailbox_id_for_composer_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/list_identities_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/list_shared_media_file_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/mixin/drag_drog_file_mixin.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/create_email_request.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/draggable_email_address.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/saved_email_draft.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/signature_status.dart';
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
import 'package:tmail_ui_user/features/email/domain/usecases/print_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/transform_html_email_content_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/presentation_email_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
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
import 'package:tmail_ui_user/features/upload/domain/extensions/list_file_upload_extension.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';
import 'package:tmail_ui_user/features/upload/domain/state/attachment_upload_state.dart';
import 'package:tmail_ui_user/features/upload/domain/state/local_file_picker_state.dart';
import 'package:tmail_ui_user/features/upload/domain/state/local_image_picker_state.dart';
import 'package:tmail_ui_user/features/upload/domain/usecases/local_file_picker_interactor.dart';
import 'package:tmail_ui_user/features/upload/domain/usecases/local_image_picker_interactor.dart';
import 'package:tmail_ui_user/features/upload/presentation/controller/upload_controller.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/universal_import/html_stub.dart' as html;

class ComposerController extends BaseController
    with DragDropFileMixin, AutoCompleteResultMixin
    implements BeforeReconnectHandler {

  final mailboxDashBoardController = Get.find<MailboxDashBoardController>();
  final networkConnectionController = Get.find<NetworkConnectionController>();
  final _beforeReconnectManager = Get.find<BeforeReconnectManager>();

  final composerArguments = Rxn<ComposerArguments>();
  final isEnableEmailSendButton = false.obs;
  final isInitialRecipient = false.obs;
  final subjectEmail = Rxn<String>();
  final screenDisplayMode = ScreenDisplayMode.normal.obs;
  final toAddressExpandMode = ExpandMode.EXPAND.obs;
  final ccAddressExpandMode = ExpandMode.EXPAND.obs;
  final bccAddressExpandMode = ExpandMode.EXPAND.obs;
  final replyToAddressExpandMode = ExpandMode.EXPAND.obs;
  final emailContentsViewState = Rxn<Either<Failure, Success>>();
  final hasRequestReadReceipt = false.obs;
  final fromRecipientState = PrefixRecipientState.disabled.obs;
  final ccRecipientState = PrefixRecipientState.disabled.obs;
  final bccRecipientState = PrefixRecipientState.disabled.obs;
  final replyToRecipientState = PrefixRecipientState.disabled.obs;
  final identitySelected = Rxn<Identity>();
  final listFromIdentities = RxList<Identity>();
  final isEmailChanged = Rx<bool>(false);

  final LocalFilePickerInteractor _localFilePickerInteractor;
  final LocalImagePickerInteractor _localImagePickerInteractor;
  final GetEmailContentInteractor _getEmailContentInteractor;
  final GetAllIdentitiesInteractor _getAllIdentitiesInteractor;
  final UploadController uploadController;
  final RemoveComposerCacheOnWebInteractor _removeComposerCacheOnWebInteractor;
  final SaveComposerCacheOnWebInteractor _saveComposerCacheOnWebInteractor;
  final DownloadImageAsBase64Interactor _downloadImageAsBase64Interactor;
  final TransformHtmlEmailContentInteractor _transformHtmlEmailContentInteractor;
  final GetAlwaysReadReceiptSettingInteractor _getAlwaysReadReceiptSettingInteractor;
  final CreateNewAndSendEmailInteractor _createNewAndSendEmailInteractor;
  final CreateNewAndSaveEmailToDraftsInteractor _createNewAndSaveEmailToDraftsInteractor;
  final PrintEmailInteractor printEmailInteractor;

  GetAllAutoCompleteInteractor? _getAllAutoCompleteInteractor;
  GetAutoCompleteInteractor? _getAutoCompleteInteractor;
  GetDeviceContactSuggestionsInteractor? _getDeviceContactSuggestionsInteractor;
  RestoreEmailInlineImagesInteractor? _restoreEmailInlineImagesInteractor;

  List<EmailAddress> listToEmailAddress = <EmailAddress>[];
  List<EmailAddress> listCcEmailAddress = <EmailAddress>[];
  List<EmailAddress> listBccEmailAddress = <EmailAddress>[];
  List<EmailAddress> listReplyToEmailAddress = <EmailAddress>[];
  ContactSuggestionSource _contactSuggestionSource = ContactSuggestionSource.tMailContact;

  final subjectEmailInputController = TextEditingController();
  final toEmailAddressController = TextEditingController();
  final ccEmailAddressController = TextEditingController();
  final bccEmailAddressController = TextEditingController();
  final replyToEmailAddressController = TextEditingController();
  final searchIdentitiesInputController = TextEditingController();

  final GlobalKey<TagsEditorState> keyToEmailTagEditor = GlobalKey<TagsEditorState>();
  final GlobalKey<TagsEditorState> keyCcEmailTagEditor = GlobalKey<TagsEditorState>();
  final GlobalKey<TagsEditorState> keyBccEmailTagEditor = GlobalKey<TagsEditorState>();
  final GlobalKey<TagsEditorState> keyReplyToEmailTagEditor = GlobalKey<TagsEditorState>();
  final GlobalKey headerEditorMobileWidgetKey = GlobalKey();
  final GlobalKey<DropdownButton2State> identityDropdownKey = GlobalKey<DropdownButton2State>();
  final double defaultPaddingCoordinateYCursorEditor = 8;

  FocusNode? subjectEmailInputFocusNode;
  FocusNode? toAddressFocusNode;
  FocusNode? ccAddressFocusNode;
  FocusNode? bccAddressFocusNode;
  FocusNode? replyToAddressFocusNode;
  FocusNode? searchIdentitiesFocusNode;
  FocusNode? toAddressFocusNodeKeyboard;
  FocusNode? ccAddressFocusNodeKeyboard;
  FocusNode? bccAddressFocusNodeKeyboard;
  FocusNode? replyToAddressFocusNodeKeyboard;

  StreamSubscription<html.Event>? _subscriptionOnDragEnter;
  StreamSubscription<html.Event>? _subscriptionOnDragOver;
  StreamSubscription<html.Event>? _subscriptionOnDragLeave;
  StreamSubscription<html.Event>? _subscriptionOnDrop;
  StreamSubscription<String>? _composerCacheListener;

  RichTextMobileTabletController? richTextMobileTabletController;
  RichTextWebController? richTextWebController;
  CustomPopupMenuController? menuMoreOptionController;

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
  ButtonState printDraftButtonState = ButtonState.enabled;
  SignatureStatus _identityContentOnOpenPolicy = SignatureStatus.editedAvailable;
  int? _savedEmailDraftHash;
  bool _restoringSignatureButton = false;
  GlobalKey? responsiveContainerKey;
  
  @visibleForTesting
  bool get restoringSignatureButton => _restoringSignatureButton;

  @visibleForTesting
  int? get savedEmailDraftHash => _savedEmailDraftHash;

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
    this._downloadImageAsBase64Interactor,
    this._transformHtmlEmailContentInteractor,
    this._getAlwaysReadReceiptSettingInteractor,
    this._createNewAndSendEmailInteractor,
    this._createNewAndSaveEmailToDraftsInteractor,
    this.printEmailInteractor,
  );

  @override
  void onInit() {
    super.onInit();
    if (PlatformInfo.isWeb) {
      responsiveContainerKey = GlobalKey();
      richTextWebController = getBinding<RichTextWebController>();
      responsiveContainerKey = GlobalKey();
      menuMoreOptionController = CustomPopupMenuController();
    } else {
      richTextMobileTabletController = getBinding<RichTextMobileTabletController>();
    }
    createFocusNodeInput();
    scrollControllerEmailAddress.addListener(_scrollControllerEmailAddressListener);
    _listenStreamEvent();
    _beforeReconnectManager.addListener(onBeforeReconnect);
  }

  @override
  void onReady() {
    if (PlatformInfo.isWeb) {
      _triggerBrowserEventListener();
    }
    _initEmail();
    if (PlatformInfo.isMobile) {
      Future.delayed(const Duration(milliseconds: 500), _checkContactPermission);
    }
    super.onReady();
  }

  @override
  void onClose() {
    _initTextEditor = null;
    _textEditorWeb = null;
    dispatchState(Right(UIClosedState()));
    composerArguments.value = null;
    emailContentsViewState.value = Right(UIClosedState());
    identitySelected.value = null;
    listFromIdentities.clear();
    _subscriptionOnDragEnter?.cancel();
    _subscriptionOnDragOver?.cancel();
    _subscriptionOnDragLeave?.cancel();
    _subscriptionOnDrop?.cancel();
    subjectEmailInputFocusNode?.removeListener(_subjectEmailInputFocusListener);
    _composerCacheListener?.cancel();
    _beforeReconnectManager.removeListener(onBeforeReconnect);
    if (PlatformInfo.isWeb) {
      richTextWebController = null;
      responsiveContainerKey = null;
      menuMoreOptionController?.dispose();
      menuMoreOptionController = null;
    } else {
      richTextMobileTabletController = null;
    }
    _identityContentOnOpenPolicy = SignatureStatus.editedAvailable;
    responsiveContainerKey = null;
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
    replyToAddressFocusNode?.dispose();
    replyToAddressFocusNode = null;
    toAddressFocusNodeKeyboard?.dispose();
    toAddressFocusNodeKeyboard = null;
    ccAddressFocusNodeKeyboard?.dispose();
    ccAddressFocusNodeKeyboard = null;
    bccAddressFocusNodeKeyboard?.dispose();
    bccAddressFocusNodeKeyboard = null;
    replyToAddressFocusNodeKeyboard?.dispose();
    replyToAddressFocusNodeKeyboard = null;
    searchIdentitiesFocusNode?.dispose();
    searchIdentitiesFocusNode = null;
    subjectEmailInputController.dispose();
    toEmailAddressController.dispose();
    ccEmailAddressController.dispose();
    bccEmailAddressController.dispose();
    replyToEmailAddressController.dispose();
    uploadInlineImageWorker.dispose();
    dashboardViewStateWorker.dispose();
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
        success is TransformHtmlEmailContentSuccess ||
        success is RestoringEmailInlineImages) {
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
        richTextWebController?.insertImage(inlineImage);
      } else {
        richTextMobileTabletController?.insertImage(inlineImage);
      }
      maxWithEditor = null;
    } else if (success is GetAlwaysReadReceiptSettingSuccess) {
      hasRequestReadReceipt.value = success.alwaysReadReceiptEnabled;
      _initEmailDraftHash();
    } else if (success is RestoreEmailInlineImagesSuccess) {
      _updateEditorContent(success);
    }
  }

  void _updateEditorContent(RestoreEmailInlineImagesSuccess success) {
    richTextWebController?.editorController.setText(success.emailContent);
    consumeState(Stream.value(Right(GetEmailContentSuccess(htmlEmailContent: success.emailContent))));
  }

  @override
  void handleFailureViewState(Failure failure) {
    super.handleFailureViewState(failure);
    if (failure is LocalFilePickerFailure) {
      _handlePickFileFailure(failure);
    } else if (failure is LocalImagePickerFailure) {
      _handlePickImageFailure(failure);
    } else if (failure is GetEmailContentFailure) {
      _handleGetEmailContentFailure(failure);
    } else if (failure is TransformHtmlEmailContentFailure
        || failure is RestoreEmailInlineImagesFailure) {
      emailContentsViewState.value = Left(failure);
    } else if (failure is GetAllIdentitiesFailure) {
      if (identitySelected.value == null) {
        _autoFocusFieldWhenLauncher();
      }
    } else if (failure is GetAlwaysReadReceiptSettingFailure) {
      hasRequestReadReceipt.value = false;
      _initEmailDraftHash();
    }
  }

  @override
  void handleUrgentExceptionOnMobile({Failure? failure, Exception? exception}) {
    if (failure is GetAllIdentitiesFailure && exception is! BadCredentialsException) {
      _handleGetAllIdentitiesFailure();
    }
    super.handleUrgentExceptionOnMobile(failure: failure, exception: exception);
  }

  @override
  Future<void> onUnloadBrowserListener(html.Event event) async {
    await _removeComposerCacheOnWebInteractor.execute();
    await _saveComposerCacheOnWebAction();
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

  void _triggerBrowserEventListener() {
    _subscriptionOnDragEnter = html.window.onDragEnter.listen((event) {
      event.preventDefault();

      if (event.dataTransfer.types.validateFilesTransfer) {
        mailboxDashBoardController.localFileDraggableAppState.value = DraggableAppState.active;
      }
    });

    _subscriptionOnDragOver = html.window.onDragOver.listen((event) {
      event.preventDefault();

      if (event.dataTransfer.types.validateFilesTransfer) {
        mailboxDashBoardController.localFileDraggableAppState.value = DraggableAppState.active;
      }
    });

    _subscriptionOnDragLeave = html.window.onDragLeave.listen((event) {
      event.preventDefault();

      if (event.dataTransfer.types.validateFilesTransfer) {
        mailboxDashBoardController.localFileDraggableAppState.value = DraggableAppState.inActive;
      }
    });

    _subscriptionOnDrop = html.window.onDrop.listen((event) {
      event.preventDefault();

      if (event.dataTransfer.types.validateFilesTransfer) {
        mailboxDashBoardController.localFileDraggableAppState.value = DraggableAppState.inActive;
      }
    });
  }

  Future<void> _saveComposerCacheOnWebAction() async {
    _autoCreateEmailTag();

    final createEmailRequest = await _generateCreateEmailRequest();
    if (createEmailRequest == null) return;

    await _saveComposerCacheOnWebInteractor.execute(
      createEmailRequest,
      mailboxDashBoardController.accountId.value!,
      mailboxDashBoardController.sessionCurrent!.username);
  }

  Future<CreateEmailRequest?> _generateCreateEmailRequest() async {
    if (composerArguments.value == null ||
        mailboxDashBoardController.sessionCurrent == null ||
        mailboxDashBoardController.accountId.value == null
    ) {
      log('ComposerController::_generateCreateEmailRequest: SESSION or ACCOUNT_ID or ARGUMENTS is NULL');
      return null;
    }
    
    final emailContent = await getContentInEditor();
    
    return CreateEmailRequest(
      session: mailboxDashBoardController.sessionCurrent!,
      accountId: mailboxDashBoardController.accountId.value!,
      emailActionType: composerArguments.value!.emailActionType,
      subject: subjectEmail.value ?? '',
      emailContent: emailContent,
      fromSender: composerArguments.value!.presentationEmail?.from ?? {},
      toRecipients: listToEmailAddress.toSet(),
      ccRecipients: listCcEmailAddress.toSet(),
      bccRecipients: listBccEmailAddress.toSet(),
      replyToRecipients: listReplyToEmailAddress.toSet(),
      hasRequestReadReceipt: hasRequestReadReceipt.value,
      identity: identitySelected.value,
      attachments: uploadController.attachmentsUploaded,
      inlineAttachments: uploadController.mapInlineAttachments,
      outboxMailboxId: getOutboxMailboxIdForComposer(),
      sentMailboxId: getSentMailboxIdForComposer(),
      draftsMailboxId: getDraftMailboxIdForComposer(),
      draftsEmailId: getDraftEmailId(),
      answerForwardEmailId: composerArguments.value!.presentationEmail?.id,
      unsubscribeEmailId: composerArguments.value!.previousEmailId,
      messageId: composerArguments.value!.messageId,
      references: composerArguments.value!.references,
      emailSendingQueue: composerArguments.value!.sendingEmail,
      displayMode: screenDisplayMode.value
    );
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
    if (replyToEmailAddressController.text.isNotEmpty) {
      keyReplyToEmailTagEditor.currentState?.closeSuggestionBox();
    }
  }

  void createFocusNodeInput() {
    toAddressFocusNode = FocusNode();
    ccAddressFocusNode = FocusNode();
    bccAddressFocusNode = FocusNode();
    replyToAddressFocusNode = FocusNode();
    searchIdentitiesFocusNode = FocusNode();
    toAddressFocusNodeKeyboard = FocusNode();
    ccAddressFocusNodeKeyboard = FocusNode();
    bccAddressFocusNodeKeyboard = FocusNode();
    replyToAddressFocusNodeKeyboard = FocusNode();

    subjectEmailInputFocusNode = FocusNode(
      onKeyEvent: PlatformInfo.isWeb ? _subjectEmailInputOnKeyListener : null,
    );
    subjectEmailInputFocusNode?.addListener(_subjectEmailInputFocusListener);
  }

  void _subjectEmailInputFocusListener() {
    if (subjectEmailInputFocusNode?.hasFocus == true) {
      if (PlatformInfo.isMobile
          && currentContext != null
          && !responsiveUtils.isScreenWithShortestSide(currentContext!)) {
        richTextMobileTabletController?.richTextController.hideRichTextView();
      }
      _collapseAllRecipient();
      _autoCreateEmailTag();
    }
  }

  KeyEventResult _subjectEmailInputOnKeyListener(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.tab) {
      subjectEmailInputFocusNode?.unfocus();
      richTextWebController?.editorController.setFocus();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void onCreatedMobileEditorAction(BuildContext context, HtmlEditorApi editorApi, String? content) {
    if (identitySelected.value != null) {
      initTextEditor(content);
    }
    richTextMobileTabletController?.htmlEditorApi = editorApi;
    richTextMobileTabletController?.richTextController.onCreateHTMLEditor(
      editorApi,
      onEnterKeyDown: _onEnterKeyDown,
      onFocus: _onEditorFocusOnMobile,
      onChangeCursor: (coordinates) {
        _onChangeCursorOnMobile(coordinates, context);
      },
    );
  }

  void onLoadCompletedMobileEditorAction(HtmlEditorApi editorApi, WebUri? url) async {
    _isEmailBodyLoaded = true;
    if (identitySelected.value == null) {
      _getAllIdentities();
    } else {
      await _selectIdentity(identitySelected.value);
      _autoFocusFieldWhenLauncher();
    }
  }

  void _initEmail() {
    _isEmailBodyLoaded = false;
    final arguments = PlatformInfo.isWeb
      ? mailboxDashBoardController.composerArguments
      : Get.arguments;
    if (arguments is ComposerArguments) {
      composerArguments.value = arguments;

      _initIdentities(arguments);

      injectAutoCompleteBindings(
        mailboxDashBoardController.sessionCurrent,
        mailboxDashBoardController.accountId.value
      );

      switch(arguments.emailActionType) {
        case EmailActionType.composeFromPresentationEmail:
          _initEmailAddress(
            presentationEmail: arguments.presentationEmail!,
            actionType: EmailActionType.composeFromPresentationEmail
          );
          _initSubjectEmail(
            presentationEmail: arguments.presentationEmail!,
            actionType: EmailActionType.composeFromPresentationEmail
          );
          _getEmailContentOfEmailDrafts(
            emailId: arguments.presentationEmail!.id!,
          );
          break;
        case EmailActionType.editDraft:
          _initEmailAddress(
            presentationEmail: arguments.presentationEmail!,
            actionType: EmailActionType.editDraft
          );
          _initSubjectEmail(
            presentationEmail: arguments.presentationEmail!,
            actionType: EmailActionType.editDraft
          );
          _getEmailContentOfEmailDrafts(
            emailId: arguments.presentationEmail!.id!,
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
          final allAttachments = arguments.sendingEmail!.email.allAttachments;
          _initAttachmentsAndInlineImages(
            attachments: allAttachments.getListAttachmentsDisplayedOutside(
              arguments.sendingEmail!.email.htmlBodyAttachments),
            inlineImages: allAttachments.listAttachmentsDisplayedInContent);

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
          if (arguments.cc?.isNotEmpty == true) {
            listCcEmailAddress = arguments.cc!;
            ccRecipientState.value = PrefixRecipientState.enabled;
            ccAddressExpandMode.value = ExpandMode.COLLAPSE;
          }
          if (arguments.bcc?.isNotEmpty == true) {
            bccRecipientState.value = PrefixRecipientState.enabled;
            bccAddressExpandMode.value = ExpandMode.COLLAPSE;
            listBccEmailAddress = arguments.bcc!;
          }
          _getEmailContentFromMailtoUri(arguments.body ?? '');
          _updateStatusEmailSendButton();
          break;
        case EmailActionType.reply:
        case EmailActionType.replyToList:
        case EmailActionType.replyAll:
          log('ComposerController::_initEmail:listPost = ${arguments.listPost}');
          _initEmailAddress(
            presentationEmail: arguments.presentationEmail!,
            actionType: arguments.emailActionType,
            listPost: arguments.listPost,
          );
          _initSubjectEmail(
            presentationEmail: arguments.presentationEmail!,
            actionType: arguments.emailActionType
          );
          _initAttachmentsAndInlineImages(
            attachments: arguments.attachments,
            inlineImages: arguments.inlineImages);

          _transformHtmlEmailContent(arguments.emailContents);
          break;
        case EmailActionType.forward:
          _initSubjectEmail(
            presentationEmail: arguments.presentationEmail!,
            actionType: arguments.emailActionType
          );
          _initAttachmentsAndInlineImages(
            attachments: arguments.attachments,
            inlineImages: arguments.inlineImages);
          _transformHtmlEmailContent(arguments.emailContents);
          break;
        case EmailActionType.reopenComposerBrowser:
          if (!PlatformInfo.isWeb) return;

          screenDisplayMode.value = arguments.displayMode;

          _initEmailAddress(
            presentationEmail: arguments.presentationEmail!,
            actionType: EmailActionType.reopenComposerBrowser
          );
          _initSubjectEmail(
            presentationEmail: arguments.presentationEmail!,
            actionType: EmailActionType.reopenComposerBrowser
          );
          _initAttachmentsAndInlineImages(
            attachments: arguments.attachments,
            inlineImages: arguments.inlineImages);

          final accountId = mailboxDashBoardController.accountId.value;
          dynamic downloadUrl;
          try {
            downloadUrl = mailboxDashBoardController.sessionCurrent
              ?.getDownloadUrl(jmapUrl: dynamicUrlInterceptors.jmapUrl);
          } catch (e) {
            logError('ComposerController::_initEmail(): $e');
            downloadUrl = null;
          }

          if (accountId == null || downloadUrl == null) return;
          _getEmailContentFromSessionStorageBrowser(
            htmlContent: arguments.emailContents ?? '',
            inlineImages: arguments.inlineImages ?? [],
            accountId: accountId,
            downloadUrl: downloadUrl
          );
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

      if (composerArguments.value?.emailActionType == EmailActionType.reopenComposerBrowser) {
        log('ComposerController::_initEmail: hasRequestReadReceipt = ${arguments.hasRequestReadReceipt}');
        hasRequestReadReceipt.value = arguments.hasRequestReadReceipt ?? false;
      } else if (composerArguments.value?.emailActionType != EmailActionType.editDraft) {
        _getAlwaysReadReceiptSetting();
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

  void _initAttachmentsAndInlineImages({
    List<Attachment>? attachments,
    List<Attachment>? inlineImages
  }) {
    if (attachments?.isNotEmpty == true) {
      initialAttachments = attachments!;
      uploadController.initializeUploadAttachments(attachments);
    }
    if (inlineImages?.isNotEmpty == true) {
      uploadController.initializeUploadInlineAttachments(inlineImages!);
    }
  }

  Identity? _selectIdentityFromId(IdentityId? identityId) {
    if (identityId == null) return null;

    return listFromIdentities.firstWhereOrNull(
      (identity) => identity.id == identityId);
  }

  Future<void> _initIdentities(ComposerArguments composerArguments) async {
    listFromIdentities.value = composerArguments.identities ?? [];
    final selectedIdentityFromId = _selectIdentityFromId(
      composerArguments.selectedIdentityId);
    if (listFromIdentities.isEmpty) {
      _getAllIdentities();
    } else if (selectedIdentityFromId != null) {
      await _selectIdentity(selectedIdentityFromId);
      _initEmailDraftHash();
    } else if (composerArguments.identities?.isNotEmpty == true) {
      await _selectIdentity(composerArguments.identities!.first);
      _initEmailDraftHash();
    }
  }

  void _getAllIdentities() {
    log('ComposerController::_getAllIdentities: Fetch again identity !');
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
        final selectedIdentityFromId = _selectIdentityFromId(
          composerArguments.value?.selectedIdentityId);
        if (selectedIdentityFromId != null) {
          await _selectIdentity(selectedIdentityFromId);
          _initEmailDraftHash();
        } else {
          await _selectIdentity(listIdentitiesMayDeleted.firstOrNull);
          _initEmailDraftHash();
        }
      }
    }
    _autoFocusFieldWhenLauncher();
  }

  void _initEmailAddress({
    required PresentationEmail presentationEmail,
    required EmailActionType actionType,
    String? listPost,
  }) {
    final senderEmailAddress = mailboxDashBoardController.sessionCurrent?.getOwnEmailAddress();
    final isSender = presentationEmail.from
      .asList()
      .any((element) => element.emailAddress.isNotEmpty && element.emailAddress == senderEmailAddress);

    final recipients = presentationEmail.generateRecipientsEmailAddressForComposer(
      emailActionType: actionType,
      isSender: isSender,
      userName: senderEmailAddress,
      listPost: listPost,
    );

    listToEmailAddress = List.from(recipients.value1);
    listCcEmailAddress = List.from(recipients.value2);
    listBccEmailAddress = List.from(recipients.value3);

    if (listToEmailAddress.isNotEmpty || listCcEmailAddress.isNotEmpty || listBccEmailAddress.isNotEmpty || listReplyToEmailAddress.isNotEmpty) {
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

    if (listReplyToEmailAddress.isNotEmpty) {
      replyToRecipientState.value = PrefixRecipientState.enabled;
      replyToAddressExpandMode.value = ExpandMode.COLLAPSE;
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
      case PrefixEmailAddress.replyTo:
        listReplyToEmailAddress = List.from(newListEmailAddress);
        break;
      default:
        break;
    }
    _updateStatusEmailSendButton();
  }

  void _updateStatusEmailSendButton() {
    if (listToEmailAddress.isNotEmpty
        || listCcEmailAddress.isNotEmpty
        || listBccEmailAddress.isNotEmpty
        || listReplyToEmailAddress.isNotEmpty) {
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
        || bccEmailAddressController.text.isNotEmpty
        || replyToEmailAddressController.text.isNotEmpty) {
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

    final allListEmailAddress = listToEmailAddress + listCcEmailAddress + listBccEmailAddress + listReplyToEmailAddress;
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
          replyToAddressExpandMode.value = ExpandMode.EXPAND;
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
        onCancelAction: popBack,
        autoPerformPopBack: false,
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

  Future<String> getContentInEditor() async {
    try {
      final htmlTextEditor = PlatformInfo.isWeb
        ? _textEditorWeb
        : await htmlEditorApi?.getText();
      return htmlTextEditor?.isNotEmpty == true
        ? htmlTextEditor!.removeEditorStartTag()
        : '';
    } catch (e) {
      logError('ComposerController::getContentInEditor:Exception = $e');
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
      _closeComposerAction(closeOverlays: true);
      return;
    }

    if (Get.isDialogOpen == true || Get.isBottomSheetOpen == true) {
      popBack();
    }

    final emailContent = await getContentInEditor();
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
      await _showConfirmDialogWhenSendMessageFailure(
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
          replyToRecipients: listReplyToEmailAddress.toSet(),
          hasRequestReadReceipt: hasRequestReadReceipt.value,
          identity: identitySelected.value,
          attachments: uploadController.attachmentsUploaded,
          inlineAttachments: uploadController.mapInlineAttachments,
          outboxMailboxId: getOutboxMailboxIdForComposer(),
          sentMailboxId: getSentMailboxIdForComposer(),
          draftsEmailId: getDraftEmailId(),
          answerForwardEmailId: composerArguments.value!.presentationEmail?.id,
          unsubscribeEmailId: composerArguments.value!.previousEmailId,
          messageId: composerArguments.value!.messageId,
          references: composerArguments.value!.references,
          emailSendingQueue: composerArguments.value!.sendingEmail,
          displayMode: screenDisplayMode.value
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

  Future<void> _showConfirmDialogWhenSendMessageFailure({
    required BuildContext context,
    required FeatureFailure failure
  }) async {
    await showConfirmDialogAction(
      context,
      title: '',
      AppLocalizations.of(context).warningMessageWhenSendEmailFailure,
      AppLocalizations.of(context).edit,
      cancelTitle: AppLocalizations.of(context).closeAnyway,
      alignCenter: true,
      outsideDismissible: false,
      autoPerformPopBack: false,
      onConfirmAction: () {
        _sendButtonState = ButtonState.enabled;
        popBack();
        _autoFocusFieldWhenLauncher();
      },
      onCancelAction: () {
        _sendButtonState = ButtonState.enabled;
        _closeComposerAction(closeOverlays: true);
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

  Future<List<EmailAddress>> getAutoCompleteSuggestion(String queryString, {int? limit}) async {
    log('ComposerController::getAutoCompleteSuggestion():queryString = $queryString | limit = $limit | $_contactSuggestionSource');
    _getAllAutoCompleteInteractor = getBinding<GetAllAutoCompleteInteractor>();
    _getAutoCompleteInteractor = getBinding<GetAutoCompleteInteractor>();
    _getDeviceContactSuggestionsInteractor = getBinding<GetDeviceContactSuggestionsInteractor>();

    final autoCompletePattern = AutoCompletePattern(
      word: queryString,
      limit: limit,
      accountId: mailboxDashBoardController.accountId.value);

    if (_contactSuggestionSource == ContactSuggestionSource.all) {
      if (_getAllAutoCompleteInteractor != null) {
        return await _getAllAutoCompleteInteractor!
          .execute(autoCompletePattern)
          .then((value) => handleAutoCompleteResultState(
            resultState: value,
            queryString: queryString,
          )
        );
      } else if (_getDeviceContactSuggestionsInteractor != null) {
        return await _getDeviceContactSuggestionsInteractor!
          .execute(autoCompletePattern)
          .then((value) => handleAutoCompleteResultState(
            resultState: value,
            queryString: queryString,
          )
        );
      } else {
        return <EmailAddress>[];
      }
    } else {
      return await _getAutoCompleteInteractor
        ?.execute(autoCompletePattern)
        .then((value) => handleAutoCompleteResultState(
          resultState: value,
          queryString: queryString,
        )
      ) ?? <EmailAddress>[];
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
      try {
        final uploadUri = session.getUploadUri(accountId, jmapUrl: dynamicUrlInterceptors.jmapUrl);
        uploadController.justUploadAttachmentsAction(
          uploadFiles: pickedFiles,
          uploadUri: uploadUri,
        );
      } catch (e) {
        log('ComposerController::_uploadAttachmentsAction: $e');
        uploadController.consumeState(Stream.value(Left(UploadAttachmentFailure(e, pickedFiles[0]))));
      }
    } else {
      log('ComposerController::_uploadAttachmentsAction: SESSION OR ACCOUNT_ID is NULL');
    }
  }

  void deleteAttachmentUploaded(UploadTaskId uploadId) {
    uploadController.deleteFileUploaded(uploadId);
  }

  Future<bool> _validateEmailChange() async {
    final newDraftHash = await _hashDraftEmail();

    return _savedEmailDraftHash != newDraftHash;
  }

  Future<int> _hashDraftEmail() async {
    final emailContent = await getContentInEditor();

    final savedEmailDraft = SavedEmailDraft(
      subject: subjectEmail.value ?? '',
      content: emailContent,
      toRecipients: listToEmailAddress.toSet(),
      ccRecipients: listCcEmailAddress.toSet(),
      bccRecipients: listBccEmailAddress.toSet(),
      replyToRecipients: listReplyToEmailAddress.toSet(),
      identity: identitySelected.value,
      attachments: uploadController.attachmentsUploaded,
      hasReadReceipt: hasRequestReadReceipt.value,
    );

    return savedEmailDraft.hashCode;
  }

  int get emptyDraftEmailHash => SavedEmailDraft.empty().hashCode;

  Future<void> _updateSavedEmailDraftHash() async {
    _savedEmailDraftHash = await _hashDraftEmail();
  }

  Future<void> _initEmailDraftHash() async {
    final draftEmailHash = await _hashDraftEmail();

    isEmailChanged.value = draftEmailHash != emptyDraftEmailHash;

    if (composerArguments.value?.emailActionType == EmailActionType.compose ||
        composerArguments.value?.emailActionType == EmailActionType.editDraft) {
      _savedEmailDraftHash = draftEmailHash;
    }
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
        getDraftMailboxIdForComposer() == null
    ) {
      log('ComposerController::handleClickSaveAsDraftsButton: SESSION or ACCOUNT_ID or ARGUMENTS is NULL');
      _saveToDraftButtonState = ButtonState.enabled;
      return;
    }

    final emailContent = await getContentInEditor();
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
      _updateSavedEmailDraftHash();
    } else if (resultState is UpdateEmailDraftsSuccess) {
      _saveToDraftButtonState = ButtonState.enabled;
      _emailIdEditing = resultState.emailId;
      mailboxDashBoardController.consumeState(Stream.value(Right<Failure, Success>(resultState)));
      _updateSavedEmailDraftHash();
    } else if ((resultState is SaveEmailAsDraftsFailure && resultState.exception is SavingEmailToDraftsCanceledException) ||
        (resultState is UpdateEmailDraftsFailure && resultState.exception is SavingEmailToDraftsCanceledException)) {
      _saveToDraftButtonState = ButtonState.enabled;
    } else if ((resultState is SaveEmailAsDraftsFailure ||
        resultState is UpdateEmailDraftsFailure ||
        resultState is GenerateEmailFailure) &&
        context.mounted
    ) {
      await _showConfirmDialogWhenSaveMessageToDraftsFailure(
        context: context,
        failure: resultState,
        onConfirmAction: () {
          _saveToDraftButtonState = ButtonState.enabled;
          popBack();
          _autoFocusFieldWhenLauncher();
        },
        onCancelAction: () {
          _saveToDraftButtonState = ButtonState.enabled;
          _closeComposerAction(closeOverlays: true);
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
        emailCurrent: sendingEmail.email
      ))
    ));
  }

  void _getEmailContentFromSessionStorageBrowser({
    required String htmlContent,
    required List<Attachment> inlineImages,
    required AccountId accountId,
    required String downloadUrl
  }) {
    _restoreEmailInlineImagesInteractor = getBinding<RestoreEmailInlineImagesInteractor>();
    if (_restoreEmailInlineImagesInteractor == null) return;
    consumeState(_restoreEmailInlineImagesInteractor!.execute(
      htmlContent: htmlContent,
      transformConfiguration: TransformConfiguration.forRestoreEmail(),
      mapUrlDownloadCID: inlineImages.toMapCidImageDownloadUrl(
        accountId: accountId,
        downloadUrl: downloadUrl)));
  }

  void _getEmailContentFromContentShared(String content) {
    consumeState(Stream.value(Right(GetEmailContentSuccess(htmlEmailContent: content))));
  }

  void _getEmailContentFromMailtoUri(String content) {
    log('ComposerController::_getEmailContentFromMailtoUri:content: $content');
    consumeState(Stream.value(Right(GetEmailContentSuccess(htmlEmailContent: content))));
  }

  void _getEmailContentFromUnsubscribeMailtoLink(String content) {
    log('ComposerController::_getEmailContentFromUnsubscribeMailtoLink:content: $content');
    consumeState(Stream.value(Right(GetEmailContentSuccess(htmlEmailContent: content))));
  }

  void _getEmailContentOfEmailDrafts({required EmailId emailId}) {
    final session = mailboxDashBoardController.sessionCurrent;
    final accountId = mailboxDashBoardController.accountId.value;

    if (session == null || accountId == null) {
      consumeState(Stream.value(Left(GetEmailContentFailure(NotFoundSessionException()))));
      return;
    }

    try {
      consumeState(_getEmailContentInteractor.execute(
        session,
        accountId,
        emailId,
        mailboxDashBoardController.baseDownloadUrl,
        TransformConfiguration.forEditDraftsEmail(),
        additionalProperties: Properties({
          IndividualHeaderIdentifier.identityHeader.value}),
      ));
    } catch (e) {
      logError('ComposerController::_handleUploadInlineSuccess(): $e');
      consumeState(Stream.value(Left(GetEmailContentFailure(e))));
    }
  }

  void _getEmailContentOffLineSuccess(GetEmailContentFromCacheSuccess success) {
    _initAttachmentsAndInlineImages(
      attachments: success.attachments,
      inlineImages: success.inlineImages);
    emailContentsViewState.value = Right(success);

    if (composerArguments.value?.emailActionType == EmailActionType.editDraft) {
      _setUpRequestReadReceiptForDraftEmail(success.emailCurrent);
    }
  }

  void _getEmailContentSuccess(GetEmailContentSuccess success) {
    _initAttachmentsAndInlineImages(
      attachments: success.attachments,
      inlineImages: success.inlineImages);
    emailContentsViewState.value = Right(success);

    if (composerArguments.value?.emailActionType == EmailActionType.editDraft) {
      _setUpRequestReadReceiptForDraftEmail(success.emailCurrent);
      _restoreIdentityFromHeader(success.emailCurrent);
    }
  }

  void _restoreIdentityFromHeader(Email? email) {
    final identityIdFromHeader = email?.identityIdFromHeader;
    if (identityIdFromHeader == null) return;
    final selectedIdentityFromHeader = _selectIdentityFromId(identityIdFromHeader);
    if (selectedIdentityFromHeader == null) return;
    identitySelected.value = selectedIdentityFromHeader;

    _initEmailDraftHash();
  }

  Future<void> restoreCollapsibleButton(String? emailContent) async {
    try {
      if (emailContent == null) return;
      final emailDocument = parse(emailContent);

      final existedSignatureButton = emailDocument.querySelector(
        'button.tmail-signature-button');
      if (existedSignatureButton != null) return;
      
      final signature = emailDocument.querySelector('div.tmail-signature');
      if (signature == null) return;
      _restoringSignatureButton = true;
      await _applySignature(signature.innerHtml);
    } catch (e) {
      logError('ComposerController::_restoreCollapsibleButton: $e');
    }
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
        return mailboxDashBoardController.sessionCurrent?.getOwnEmailAddress() ?? '';
      }
    }
    return '';
  }

  void clearFocus(BuildContext context) {
    log('ComposerController::clearFocus:');
    if (PlatformInfo.isMobile) {
      htmlEditorApi?.unfocus();
    }
    FocusScope.of(context).unfocus();
  }

  void _closeComposerAction({dynamic result, bool closeOverlays = false}) {
    if (PlatformInfo.isWeb) {
      if (closeOverlays) {
        popBack();
      }
      mailboxDashBoardController.closeComposerOverlay(result: result);
    } else {
      popBack(result: result, closeOverlays: closeOverlays);
    }
  }

  void displayScreenTypeComposerAction(ScreenDisplayMode displayMode) async {
    if (screenDisplayMode.value == ScreenDisplayMode.minimize) {
      _isEmailBodyLoaded = false;
    }
    if (richTextWebController != null && screenDisplayMode.value != ScreenDisplayMode.minimize) {
      final textCurrent = await richTextWebController!.editorController.getText();
      richTextWebController!.editorController.setText(textCurrent);
    }
    screenDisplayMode.value = displayMode;

    await Future.delayed(
      const Duration(milliseconds: 300),
      _autoFocusFieldWhenLauncher);
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
      case PrefixEmailAddress.replyTo:
        replyToRecipientState.value = PrefixRecipientState.enabled;
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
      case PrefixEmailAddress.replyTo:
        replyToRecipientState.value = PrefixRecipientState.disabled;
        replyToAddressFocusNode = FocusNode();
        replyToEmailAddressController.clear();
        break;
      default:
        break;
    }
  }

  void _collapseAllRecipient() {
    toAddressExpandMode.value = ExpandMode.COLLAPSE;
    ccAddressExpandMode.value = ExpandMode.COLLAPSE;
    bccAddressExpandMode.value = ExpandMode.COLLAPSE;
    replyToAddressExpandMode.value = ExpandMode.COLLAPSE;
  }

  void _autoCreateEmailTag() {
    final inputToEmail = toEmailAddressController.text;
    final inputCcEmail = ccEmailAddressController.text;
    final inputBccEmail = bccEmailAddressController.text;
    final inputReplyToEmail = replyToEmailAddressController.text;
    log('ComposerController::_autoCreateEmailTag:inputToEmail = $inputToEmail | inputCcEmail = $inputCcEmail | inputBccEmail = $inputBccEmail');
    if (inputToEmail.trim().isNotEmpty) {
      _autoCreateEmailTagForRecipientField(
        prefixEmail: PrefixEmailAddress.to,
        inputText: inputToEmail,
        listEmailAddress: listToEmailAddress,
        keyEmailTagEditor: keyToEmailTagEditor,
      );
    }
    if (inputCcEmail.trim().isNotEmpty) {
      _autoCreateEmailTagForRecipientField(
        prefixEmail: PrefixEmailAddress.cc,
        inputText: inputCcEmail,
        listEmailAddress: listCcEmailAddress,
        keyEmailTagEditor: keyCcEmailTagEditor,
      );
    }
    if (inputBccEmail.trim().isNotEmpty) {
      _autoCreateEmailTagForRecipientField(
        prefixEmail: PrefixEmailAddress.bcc,
        inputText: inputBccEmail,
        listEmailAddress: listBccEmailAddress,
        keyEmailTagEditor: keyBccEmailTagEditor,
      );
    }
    if (inputReplyToEmail.isNotEmpty) {
      _autoCreateReplyToEmailTag(inputReplyToEmail);
    }
  }

  bool _isDuplicatedRecipient(String inputEmail, List<EmailAddress> listEmailAddress) {
    return listEmailAddress
      .map((emailAddress) => emailAddress.email)
      .whereNotNull()
      .contains(inputEmail);
  }

  void _autoCreateEmailTagForRecipientField({
    required PrefixEmailAddress prefixEmail,
    required String inputText,
    required List<EmailAddress> listEmailAddress,
    required GlobalKey<TagsEditorState> keyEmailTagEditor,
  }) {
    log('ComposerController::_autoCreateEmailTagForRecipientField:prefixEmail = $prefixEmail | inputText = $inputText | listEmailAddress = $listEmailAddress');
    switch(prefixEmail) {
      case PrefixEmailAddress.to:
      case PrefixEmailAddress.cc:
      case PrefixEmailAddress.bcc:
        final listString = StringConvert.extractStrings(inputText).toSet();
        if (listString.isEmpty && !_isDuplicatedRecipient(inputText, listEmailAddress)) {
          final emailAddress = EmailAddress(null, inputText);
          listEmailAddress.add(emailAddress);
          isInitialRecipient.value = true;
          isInitialRecipient.refresh();
          _updateStatusEmailSendButton();
          keyEmailTagEditor.currentState?.resetTextField();
          Future.delayed(
            const Duration(milliseconds: 300),
            keyEmailTagEditor.currentState?.closeSuggestionBox,
          );
        } else if (listString.isNotEmpty) {
          final listStringNotExist = listString
            .where((text) => !_isDuplicatedRecipient(text, listEmailAddress))
            .toList();

          if (listStringNotExist.isNotEmpty) {
            final listAddress = listStringNotExist
              .map((value) => EmailAddress(null, value))
              .toList();
            listEmailAddress.addAll(listAddress);
            isInitialRecipient.value = true;
            isInitialRecipient.refresh();
            _updateStatusEmailSendButton();
            keyEmailTagEditor.currentState?.resetTextField();
            Future.delayed(
              const Duration(milliseconds: 300),
              keyEmailTagEditor.currentState?.closeSuggestionBox,
            );
          }
        }
        break;
      default:
        break;
    }
  }

  void _autoCreateReplyToEmailTag(String inputEmail) {
    if (!_isDuplicatedRecipient(inputEmail, listReplyToEmailAddress)) {
      final emailAddress = EmailAddress(null, inputEmail);
      listReplyToEmailAddress.add(emailAddress);
      isInitialRecipient.value = true;
      isInitialRecipient.refresh();
      _updateStatusEmailSendButton();
    }
    keyReplyToEmailTagEditor.currentState?.resetTextField();
    Future.delayed(const Duration(milliseconds: 300), () {
      keyReplyToEmailTagEditor.currentState?.closeSuggestionBox();
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
    if (replyToEmailAddressController.text.isEmpty) {
      keyReplyToEmailTagEditor.currentState?.closeSuggestionBox();
    }
  }

  void showFullEmailAddress(PrefixEmailAddress prefixEmailAddress) {
    switch(prefixEmailAddress) {
      case PrefixEmailAddress.to:
        toAddressExpandMode.value = ExpandMode.EXPAND;
        toAddressFocusNode?.requestFocus();
        break;
      case PrefixEmailAddress.cc:
        ccAddressExpandMode.value = ExpandMode.EXPAND;
        ccAddressFocusNode?.requestFocus();
        break;
      case PrefixEmailAddress.bcc:
        bccAddressExpandMode.value = ExpandMode.EXPAND;
        bccAddressFocusNode?.requestFocus();
        break;
      case PrefixEmailAddress.replyTo:
        replyToAddressExpandMode.value = ExpandMode.EXPAND;
        replyToAddressFocusNode?.requestFocus();
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
        case PrefixEmailAddress.replyTo:
          replyToAddressExpandMode.value = ExpandMode.EXPAND;
          break;
        default:
          break;
      }
      _closeSuggestionBox();
      if (PlatformInfo.isMobile
          && currentContext != null
          && !responsiveUtils.isScreenWithShortestSide(currentContext!)) {
        richTextMobileTabletController?.richTextController.hideRichTextView();
      }
    } else {
      switch(prefixEmailAddress) {
        case PrefixEmailAddress.to:
          toAddressExpandMode.value = ExpandMode.COLLAPSE;
          final inputToEmail = toEmailAddressController.text;
          if (inputToEmail.trim().isNotEmpty) {
            _autoCreateEmailTagForRecipientField(
              prefixEmail: PrefixEmailAddress.to,
              inputText: inputToEmail,
              listEmailAddress: listToEmailAddress,
              keyEmailTagEditor: keyToEmailTagEditor,
            );
          }
          break;
        case PrefixEmailAddress.cc:
          ccAddressExpandMode.value = ExpandMode.COLLAPSE;
          final inputCcEmail = ccEmailAddressController.text;
          if (inputCcEmail.trim().isNotEmpty) {
            _autoCreateEmailTagForRecipientField(
              prefixEmail: PrefixEmailAddress.cc,
              inputText: inputCcEmail,
              listEmailAddress: listCcEmailAddress,
              keyEmailTagEditor: keyCcEmailTagEditor,
            );
          }
          break;
        case PrefixEmailAddress.bcc:
          bccAddressExpandMode.value = ExpandMode.COLLAPSE;
          final inputBccEmail = bccEmailAddressController.text;
          if (inputBccEmail.trim().isNotEmpty) {
            _autoCreateEmailTagForRecipientField(
              prefixEmail: PrefixEmailAddress.bcc,
              inputText: inputBccEmail,
              listEmailAddress: listBccEmailAddress,
              keyEmailTagEditor: keyBccEmailTagEditor,
            );
          }
          break;
        case PrefixEmailAddress.replyTo:
          replyToAddressExpandMode.value = ExpandMode.COLLAPSE;
          final inputReplyToEmail = replyToEmailAddressController.text;
          if (inputReplyToEmail.isNotEmpty) {
            _autoCreateReplyToEmailTag(inputReplyToEmail);
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
    if (newIdentity == null) return;

    final emailActionType = composerArguments.value?.emailActionType;
    switch (emailActionType) {
      case EmailActionType.reopenComposerBrowser:
      case EmailActionType.editDraft:
        if (_identityContentOnOpenPolicy == SignatureStatus.editedAvailable) {
          _identityContentOnOpenPolicy = SignatureStatus.editedApplied;
        } else {
          await _applyIdentityForAllFieldComposer(formerIdentity, newIdentity);
        }
        break;
      default:
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

    if (PlatformInfo.isMobile) {
      await htmlEditorApi?.onDocumentChanged();
    }
  }

  void _applyBccEmailAddressFromIdentity(Set<EmailAddress> listEmailAddress) {
    if (bccRecipientState.value == PrefixRecipientState.disabled) {
      bccRecipientState.value = PrefixRecipientState.enabled;
    }
    if (composerArguments.value?.emailActionType == EmailActionType.composeFromMailtoUri) {
      listBccEmailAddress = {...listEmailAddress, ...?composerArguments.value?.bcc}.toList();
    } else {
      listBccEmailAddress = listEmailAddress.toList();
    }
    toAddressExpandMode.value = ExpandMode.COLLAPSE;
    ccAddressExpandMode.value = ExpandMode.COLLAPSE;
    bccAddressExpandMode.value = ExpandMode.COLLAPSE;
    bccAddressExpandMode.refresh();
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
      richTextWebController?.editorController.insertSignature(signature);
    } else {
      await htmlEditorApi?.insertSignature(signature, allowCollapsed: false);
    }
  }

  Future<void> _removeSignature() async {
    log('ComposerController::_removeSignature():');
    if (PlatformInfo.isWeb) {
      richTextWebController?.editorController.removeSignature();
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

    String? baseDownloadUrl;
    try {
      baseDownloadUrl = mailboxDashBoardController.sessionCurrent?.getDownloadUrl(jmapUrl: dynamicUrlInterceptors.jmapUrl);
    } catch (e) {
      logError('ComposerController::_handleUploadInlineSuccess(): $e');
    }
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
    } else {
      log('ComposerController::_handleUploadInlineFailure(): baseDownloadUrl: $baseDownloadUrl, accountId: $accountId');
      consumeState(Stream.value(Left(DownloadImageAsBase64Failure(e))));
    }
  }

  void handleClickDeleteComposer(BuildContext context) {
    clearFocus(context);
    _closeComposerAction();
  }

  Future<void> _onEditorFocusOnMobile() async {
    if (PlatformInfo.isAndroid) {
      if (FocusManager.instance.primaryFocus?.hasFocus == true) {
        FocusManager.instance.primaryFocus?.unfocus();
      }
      await Future.delayed(
        const Duration(milliseconds: 300),
        richTextMobileTabletController?.richTextController.showDeviceKeyboard);
    }
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
        final outsideHeight = Get.height - MediaQuery.viewInsetsOf(context).bottom - ComposerStyle.keyboardToolBarHeight;
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
    final scrollTarget = realCoordinateY -
      (responsiveUtils.isLandscapeMobile(context)
        ? 0
        : headerEditorMobileHeight / 2);
    final maxScrollExtend = scrollController.position.maxScrollExtent;
    scrollController.jumpTo(min(scrollTarget, maxScrollExtend));
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

  void toggleRequestReadReceipt(BuildContext context) {
    hasRequestReadReceipt.toggle();

    appToast.showToastSuccessMessage(
      context,
      hasRequestReadReceipt.isTrue
        ? AppLocalizations.of(context).requestReadReceiptHasBeenEnabled
        : AppLocalizations.of(context).requestReadReceiptHasBeenDisabled);
  }

  Future<void> _autoFocusFieldWhenLauncher() async {
    if (await _hasInputFieldFocused()) {
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
      richTextWebController?.editorController.setFocus();
    } else if (PlatformInfo.isIOS) {
      await richTextMobileTabletController?.htmlEditorApi?.requestFocus();
    }
  }

  Future<bool> _hasInputFieldFocused() async {
    if (PlatformInfo.isWeb) {
      return toAddressFocusNode?.hasFocus == true ||
        ccAddressFocusNode?.hasFocus == true ||
        bccAddressFocusNode?.hasFocus == true ||
        replyToAddressFocusNode?.hasFocus == true ||
        subjectEmailInputFocusNode?.hasFocus == true;
    } else if (PlatformInfo.isMobile) {
      final isEditorFocused = (await richTextMobileTabletController?.isEditorFocused) ?? false;
      return toAddressFocusNode?.hasFocus == true ||
        ccAddressFocusNode?.hasFocus == true ||
        bccAddressFocusNode?.hasFocus == true ||
        replyToAddressFocusNode?.hasFocus == true ||
        subjectEmailInputFocusNode?.hasFocus == true ||
        isEditorFocused;
    }
    return false;
  }

  void handleInitHtmlEditorWeb(String initContent) async {
    if (_isEmailBodyLoaded) return;
    log('ComposerController::handleInitHtmlEditorWeb:');
    _isEmailBodyLoaded = true;
    richTextWebController?.editorController.setFullScreen();
    richTextWebController?.editorController.setOnDragDropEvent();
    onChangeTextEditorWeb(initContent);
    richTextWebController?.setEnableCodeView();
    if (identitySelected.value == null) {
      _getAllIdentities();
    } else {
      if (composerArguments.value?.emailActionType != EmailActionType.editDraft) {
        await _selectIdentity(identitySelected.value);
      }
      _autoFocusFieldWhenLauncher();
    }
  }

  void handleOnFocusHtmlEditorWeb() {
    FocusManager.instance.primaryFocus?.unfocus();
    richTextWebController?.editorController.setFocus();
    richTextWebController?.closeAllMenuPopup();
    if (menuMoreOptionController?.menuIsShowing == true) {
      menuMoreOptionController?.hideMenu();
    }
  }

  void handleOnMouseDownHtmlEditorWeb() {
    _collapseAllRecipient();
    _autoCreateEmailTag();
  }

  FocusNode? getNextFocusOfToEmailAddress() {
    if (ccRecipientState.value == PrefixRecipientState.enabled) {
      return ccAddressFocusNode;
    } else if (bccRecipientState.value == PrefixRecipientState.enabled) {
      return bccAddressFocusNode;
    } else if (replyToRecipientState.value == PrefixRecipientState.enabled) {
      return replyToAddressFocusNode;
    } else {
      return subjectEmailInputFocusNode;
    }
  }

  FocusNode? getNextFocusOfCcEmailAddress() {
    if (bccRecipientState.value == PrefixRecipientState.enabled) {
      return bccAddressFocusNode;
    } else if (replyToRecipientState.value == PrefixRecipientState.enabled) {
      return replyToAddressFocusNode;
    } else {
      return subjectEmailInputFocusNode;
    }
  }

  FocusNode? getNextFocusOfBccEmailAddress() {
    if (replyToRecipientState.value == PrefixRecipientState.enabled) {
      return replyToAddressFocusNode;
    } else {
      return subjectEmailInputFocusNode;
    }
  }

  void handleFocusNextAddressAction() {
    _autoCreateEmailTag();
  }

  bool get isNetworkConnectionAvailable => networkConnectionController.isNetworkConnectionAvailable();

  String? get textEditorWeb => _textEditorWeb;

  HtmlEditorApi? get htmlEditorApi => richTextMobileTabletController?.htmlEditorApi;

  void onChangeTextEditorWeb(String? text) {
    if (identitySelected.value != null) {
      initTextEditor(text);
    }
    _textEditorWeb = text;

    _initEmailDraftHashAfterSignatureButtonRestored(text);
  }

  void _initEmailDraftHashAfterSignatureButtonRestored(String? emailContent) {
    if (!_restoringSignatureButton) return;
    final emailDocument = parse(emailContent);
    final signatureButton = emailDocument.querySelector('button.tmail-signature-button');
    if (signatureButton == null) return;

    _restoringSignatureButton = false;
    _initEmailDraftHash();
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
      case PrefixEmailAddress.replyTo:
        listReplyToEmailAddress.remove(draggableEmailAddress.emailAddress);
        replyToAddressExpandMode.value = ExpandMode.EXPAND;
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

  Future<void> _handleGetAllIdentitiesFailure() async {
    if (composerArguments.value?.emailActionType == EmailActionType.editSendingEmail) {
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

    if (composerArguments.value == null || !_isEmailBodyLoaded) {
      log('ComposerController::handleClickCloseComposer: ARGUMENTS is NULL or EMAIL NOT LOADED');
      _closeComposerButtonState = ButtonState.enabled;
      clearFocus(context);
      _closeComposerAction();
      return;
    }

    final isChanged = await _validateEmailChange();

    if (isChanged && context.mounted) {
      clearFocus(context);
      await _showConfirmDialogSaveMessage(context);
      return;
    }

    if (context.mounted) {
      _closeComposerButtonState = ButtonState.enabled;
      clearFocus(context);
      _closeComposerAction();
    }
  }

  Future<void> _showConfirmDialogSaveMessage(BuildContext context) async {
    await showConfirmDialogAction(
      context,
      title: AppLocalizations.of(context).saveMessage.capitalizeFirstEach,
      AppLocalizations.of(context).warningMessageWhenClickCloseComposer,
      AppLocalizations.of(context).save,
      cancelTitle: AppLocalizations.of(context).discardChanges,
      alignCenter: true,
      outsideDismissible: false,
      autoPerformPopBack: false,
      titleActionButtonMaxLines: 1,
      isArrangeActionButtonsVertical: true,
      usePopScope: true,
      onConfirmAction: () => _handleSaveMessageToDraft(context),
      onCancelAction: () {
        _closeComposerButtonState = ButtonState.enabled;
        _closeComposerAction(closeOverlays: true);
      },
      onCloseButtonAction: () {
        _closeComposerButtonState = ButtonState.enabled;
        popBack();
        _autoFocusFieldWhenLauncher();
      },
      onPopInvoked: (didPop, _) {
        log('ComposerController::_showConfirmDialogSaveMessage: didPop = $didPop');
        if (!didPop) {
          _closeComposerButtonState = ButtonState.enabled;
          popBack();
          _autoFocusFieldWhenLauncher();
        }
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
    log('ComposerController::_getAlwaysReadReceiptSetting:');
    final accountId = mailboxDashBoardController.accountId.value;
    if (accountId != null) {
      consumeState(_getAlwaysReadReceiptSettingInteractor.execute(accountId));
    }
  }

  void handleOnDragEnterHtmlEditorWeb(List<dynamic>? types) {
    if (types.validateFilesTransfer) {
      mailboxDashBoardController.localFileDraggableAppState.value = DraggableAppState.active;
    }
  }

  void handleOnDragOverHtmlEditorWeb(List<dynamic>? types) {
    if (types.validateFilesTransfer) {
      mailboxDashBoardController.localFileDraggableAppState.value = DraggableAppState.active;
    }
  }

  void onLocalFileDropZoneListener({
    required BuildContext context,
    required DropDoneDetails details,
    required double maxWidth
  }) async {
    _setUpMaxWidthInlineImage(context: context, maxWidth: maxWidth);

    final listFileInfo = await onDragDone(context: context, details: details);

    if (listFileInfo.isEmpty && context.mounted) {
      appToast.showToastErrorMessage(
        context,
        AppLocalizations.of(context).can_not_upload_this_file_as_attachments
      );
      return;
    }

    uploadController.validateTotalSizeAttachmentsBeforeUpload(
      totalSizePreparedFiles: listFileInfo.totalSize,
      totalSizePreparedFilesWithDispositionAttachment: listFileInfo.listAttachmentFiles.totalSize,
      onValidationSuccess: () => _uploadAttachmentsAction(pickedFiles: listFileInfo)
    );
  }

  void _handleSaveMessageToDraft(BuildContext context) async {
    if (composerArguments.value == null ||
        mailboxDashBoardController.sessionCurrent == null ||
        mailboxDashBoardController.accountId.value == null ||
        getDraftMailboxIdForComposer() == null
    ) {
      log('ComposerController::_handleSaveMessageToDraft: SESSION or ACCOUNT_ID or ARGUMENTS is NULL');
      _closeComposerButtonState = ButtonState.enabled;
      _closeComposerAction(closeOverlays: true);
      return;
    }

    popBack();

    final emailContent = await getContentInEditor();
    final draftEmailId = getDraftEmailId();
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
    } else if ((resultState is SaveEmailAsDraftsFailure ||
        resultState is UpdateEmailDraftsFailure ||
        resultState is GenerateEmailFailure) &&
        context.mounted
    ) {
      await _showConfirmDialogWhenSaveMessageToDraftsFailure(
        context: context,
        failure: resultState
      );
    } else {
      _closeComposerButtonState = ButtonState.enabled;
    }
  }

  EmailId? getDraftEmailId() {
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
          replyToRecipients: listReplyToEmailAddress.toSet(),
          hasRequestReadReceipt: hasRequestReadReceipt.value,
          identity: identitySelected.value,
          attachments: uploadController.attachmentsUploaded,
          inlineAttachments: uploadController.mapInlineAttachments,
          sentMailboxId: getSentMailboxIdForComposer(),
          draftsMailboxId: getDraftMailboxIdForComposer(),
          draftsEmailId: draftEmailId,
          answerForwardEmailId: composerArguments.value!.presentationEmail?.id,
          unsubscribeEmailId: composerArguments.value!.previousEmailId,
          messageId: composerArguments.value!.messageId,
          references: composerArguments.value!.references,
          emailSendingQueue: composerArguments.value!.sendingEmail,
          displayMode: screenDisplayMode.value
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

  Future<void> _showConfirmDialogWhenSaveMessageToDraftsFailure({
    required BuildContext context,
    required FeatureFailure failure,
    VoidCallback? onConfirmAction,
    VoidCallback? onCancelAction,
  }) async {
    await showConfirmDialogAction(
      context,
      title: '',
      AppLocalizations.of(context).warningMessageWhenSaveEmailToDraftsFailure,
      AppLocalizations.of(context).edit,
      cancelTitle: AppLocalizations.of(context).closeAnyway,
      alignCenter: true,
      outsideDismissible: false,
      autoPerformPopBack: false,
      onConfirmAction: onConfirmAction ?? () {
        _closeComposerButtonState = ButtonState.enabled;
        popBack();
        _autoFocusFieldWhenLauncher();
      },
      onCancelAction: onCancelAction ?? () {
        _closeComposerButtonState = ButtonState.enabled;
        _closeComposerAction(closeOverlays: true);
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
    replyToRecipientState.value = isEnabled ? PrefixRecipientState.disabled : PrefixRecipientState.enabled;
  }

  void _handleGetEmailContentFailure(GetEmailContentFailure failure) {
    emailContentsViewState.value = Left(failure);
    if (composerArguments.value?.emailActionType == EmailActionType.editDraft) {
      _getAlwaysReadReceiptSetting();
    }
  }

  void _setUpRequestReadReceiptForDraftEmail(Email? email) {
    if (email?.hasRequestReadReceipt == true) {
      hasRequestReadReceipt.value = true;
      _initEmailDraftHash();
    } else {
      _getAlwaysReadReceiptSetting();
    }
  }
  
  @override
  Future<void> onBeforeReconnect() async {
    if (mailboxDashBoardController.accountId.value != null &&
        mailboxDashBoardController.sessionCurrent?.username != null
    ) {
      await _saveComposerCacheOnWebAction();
    }
  }

  void _setUpMaxWidthInlineImage({
    required BuildContext context,
    required double maxWidth
  }) {
    if (responsiveUtils.isMobile(context)) {
      maxWithEditor = maxWidth - 40;
    } else {
      maxWithEditor = maxWidth - 70;
    }
  }

  void handleOnPasteImageSuccessAction({
    required BuildContext context,
    required double maxWidth,
    required List<FileUpload> listFileUpload
  }) {
    log('ComposerController::handleOnPasteImageSuccessAction: listFileUpload = ${listFileUpload.length}');
    _setUpMaxWidthInlineImage(context: context, maxWidth: maxWidth);

    final listFileInfo = listFileUpload.toListFileInfo();

    uploadController.validateTotalSizeAttachmentsBeforeUpload(
      totalSizePreparedFiles: listFileInfo.totalSize,
      onValidationSuccess: () => _uploadAttachmentsAction(pickedFiles: listFileInfo)
    );
  }

  void handleOnPasteImageFailureAction({
    required BuildContext context,
    List<FileUpload>? listFileUpload,
    String? base64,
    required UploadError uploadError
  }) {
    logError('ComposerController::handleOnPasteImageFailureAction: $uploadError');
    appToast.showToastErrorMessage(
      context,
      AppLocalizations.of(context).thisImageCannotBePastedIntoTheEditor);
  }
}