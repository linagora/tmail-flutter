
import 'dart:async';
import 'dart:math';

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
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/error/method/error_method_response.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:rich_text_composer/rich_text_composer.dart';
import 'package:super_tag_editor/tag_editor.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/base/before_reconnect_handler.dart';
import 'package:tmail_ui_user/features/base/before_reconnect_manager.dart';
import 'package:tmail_ui_user/features/base/mixin/auto_complete_result_mixin.dart';
import 'package:tmail_ui_user/features/base/state/base_ui_state.dart';
import 'package:tmail_ui_user/features/base/state/button_state.dart';
import 'package:tmail_ui_user/features/composer/domain/exceptions/compose_email_exception.dart';
import 'package:tmail_ui_user/features/composer/domain/exceptions/set_method_exception.dart';
import 'package:tmail_ui_user/features/composer/domain/extensions/set_method_exception_description_extension.dart';
import 'package:tmail_ui_user/features/composer/domain/model/contact_suggestion_source.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/composer_repository.dart';
import 'package:tmail_ui_user/features/composer/domain/state/download_image_as_base64_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/generate_email_state.dart';
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
import 'package:tmail_ui_user/features/composer/presentation/extensions/auto_create_tag_for_recipients_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/get_draft_mailbox_id_for_composer_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/get_outbox_mailbox_id_for_composer_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/get_sent_mailbox_id_for_composer_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/handle_message_failure_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/list_identities_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/sanitize_signature_in_email_content_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/setup_email_attachments_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/setup_email_content_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/setup_email_important_flag_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/setup_email_other_components_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/setup_email_recipients_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/setup_email_request_read_receipt_flag_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/setup_email_subject_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/setup_email_template_id_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/setup_list_identities_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/setup_selected_identity_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/update_screen_display_mode_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/mixin/drag_drog_file_mixin.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/create_email_request.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/inline_image.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/prefix_recipient_state.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/saved_composing_email.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/screen_display_mode.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/composer_style.dart';
import 'package:tmail_ui_user/features/composer/presentation/view/editor_view_mixin.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/mobile/from_composer_bottom_sheet_builder.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/saving_message_dialog_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/saving_template_dialog_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/sending_message_dialog_view.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_email_content_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/save_template_email_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/update_template_email_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_email_content_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/print_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/save_template_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/transform_html_email_content_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/presentation_email_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/remove_composer_cache_by_id_on_web_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/open_and_close_composer_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/draggable_app_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_all_identities_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_identities_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/identity_extension.dart';
import 'package:tmail_ui_user/features/network_connection/presentation/network_connection_controller.dart'
  if (dart.library.html) 'package:tmail_ui_user/features/network_connection/presentation/web_network_connection_controller.dart';
import 'package:tmail_ui_user/features/server_settings/domain/usecases/get_server_setting_interactor.dart';
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
import 'package:tmail_ui_user/main/utils/app_config.dart';

class ComposerController extends BaseController
    with DragDropFileMixin, AutoCompleteResultMixin, EditorViewMixin
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
  final isMarkAsImportant = Rx<bool>(false);
  final isContentHeightExceeded = Rx<bool>(false);

  final LocalFilePickerInteractor _localFilePickerInteractor;
  final LocalImagePickerInteractor _localImagePickerInteractor;
  final GetEmailContentInteractor _getEmailContentInteractor;
  final GetAllIdentitiesInteractor _getAllIdentitiesInteractor;
  final UploadController uploadController;
  final RemoveComposerCacheByIdOnWebInteractor _removeComposerCacheByIdOnWebInteractor;
  final SaveComposerCacheOnWebInteractor _saveComposerCacheOnWebInteractor;
  final DownloadImageAsBase64Interactor _downloadImageAsBase64Interactor;
  final TransformHtmlEmailContentInteractor _transformHtmlEmailContentInteractor;
  final GetServerSettingInteractor _getServerSettingInteractor;
  final CreateNewAndSendEmailInteractor _createNewAndSendEmailInteractor;
  final CreateNewAndSaveEmailToDraftsInteractor _createNewAndSaveEmailToDraftsInteractor;
  final PrintEmailInteractor printEmailInteractor;
  final ComposerRepository _composerRepository;
  final String? composerId;
  final ComposerArguments? composerArgs;
  final SaveTemplateEmailInteractor _saveTemplateEmailInteractor;

  GetAllAutoCompleteInteractor? _getAllAutoCompleteInteractor;
  GetAutoCompleteInteractor? _getAutoCompleteInteractor;
  GetDeviceContactSuggestionsInteractor? _getDeviceContactSuggestionsInteractor;
  RestoreEmailInlineImagesInteractor? restoreEmailInlineImagesInteractor;

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
  double? maxWithEditor;
  EmailId? emailIdEditing;
  bool isAttachmentCollapsed = false;
  ButtonState _closeComposerButtonState = ButtonState.enabled;
  ButtonState _saveToDraftButtonState = ButtonState.enabled;
  ButtonState _sendButtonState = ButtonState.enabled;
  ButtonState printDraftButtonState = ButtonState.enabled;
  int? _savedEmailDraftHash;
  bool restoringSignatureButton = false;
  bool synchronizeInitDraftHash = false;
  GlobalKey? responsiveContainerKey;
  EmailActionType? currentEmailActionType;
  EmailActionType? savedActionType;
  int minInputLengthAutocomplete = AppConfig.defaultMinInputLengthAutocomplete;
  EmailId? currentTemplateEmailId;

  @visibleForTesting
  int? get savedEmailDraftHash => _savedEmailDraftHash;

  GetEmailContentInteractor get getEmailContentInteractor => _getEmailContentInteractor;

  GetServerSettingInteractor get getServerSettingInteractor => _getServerSettingInteractor;

  GetAllIdentitiesInteractor get getAllIdentitiesInteractor => _getAllIdentitiesInteractor;

  TransformHtmlEmailContentInteractor get transformHtmlEmailContentInteractor => _transformHtmlEmailContentInteractor;

  late Worker uploadInlineImageWorker;
  late Worker dashboardViewStateWorker;
  late bool _isEmailBodyLoaded;

  ComposerController(
    this._localFilePickerInteractor,
    this._localImagePickerInteractor,
    this._getEmailContentInteractor,
    this._getAllIdentitiesInteractor,
    this.uploadController,
    this._removeComposerCacheByIdOnWebInteractor,
    this._saveComposerCacheOnWebInteractor,
    this._downloadImageAsBase64Interactor,
    this._transformHtmlEmailContentInteractor,
    this._getServerSettingInteractor,
    this._createNewAndSendEmailInteractor,
    this._createNewAndSaveEmailToDraftsInteractor,
    this.printEmailInteractor,
    this._composerRepository,
    this._saveTemplateEmailInteractor,
    {
      this.composerId,
      this.composerArgs,
    }
  );

  @override
  void onInit() {
    super.onInit();
    if (PlatformInfo.isWeb) {
      responsiveContainerKey = GlobalKey();
      richTextWebController = getBinding<RichTextWebController>(tag: composerId);
      restoreEmailInlineImagesInteractor = getBinding<RestoreEmailInlineImagesInteractor>(tag: composerId);
      menuMoreOptionController = CustomPopupMenuController();
    } else {
      richTextMobileTabletController = getBinding<RichTextMobileTabletController>(tag: composerId);
    }
    createFocusNodeInput();
    scrollControllerEmailAddress.addListener(_scrollControllerEmailAddressListener);
    _listenStreamEvent();
    _beforeReconnectManager.addListener(onBeforeReconnect);
    _injectBinding();
  }

  @override
  void onReady() {
    if (PlatformInfo.isWeb) {
      _triggerBrowserEventListener();
    }
    setupComposer();
    if (PlatformInfo.isMobile) {
      Future.delayed(const Duration(milliseconds: 500), _checkContactPermission);
    }
    super.onReady();
  }

  @override
  void onClose() {
    _textEditorWeb = null;
    savedActionType = null;
    _savedEmailDraftHash = null;
    currentEmailActionType = null;
    emailIdEditing = null;
    maxWithEditor = null;
    initialAttachments.clear();
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
    if (success is LocalFilePickerSuccess) {
      _handlePickFileSuccess(success);
    } else if (success is LocalImagePickerSuccess) {
      _handlePickImageSuccess(success);
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
    } else {
      super.handleSuccessViewState(success);
    }
  }

  @override
  void handleFailureViewState(Failure failure) {
    if (failure is LocalFilePickerFailure) {
      _handlePickFileFailure(failure);
    } else if (failure is LocalImagePickerFailure) {
      _handlePickImageFailure(failure);
    } else {
      super.handleFailureViewState(failure);
    }
  }

  @override
  Future<void> onUnloadBrowserListener(html.Event event) async {
    final username = mailboxDashBoardController.sessionCurrent?.username;
    final accountId = mailboxDashBoardController.accountId.value;
    if (composerId != null && username != null && accountId != null) {
      await _removeComposerCacheByIdOnWebInteractor.execute(
        accountId,
        username,
        composerId!,
      );
    }
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
    autoCreateEmailTag();

    final createEmailRequest = await _generateCreateEmailRequestToSaveAsCache();
    if (createEmailRequest == null) return;

    await _saveComposerCacheOnWebInteractor.execute(
      createEmailRequest,
      mailboxDashBoardController.accountId.value!,
      mailboxDashBoardController.sessionCurrent!.username);
  }

  Uri? _getUploadUriFromSession(Session session, AccountId accountId) {
    try {
      return session.getUploadUri(accountId, jmapUrl: dynamicUrlInterceptors.jmapUrl);
    } catch (e) {
      logError('ComposerController::_getUploadUriFromSession:Exception = $e');
      return null;
    }
  }

  Future<CreateEmailRequest?> _generateCreateEmailRequestToSaveAsCache() async {
    final arguments = composerArguments.value;
    final session = mailboxDashBoardController.sessionCurrent;
    final accountId = mailboxDashBoardController.accountId.value;

    if (arguments == null || session == null || accountId == null) {
      log('ComposerController::_generateCreateEmailRequest: SESSION or ACCOUNT_ID or ARGUMENTS is NULL');
      return null;
    }
    
    String emailContent = await getContentInEditor();
    if (currentEmailActionType == EmailActionType.compose) {
      emailContent = await _composerRepository.removeCollapsedExpandedSignatureEffect(
        emailContent: emailContent,
      );
    }
    final uploadUri = _getUploadUriFromSession(session, accountId);

    final composerIndex = composerId != null
      ? mailboxDashBoardController.composerManager.getComposerIndex(composerId!)
      : null;
    
    return CreateEmailRequest(
      session: session,
      accountId: accountId,
      emailActionType: arguments.emailActionType,
      subject: subjectEmail.value ?? '',
      emailContent: emailContent,
      fromSender: arguments.presentationEmail?.from ?? {},
      toRecipients: listToEmailAddress.toSet(),
      ccRecipients: listCcEmailAddress.toSet(),
      bccRecipients: listBccEmailAddress.toSet(),
      replyToRecipients: listReplyToEmailAddress.toSet(),
      hasRequestReadReceipt: hasRequestReadReceipt.value,
      isMarkAsImportant: isMarkAsImportant.value,
      identity: identitySelected.value,
      attachments: uploadController.attachmentsUploaded,
      inlineAttachments: uploadController.mapInlineAttachments,
      outboxMailboxId: getOutboxMailboxIdForComposer(),
      sentMailboxId: getSentMailboxIdForComposer(),
      draftsMailboxId: getDraftMailboxIdForComposer(),
      draftsEmailId: getDraftEmailId(),
      answerForwardEmailId: arguments.presentationEmail?.id,
      unsubscribeEmailId: arguments.previousEmailId,
      messageId: arguments.messageId,
      references: arguments.references,
      emailSendingQueue: arguments.sendingEmail,
      displayMode: screenDisplayMode.value,
      uploadUri: uploadUri,
      composerIndex: composerIndex,
      composerId: composerId,
      savedDraftHash: arguments.savedDraftHash ?? _savedEmailDraftHash,
      savedActionType: savedActionType ?? currentEmailActionType,
      savedEmailDraftId: emailIdEditing,
      templateEmailId: currentTemplateEmailId,
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
      autoCreateEmailTag();
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

  Future<void> onLoadCompletedMobileEditorAction(HtmlEditorApi editorApi, WebUri? url) async {
    _isEmailBodyLoaded = true;
    await setupSelectedIdentity();
    _autoFocusFieldWhenLauncher();
  }

  void _injectBinding() {
    injectAutoCompleteBindings(
      mailboxDashBoardController.sessionCurrent,
      mailboxDashBoardController.accountId.value,
    );
  }

  Future<void> setupComposer() async {
    _isEmailBodyLoaded = false;
    final arguments = PlatformInfo.isWeb ? composerArgs : Get.arguments;

    if (arguments is! ComposerArguments) return;

    composerArguments.value = arguments;
    currentEmailActionType = arguments.emailActionType;
    savedActionType = arguments.savedActionType;
    emailIdEditing = arguments.savedEmailDraftId;
    emailContentsViewState.value = Right(GetEmailContentLoading());

    setupEmailSubject(arguments);
    setupEmailRecipients(arguments);
    setupEmailImportantFlag(arguments);
    setupEmailAttachments(arguments);
    setupEmailOtherComponents(arguments);
    setupEmailRequestReadReceiptFlag(arguments);
    setupEmailTemplateId(arguments);

    await setupListIdentities(arguments);
    await setupEmailContent(arguments);

    if (screenDisplayMode.value.isNotContentVisible() &&
        currentContext != null &&
        responsiveUtils.isWebDesktop(currentContext!)) {
      await setupSelectedIdentityWithoutApplySignature();
    }
  }

  void initAttachmentsAndInlineImages({
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

  void _getAllIdentities() {
    log('ComposerController::_getAllIdentities: Fetch again identity !');
    final accountId = mailboxDashBoardController.accountId.value;
    final session = mailboxDashBoardController.sessionCurrent;
    if (accountId != null && session != null) {
      consumeState(_getAllIdentitiesInteractor.execute(session, accountId));
    }
  }

  void _handleGetAllIdentitiesSuccess(GetAllIdentitiesSuccess success) {
    final listIdentitiesMayDeleted = success.identities?.toListMayDeleted() ?? [];
    if (listIdentitiesMayDeleted.isNotEmpty) {
      listFromIdentities.value = listIdentitiesMayDeleted;
    }
  }

  void initEmailAddress({
    required PresentationEmail presentationEmail,
    required EmailActionType actionType,
    String? listPost,
  }) {
    final senderEmailAddress = mailboxDashBoardController.sessionCurrent?.getOwnEmailAddressOrEmpty();
    final isSender = presentationEmail.from
      .asList()
      .any((element) => element.emailAddress.isNotEmpty && element.emailAddress == senderEmailAddress);

    final recipients = presentationEmail.generateRecipientsEmailAddressForComposer(
      emailActionType: actionType,
      isSender: isSender,
      userName: senderEmailAddress,
      listPost: listPost,
    );

    listToEmailAddress = List.from(recipients.to);
    listCcEmailAddress = List.from(recipients.cc);
    listBccEmailAddress = List.from(recipients.bcc);
    listReplyToEmailAddress = List.from(recipients.replyTo);

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

    updateStatusEmailSendButton();
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
    updateStatusEmailSendButton();
  }

  void updateStatusEmailSendButton() {
    if (listToEmailAddress.isNotEmpty
        || listCcEmailAddress.isNotEmpty
        || listBccEmailAddress.isNotEmpty) {
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
      autoCreateEmailTag();
    }

    if (!isEnableEmailSendButton.value) {
      showConfirmDialogAction(context,
        AppLocalizations.of(context).message_dialog_send_email_without_recipient,
        AppLocalizations.of(context).add_recipients,
        title: AppLocalizations.of(context).sending_failed,
        hasCancelButton: false,
        showAsBottomSheet: true,
        dialogMargin: MediaQuery.paddingOf(context).add(const EdgeInsets.only(bottom: 12)),
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
        hasCancelButton: false,
        dialogMargin: MediaQuery.paddingOf(context).add(const EdgeInsets.only(bottom: 12)),
      ).whenComplete(() => _sendButtonState = ButtonState.enabled);
      return;
    }

    if (subjectEmail.value == null || subjectEmail.isEmpty == true) {
      showConfirmDialogAction(context,
        AppLocalizations.of(context).message_dialog_send_email_without_a_subject,
        AppLocalizations.of(context).cancel,
        cancelTitle: AppLocalizations.of(context).send_anyway,
        onCancelAction: () => _handleSendMessages(context),
        onConfirmAction: popBack,
        autoPerformPopBack: false,
        title: AppLocalizations.of(context).empty_subject,
        showAsBottomSheet: true,
        dialogMargin: MediaQuery.paddingOf(context).add(const EdgeInsets.only(bottom: 12)),
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
        hasCancelButton: false,
        dialogMargin: MediaQuery.paddingOf(context).add(const EdgeInsets.only(bottom: 12)),
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
    final arguments = composerArguments.value;
    final session = mailboxDashBoardController.sessionCurrent;
    final accountId = mailboxDashBoardController.accountId.value;

    if (arguments == null || session == null || accountId == null) {
      log('ComposerController::_handleSendMessages: SESSION or ACCOUNT_ID or ARGUMENTS is NULL');
      _sendButtonState = ButtonState.enabled;
      _closeComposerAction(closeOverlays: true);
      return;
    }

    if (Get.isDialogOpen == true || Get.isBottomSheetOpen == true) {
      popBack();
    }

    final emailContent = await getContentInEditor();
    final uploadUri = _getUploadUriFromSession(session, accountId);
    final cancelToken = CancelToken();
    final resultState = await _showSendingMessageDialog(
      session: session,
      accountId: accountId,
      arguments: arguments,
      emailContent: emailContent,
      uploadUri: uploadUri,
      cancelToken: cancelToken
    );
    log('ComposerController::_handleSendMessages: resultState = $resultState');
    if (resultState is SendEmailSuccess || mailboxDashBoardController.validateSendingEmailFailedWhenNetworkIsLostOnMobile(resultState)) {
      _sendButtonState = ButtonState.enabled;
      _closeComposerAction(result: resultState);
    } else if (resultState is SendEmailFailure && resultState.exception is SendingEmailCanceledException) {
      _sendButtonState = ButtonState.enabled;
    } else if (resultState is SendEmailFailure || resultState is GenerateEmailFailure) {
      if (resultState.exception is BadCredentialsException) {
        _sendButtonState = ButtonState.enabled;
        handleBadCredentialsException();
      } else if (context.mounted) {
        await _showConfirmDialogWhenSendMessageFailure(
          context: context,
          failure: resultState,
        );
      } else {
        _sendButtonState = ButtonState.enabled;
      }
    } else {
      _sendButtonState = ButtonState.enabled;
    }
  }

  Future<dynamic> _showSendingMessageDialog({
    required Session session,
    required AccountId accountId,
    required ComposerArguments arguments,
    required String emailContent,
    required Uri? uploadUri,
    CancelToken? cancelToken,
  }) {
    final childWidget = PointerInterceptor(
      child: SendingMessageDialogView(
        createEmailRequest: CreateEmailRequest(
          session: session,
          accountId: accountId,
          emailActionType: arguments.emailActionType,
          subject: subjectEmail.value ?? '',
          emailContent: emailContent,
          fromSender: arguments.presentationEmail?.from ?? {},
          toRecipients: listToEmailAddress.toSet(),
          ccRecipients: listCcEmailAddress.toSet(),
          bccRecipients: listBccEmailAddress.toSet(),
          replyToRecipients: listReplyToEmailAddress.toSet(),
          hasRequestReadReceipt: hasRequestReadReceipt.value,
          isMarkAsImportant: isMarkAsImportant.value,
          identity: identitySelected.value,
          attachments: uploadController.attachmentsUploaded,
          inlineAttachments: uploadController.mapInlineAttachments,
          outboxMailboxId: getOutboxMailboxIdForComposer(),
          sentMailboxId: getSentMailboxIdForComposer(),
          draftsEmailId: getDraftEmailId(),
          answerForwardEmailId: arguments.presentationEmail?.id,
          unsubscribeEmailId: arguments.previousEmailId,
          messageId: arguments.messageId,
          references: arguments.references,
          emailSendingQueue: arguments.sendingEmail,
          displayMode: screenDisplayMode.value,
          uploadUri: uploadUri,
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
    final errorMessage = getMessageFailure(
      appLocalizations: AppLocalizations.of(context),
      exception: failure.exception,
    );
    await showConfirmDialogAction(
      context,
      title: '',
      errorMessage,
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
          .then(
            (value) => handleAutoCompleteResultState(
              resultState: value,
              queryString: queryString,
              onFailureCallback: (failure) {
                logError('ComposerController::getAutoCompleteSuggestion:onFailureCallback: $failure');
                consumeState(Stream.value(Left(failure)));
              },
            ),
            onError: (error) {
              logError('ComposerController::getAutoCompleteSuggestion:onError: $error');
              consumeState(Stream.value(Left(error)));
            },
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
        .then(
          (value) => handleAutoCompleteResultState(
            resultState: value,
            queryString: queryString,
            onFailureCallback: (failure) {
              logError('ComposerController::getAutoCompleteSuggestion:onFailureCallback: $failure');
              consumeState(Stream.value(Left(failure)));
            },
          ),
          onError: (error) {
            logError('ComposerController::getAutoCompleteSuggestion:onError: $error');
            consumeState(Stream.value(Left(error)));
          },
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
      onValidationSuccess: () => uploadAttachmentsAction(pickedFiles: success.pickedFiles)
    );
  }

  void _handlePickImageSuccess(LocalImagePickerSuccess success) {
    uploadController.validateTotalSizeInlineAttachmentsBeforeUpload(
      totalSizePreparedFiles: success.fileInfo.fileSize,
      onValidationSuccess: () => uploadAttachmentsAction(pickedFiles: [success.fileInfo.withInline()])
    );
  }

  void uploadAttachmentsAction({required List<FileInfo> pickedFiles}) {
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
        logError('ComposerController::uploadAttachmentsAction: $e');
        uploadController.consumeState(Stream.value(Left(UploadAttachmentFailure(e, pickedFiles[0]))));
      }
    } else {
      logError('ComposerController::uploadAttachmentsAction: SESSION OR ACCOUNT_ID is NULL');
    }
  }

  void deleteAttachmentUploaded(UploadTaskId uploadId) {
    uploadController.deleteFileUploaded(uploadId);
  }

  Future<bool> _validateEmailChange() async {
    final newDraftHash = await _hashComposingEmail();
    return _savedEmailDraftHash != newDraftHash;
  }

  Future<int> _hashComposingEmail() async {
    String emailContent = await getContentInEditor();

    emailContent = await _composerRepository.removeCollapsedExpandedSignatureEffect(
      emailContent: emailContent,
    );
    if (emailIdEditing != null &&
        savedActionType == EmailActionType.compose &&
        currentEmailActionType == EmailActionType.reopenComposerBrowser) {
      emailContent = await _composerRepository.removeStyleLazyLoadDisplayInlineImages(
        emailContent: emailContent,
      );
    }

    final savedEmailDraft = SavedComposingEmail(
      subject: subjectEmail.value ?? '',
      content: emailContent,
      toRecipients: listToEmailAddress.toSet(),
      ccRecipients: listCcEmailAddress.toSet(),
      bccRecipients: listBccEmailAddress.toSet(),
      replyToRecipients: listReplyToEmailAddress.toSet(),
      identity: identitySelected.value,
      attachments: uploadController.attachmentsUploaded,
      hasReadReceipt: hasRequestReadReceipt.value,
      isMarkAsImportant: isMarkAsImportant.value,
    );
    final draftAsString = savedEmailDraft.asString();
    final draftAsHasCode = draftAsString.hashCode;
    log('ComposerController::_hashDraftEmail:draftAsString = $draftAsString | draftAsHasCode = $draftAsHasCode');
    return draftAsHasCode;
  }

  Future<void> _updateSavedEmailDraftHash() async {
    _savedEmailDraftHash = await _hashComposingEmail();
  }

  Future<void> initEmailDraftHash() async {
    final currentDraftHash = await _hashComposingEmail();

    final oldSavedDraftHash = composerArguments.value?.savedDraftHash;

    if (currentEmailActionType == EmailActionType.compose ||
        currentEmailActionType == EmailActionType.editDraft) {
      _savedEmailDraftHash = currentDraftHash;
    } else if (currentEmailActionType == EmailActionType.reopenComposerBrowser) {
      _savedEmailDraftHash = oldSavedDraftHash;
    }
    log('ComposerController::initEmailDraftHash:oldSavedDraftHash = $oldSavedDraftHash | currentDraftHash = $currentDraftHash | _savedEmailDraftHash = $_savedEmailDraftHash');

    isEmailChanged.value = currentDraftHash != _savedEmailDraftHash;
  }

  void handleClickSaveAsDraftsButton(BuildContext context) async {
    if (_saveToDraftButtonState == ButtonState.disabled) {
      log('ComposerController::handleClickSaveAsDraftsButton: Saving to draft');
      return;
    }

    _saveToDraftButtonState = ButtonState.disabled;

    final arguments = composerArguments.value;
    final session = mailboxDashBoardController.sessionCurrent;
    final accountId = mailboxDashBoardController.accountId.value;

    if (arguments == null ||
        session == null ||
        accountId == null ||
        getDraftMailboxIdForComposer() == null
    ) {
      log('ComposerController::handleClickSaveAsDraftsButton: SESSION or ACCOUNT_ID or ARGUMENTS is NULL');
      _saveToDraftButtonState = ButtonState.enabled;
      return;
    }

    final emailContent = await getContentInEditor();
    final uploadUri = _getUploadUriFromSession(session, accountId);
    final cancelToken = CancelToken();
    final resultState = await _showSavingMessageToDraftsDialog(
      session: session,
      accountId: accountId,
      arguments: arguments,
      emailContent: emailContent,
      uploadUri: uploadUri,
      draftEmailId: emailIdEditing,
      cancelToken: cancelToken
    );

    if (resultState is SaveEmailAsDraftsSuccess) {
      _saveToDraftButtonState = ButtonState.enabled;
      emailIdEditing = resultState.emailId;
      mailboxDashBoardController.consumeState(Stream.value(Right<Failure, Success>(resultState)));
      _updateSavedEmailDraftHash();
    } else if (resultState is UpdateEmailDraftsSuccess) {
      _saveToDraftButtonState = ButtonState.enabled;
      emailIdEditing = resultState.emailId;
      mailboxDashBoardController.consumeState(Stream.value(Right<Failure, Success>(resultState)));
      _updateSavedEmailDraftHash();
    } else if ((resultState is SaveEmailAsDraftsFailure && resultState.exception is SavingEmailToDraftsCanceledException) ||
        (resultState is UpdateEmailDraftsFailure && resultState.exception is SavingEmailToDraftsCanceledException)) {
      _saveToDraftButtonState = ButtonState.enabled;
    } else if (resultState is SaveEmailAsDraftsFailure ||
        resultState is UpdateEmailDraftsFailure ||
        resultState is GenerateEmailFailure
    ) {
      if (resultState.exception is BadCredentialsException) {
        _saveToDraftButtonState = ButtonState.enabled;
        handleBadCredentialsException();
      } else if (context.mounted) {
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
          },
        );
      } else {
        _saveToDraftButtonState = ButtonState.enabled;
      }
    } else {
      _saveToDraftButtonState = ButtonState.enabled;
    }
  }

  Future<void> handleClickSaveAsTemplateButton(BuildContext context) async {
    if (composerArguments.value == null ||
        mailboxDashBoardController.sessionCurrent == null ||
        mailboxDashBoardController.accountId.value == null
    ) {
      log('ComposerController::handleClickSaveAsTemplateButton: SESSION or ACCOUNT_ID or ARGUMENTS is NULL');
      return;
    }

    MailboxId? templateMailboxId = mailboxDashBoardController
      .getMailboxIdByRole(PresentationMailbox.roleTemplates);
    templateMailboxId ??= mailboxDashBoardController.mapMailboxById
      .where((_, mailbox) => mailbox.name?.name.toLowerCase() ==
        PresentationMailbox.roleTemplates.value.toLowerCase())
      .keys
      .firstOrNull;

    final emailContent = await getContentInEditor();
    final cancelToken = CancelToken();
    final resultState = await _showSavingMessageToTemplateDialog(
      emailContent: emailContent,
      templateMailboxId: templateMailboxId,
      templateEmailId: currentTemplateEmailId,
      createNewMailboxRequest: templateMailboxId != null
        ? null
        : CreateNewMailboxRequest(
            MailboxName(PresentationMailbox.roleTemplates.value.toUpperCase()),
          ),
      cancelToken: cancelToken,
    );

    if (resultState is SaveTemplateEmailSuccess && context.mounted == true) {
      currentTemplateEmailId = resultState.emailId;
      appToast.showToastSuccessMessage(
        context,
        AppLocalizations.of(context).saveMessageToTemplateSuccess,
      );
    } else if (resultState is UpdateTemplateEmailSuccess && context.mounted == true) {
      currentTemplateEmailId = resultState.emailId;
      appToast.showToastSuccessMessage(
        context,
        AppLocalizations.of(context).updateMessageToTemplateSuccess,
      );
    } else if (resultState is SaveTemplateEmailFailure ||
        resultState is UpdateTemplateEmailFailure ||
        resultState is GenerateEmailFailure
    ) {
      if (resultState.exception is BadCredentialsException) {
        handleBadCredentialsException();
      } else if (context.mounted) {
        String message = '';
        final exception = resultState.exception;
        if (exception is SetMethodException) {
          final exceptionDescription = exception.getDescriptionFromErrorType(
            ErrorMethodResponse.invalidArguments,
          );
          message = exceptionDescription != null
            ? AppLocalizations.of(context).invalidArguments(exceptionDescription)
            : AppLocalizations.of(context).saveMessageToTemplateFailed;
        } else if (cancelToken.isCancelled) {
          message = AppLocalizations.of(context).saveMessageToTemplateCancelled;
        } else {
          message = AppLocalizations.of(context).saveMessageToTemplateFailed;
        }

        appToast.showToastErrorMessage(context, message);
      }
    }
  }

  void clearFocus(BuildContext context) {
    log('ComposerController::clearFocus:');
    if (PlatformInfo.isMobile) {
      htmlEditorApi?.unfocus();
    }
    FocusScope.of(context).unfocus();
  }

  void _closeComposerAction({dynamic result, bool closeOverlays = false}) {
    mailboxDashBoardController.closeComposer(
      result: result,
      closeOverlays: closeOverlays,
      composerId: composerId,
    );
  }

  void displayScreenTypeComposerAction(ScreenDisplayMode displayMode) async {
    if (screenDisplayMode.value.isNotContentVisible()) {
      _isEmailBodyLoaded = false;
    }
    if (richTextWebController != null && !screenDisplayMode.value.isNotContentVisible()) {
      final textCurrent = await richTextWebController!.editorController.getText();
      richTextWebController!.editorController.setText(textCurrent);
    }
    screenDisplayMode.value = displayMode;
    updateDisplayModeForComposerQueue(displayMode);

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
            autoCreateEmailTagForType(PrefixEmailAddress.to, inputToEmail);
          }
          break;
        case PrefixEmailAddress.cc:
          ccAddressExpandMode.value = ExpandMode.COLLAPSE;
          final inputCcEmail = ccEmailAddressController.text;
          if (inputCcEmail.trim().isNotEmpty) {
            autoCreateEmailTagForType(PrefixEmailAddress.cc, inputCcEmail);
          }
          break;
        case PrefixEmailAddress.bcc:
          bccAddressExpandMode.value = ExpandMode.COLLAPSE;
          final inputBccEmail = bccEmailAddressController.text;
          if (inputBccEmail.trim().isNotEmpty) {
            autoCreateEmailTagForType(PrefixEmailAddress.bcc, inputBccEmail);
          }
          break;
        case PrefixEmailAddress.replyTo:
          replyToAddressExpandMode.value = ExpandMode.COLLAPSE;
          final inputReplyToEmail = replyToEmailAddressController.text;
          if (inputReplyToEmail.trim().isNotEmpty) {
            autoCreateEmailTagForType(PrefixEmailAddress.replyTo, inputReplyToEmail);
          }
          break;
        default:
          break;
      }
    }
  }

  Future<void> selectIdentity(Identity? newIdentity) async {
    final formerIdentity = identitySelected.value;
    identitySelected.value = newIdentity;
    if (newIdentity == null) return;
    await _applyIdentityForAllFieldComposer(formerIdentity, newIdentity);
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
      await applySignature(newIdentity.signatureAsString.asSignatureHtml());
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
    updateStatusEmailSendButton();
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
    updateStatusEmailSendButton();
  }

  Future<void> applySignature(String signature) async {
    if (PlatformInfo.isWeb) {
      richTextWebController?.editorController.insertSignature(signature);
    } else {
      await htmlEditorApi?.insertSignature(signature, allowCollapsed: false);
    }
  }

  Future<void> _removeSignature() async {
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
    autoCreateEmailTag();
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

  void handleInitHtmlEditorWeb(String initContent) {
    if (_isEmailBodyLoaded) return;
    _isEmailBodyLoaded = true;
    richTextWebController?.editorController.setFullScreen();
    richTextWebController?.editorController.setOnDragDropEvent();
    richTextWebController?.setEnableCodeView();
    setTextEditorWeb(initContent);
  }

  Future<void> onInitialContentLoadCompleteWeb(String? initContent) async {
    await restoreCollapsibleSignatureButton(initContent);
    await setupSelectedIdentity();
    _autoFocusFieldWhenLauncher();
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
    autoCreateEmailTag();
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
    autoCreateEmailTag();
  }

  bool get isNetworkConnectionAvailable => networkConnectionController.isNetworkConnectionAvailable();

  String? get textEditorWeb => _textEditorWeb;

  void setTextEditorWeb(String value) => _textEditorWeb = value;

  HtmlEditorApi? get htmlEditorApi => richTextMobileTabletController?.htmlEditorApi;

  void onChangeTextEditorWeb(String? text) {
    _textEditorWeb = text;

    if (restoringSignatureButton ||
        (currentEmailActionType == EmailActionType.compose && !synchronizeInitDraftHash)) {
      synchronizeInitEmailDraftHash(text);
    }
  }

  void setSubjectEmail(String subject) => subjectEmail.value = subject;

  void onAttachmentDropZoneListener(Attachment attachment) {
    log('ComposerController::onAttachmentDropZoneListener: attachment = $attachment');
    uploadController.validateTotalSizeAttachmentsBeforeUpload(
      totalSizePreparedFiles: attachment.size?.value ?? 0,
      onValidationSuccess: () => uploadController.initializeUploadAttachments([attachment])
    );
  }

  Future<void> onChangeIdentity(Identity? newIdentity) async {
    await selectIdentity(newIdentity);
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

    if (_validateCloseComposerWithoutSave()) {
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

  bool _validateCloseComposerWithoutSave() {
    if (composerArguments.value == null) return true;

    if (PlatformInfo.isWeb &&
        !_isEmailBodyLoaded &&
        !screenDisplayMode.value.isNotContentVisible()) return true;

    if (PlatformInfo.isMobile && !_isEmailBodyLoaded) return true;

    return false;
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
      isArrangeActionButtonsVertical: true,
      isScrollContentEnabled: responsiveUtils.isLandscapeMobile(context),
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
    );
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
      onValidationSuccess: () => uploadAttachmentsAction(pickedFiles: listFileInfo)
    );
  }

  void _handleSaveMessageToDraft(BuildContext context) async {
    final arguments = composerArguments.value;
    final session = mailboxDashBoardController.sessionCurrent;
    final accountId = mailboxDashBoardController.accountId.value;

    if (arguments == null ||
        session == null ||
        accountId == null ||
        getDraftMailboxIdForComposer() == null
    ) {
      log('ComposerController::_handleSaveMessageToDraft: SESSION or ACCOUNT_ID or ARGUMENTS is NULL');
      _closeComposerButtonState = ButtonState.enabled;
      _closeComposerAction(closeOverlays: true);
      return;
    }

    popBack();

    final emailContent = await getContentInEditor();
    final uploadUri = _getUploadUriFromSession(session, accountId);
    final draftEmailId = getDraftEmailId();
    log('ComposerController::_handleSaveMessageToDraft: draftEmailId = $draftEmailId');
    final cancelToken = CancelToken();
    final resultState = await _showSavingMessageToDraftsDialog(
      session: session,
      accountId: accountId,
      arguments: arguments,
      emailContent: emailContent,
      uploadUri: uploadUri,
      draftEmailId: draftEmailId,
      cancelToken: cancelToken
    );

    if (resultState is SaveEmailAsDraftsSuccess || resultState is UpdateEmailDraftsSuccess) {
      _closeComposerButtonState = ButtonState.enabled;
      _closeComposerAction(result: resultState);
    } else if ((resultState is SaveEmailAsDraftsFailure && resultState.exception is SavingEmailToDraftsCanceledException) ||
        (resultState is UpdateEmailDraftsFailure && resultState.exception is SavingEmailToDraftsCanceledException)) {
      _closeComposerButtonState = ButtonState.enabled;
    } else if (resultState is SaveEmailAsDraftsFailure ||
        resultState is UpdateEmailDraftsFailure ||
        resultState is GenerateEmailFailure
    ) {
      if (resultState.exception is BadCredentialsException) {
        _closeComposerButtonState = ButtonState.enabled;
        handleBadCredentialsException();
      } else if (context.mounted) {
        await _showConfirmDialogWhenSaveMessageToDraftsFailure(
          context: context,
          failure: resultState,
        );
      } else {
        _closeComposerButtonState = ButtonState.enabled;
      }
    } else {
      _closeComposerButtonState = ButtonState.enabled;
    }
  }

  EmailId? getDraftEmailId() {
    if (emailIdEditing != null &&
        emailIdEditing != composerArguments.value!.presentationEmail?.id) {
      return emailIdEditing;
    } else if (currentEmailActionType == EmailActionType.editDraft) {
      return composerArguments.value!.presentationEmail?.id;
    } else {
      return null;
    }
  }

  Future<dynamic> _showSavingMessageToDraftsDialog({
    required Session session,
    required AccountId accountId,
    required ComposerArguments arguments,
    required String emailContent,
    required Uri? uploadUri,
    EmailId? draftEmailId,
    CancelToken? cancelToken,
  }) {
    final childWidget = PointerInterceptor(
      child: SavingMessageDialogView(
        createEmailRequest: CreateEmailRequest(
          session: session,
          accountId: accountId,
          emailActionType: arguments.emailActionType,
          subject: subjectEmail.value ?? '',
          emailContent: emailContent,
          fromSender: arguments.presentationEmail?.from ?? {},
          toRecipients: listToEmailAddress.toSet(),
          ccRecipients: listCcEmailAddress.toSet(),
          bccRecipients: listBccEmailAddress.toSet(),
          replyToRecipients: listReplyToEmailAddress.toSet(),
          hasRequestReadReceipt: hasRequestReadReceipt.value,
          isMarkAsImportant: isMarkAsImportant.value,
          identity: identitySelected.value,
          attachments: uploadController.attachmentsUploaded,
          inlineAttachments: uploadController.mapInlineAttachments,
          sentMailboxId: getSentMailboxIdForComposer(),
          draftsMailboxId: getDraftMailboxIdForComposer(),
          draftsEmailId: draftEmailId,
          answerForwardEmailId: arguments.presentationEmail?.id,
          unsubscribeEmailId: arguments.previousEmailId,
          messageId: arguments.messageId,
          references: arguments.references,
          emailSendingQueue: arguments.sendingEmail,
          displayMode: screenDisplayMode.value,
          uploadUri: uploadUri,
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

  Future<dynamic> _showSavingMessageToTemplateDialog({
    required String emailContent,
    required MailboxId? templateMailboxId,
    required EmailId? templateEmailId,
    required CreateNewMailboxRequest? createNewMailboxRequest,
    CancelToken? cancelToken,
  }) {
    final childWidget = PointerInterceptor(
      child: SavingTemplateDialogView(
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
          isMarkAsImportant: isMarkAsImportant.value,
          identity: identitySelected.value,
          attachments: uploadController.attachmentsUploaded,
          inlineAttachments: uploadController.mapInlineAttachments,
          sentMailboxId: getSentMailboxIdForComposer(),
          templateMailboxId: templateMailboxId,
          templateEmailId: templateEmailId,
          answerForwardEmailId: composerArguments.value!.presentationEmail?.id,
          unsubscribeEmailId: composerArguments.value!.previousEmailId,
          messageId: composerArguments.value!.messageId,
          references: composerArguments.value!.references,
          emailSendingQueue: composerArguments.value!.sendingEmail,
          displayMode: screenDisplayMode.value
        ),
        saveTemplateEmailInteractor: _saveTemplateEmailInteractor,
        createNewMailboxRequest: createNewMailboxRequest,
        onCancel: (cancelToken) => cancelToken?.cancel(),
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
    final errorMessage = getMessageFailure(
      appLocalizations: AppLocalizations.of(context),
      exception: failure.exception,
      isDraft: true,
    );
    await showConfirmDialogAction(
      context,
      title: '',
      errorMessage,
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
    );
  }

  void handleEnableRecipientsInputAction(bool isEnabled) {
    fromRecipientState.value = isEnabled ? PrefixRecipientState.disabled : PrefixRecipientState.enabled;
    ccRecipientState.value = isEnabled ? PrefixRecipientState.disabled : PrefixRecipientState.enabled;
    bccRecipientState.value = isEnabled ? PrefixRecipientState.disabled : PrefixRecipientState.enabled;
    replyToRecipientState.value = isEnabled ? PrefixRecipientState.disabled : PrefixRecipientState.enabled;
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
      onValidationSuccess: () => uploadAttachmentsAction(pickedFiles: listFileInfo)
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

  void onCompleteSetupComposer() {
    initEmailDraftHash();
  }
}