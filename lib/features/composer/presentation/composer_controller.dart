
import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:core/core.dart';
import 'package:core/presentation/utils/html_transformer/html_utils.dart';
import 'package:dartz/dartz.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:filesize/filesize.dart';
import 'package:fk_user_agent/fk_user_agent.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart' as web_html_editor;
import 'package:http_parser/http_parser.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_body_part.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_body_value.dart';
import 'package:jmap_dart_client/jmap/mail/email/individual_header_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:rich_text_composer/rich_text_composer.dart';
import 'package:rxdart/rxdart.dart';
import 'package:super_tag_editor/tag_editor.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/composer/domain/model/contact_suggestion_source.dart';
import 'package:tmail_ui_user/features/composer/domain/model/email_request.dart';
import 'package:tmail_ui_user/features/composer/domain/state/download_image_as_base64_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/get_autocomplete_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/get_device_contact_suggestions_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/save_email_as_drafts_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/update_email_drafts_state.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/download_image_as_base64_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_all_autocomplete_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_autocomplete_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_device_contact_suggestions_interactor.dart';
import 'package:tmail_ui_user/features/composer/presentation/controller/rich_text_mobile_tablet_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/controller/rich_text_web_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/email_action_type_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/file_upload_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/list_identities_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/draggable_email_address.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/image_source.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/inline_image.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/prefix_recipient_state.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/save_to_draft_arguments.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/save_to_draft_view_event.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/screen_display_mode.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/composer_style.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/mobile/from_composer_bottom_sheet_builder.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/insert_link_dialog_widget.dart';
import 'package:tmail_ui_user/features/email/domain/exceptions/email_exceptions.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_email_content_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/transform_html_email_content_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_email_content_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/transform_html_email_content_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/remove_composer_cache_on_web_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/save_composer_cache_on_web_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_all_identities_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_identities_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/identity_extension.dart';
import 'package:tmail_ui_user/features/network_connection/presentation/network_connection_controller.dart'
  if (dart.library.html) 'package:tmail_ui_user/features/network_connection/presentation/web_network_connection_controller.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/extensions/sending_email_extension.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/model/sending_email.dart';
import 'package:tmail_ui_user/features/sending_queue/presentation/model/sending_email_arguments.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';
import 'package:tmail_ui_user/features/upload/domain/state/attachment_upload_state.dart';
import 'package:tmail_ui_user/features/upload/domain/state/local_file_picker_state.dart';
import 'package:tmail_ui_user/features/upload/domain/usecases/local_file_picker_interactor.dart';
import 'package:tmail_ui_user/features/upload/presentation/controller/upload_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:universal_html/html.dart' as html;

class ComposerController extends BaseController {

  final mailboxDashBoardController = Get.find<MailboxDashBoardController>();
  final richTextMobileTabletController = Get.find<RichTextMobileTabletController>();
  final networkConnectionController = Get.find<NetworkConnectionController>();
  final _dynamicUrlInterceptors = Get.find<DynamicUrlInterceptors>();

  final expandModeAttachments = ExpandMode.EXPAND.obs;
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
  final isSendEmailLoading = false.obs;
  final identitySelected = Rxn<Identity>();
  final listFromIdentities = RxList<Identity>();

  final LocalFilePickerInteractor _localFilePickerInteractor;
  final DeviceInfoPlugin _deviceInfoPlugin;
  final GetEmailContentInteractor _getEmailContentInteractor;
  final GetAllIdentitiesInteractor _getAllIdentitiesInteractor;
  final UploadController uploadController;
  final RemoveComposerCacheOnWebInteractor _removeComposerCacheOnWebInteractor;
  final SaveComposerCacheOnWebInteractor _saveComposerCacheOnWebInteractor;
  final RichTextWebController richTextWebController;
  final DownloadImageAsBase64Interactor _downloadImageAsBase64Interactor;
  final TransformHtmlEmailContentInteractor _transformHtmlEmailContentInteractor;

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

  final RichTextController keyboardRichTextController = RichTextController();

  final ScrollController scrollController = ScrollController();
  final ScrollController scrollControllerEmailAddress = ScrollController();
  final ScrollController scrollControllerAttachment = ScrollController();
  final ScrollController scrollControllerIdentities = ScrollController();

  final _saveToDraftEventController = StreamController<SaveToDraftViewEvent>();
  Stream<SaveToDraftViewEvent> get _saveToDraftEventStream => _saveToDraftEventController.stream;
  late StreamSubscription _saveToDraftStreamSubscription;

  List<Attachment> initialAttachments = <Attachment>[];
  String? _textEditorWeb;
  String? _initTextEditor;
  double? maxWithEditor;
  EmailId? _emailIdEditing;
  bool isAttachmentCollapsed = false;

  late Worker uploadInlineImageWorker;
  late Worker dashboardViewStateWorker;

  ComposerController(
    this._deviceInfoPlugin,
    this._localFilePickerInteractor,
    this._getEmailContentInteractor,
    this._getAllIdentitiesInteractor,
    this.uploadController,
    this._removeComposerCacheOnWebInteractor,
    this._saveComposerCacheOnWebInteractor,
    this.richTextWebController,
    this._downloadImageAsBase64Interactor,
    this._transformHtmlEmailContentInteractor,
  );

  @override
  void onInit() {
    super.onInit();
    createFocusNodeInput();
    scrollControllerEmailAddress.addListener(_scrollControllerEmailAddressListener);
    _listenStreamEvent();
    if (PlatformInfo.isMobile) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
        await FkUserAgent.init();
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _listenBrowserTabRefresh();
      });
    }
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
    if (PlatformInfo.isMobile) {
      FkUserAgent.release();
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
    _saveToDraftStreamSubscription.cancel();
    _saveToDraftEventController.close();
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
      _pickFileSuccess(success);
    } else if (success is GetEmailContentSuccess) {
      _getEmailContentSuccess(success);
    } else if (success is GetEmailContentFromCacheSuccess) {
      _getEmailContentOffLineSuccess(success);
    } else if (success is GetAllIdentitiesSuccess) {
      _handleGetAllIdentitiesSuccess(success);
    } else if (success is DownloadImageAsBase64Success) {
      if (PlatformInfo.isWeb) {
        richTextWebController.insertImage(
          InlineImage(
            ImageSource.local,
            fileInfo: success.fileInfo,
            cid: success.cid,
            base64Uri: success.base64Uri));
      } else {
        richTextMobileTabletController.insertImage(
          InlineImage(
            ImageSource.local,
            fileInfo: success.fileInfo,
            cid: success.cid,
            base64Uri: success.base64Uri
          ),
          fromFileShare: success.fromFileShared
        );
      }
      maxWithEditor = null;
    }
  }

  @override
  void handleFailureViewState(Failure failure) {
    super.handleFailureViewState(failure);
    if (failure is LocalFilePickerFailure || failure is LocalFilePickerCancel) {
      _pickFileFailure(failure);
    } else if (failure is GetEmailContentFailure ||
        failure is TransformHtmlEmailContentFailure) {
      emailContentsViewState.value = Left(failure);
      if (isSendEmailLoading.isTrue) {
        isSendEmailLoading.value = false;
      }
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

    _saveToDraftStreamSubscription = _saveToDraftEventStream
      .debounceTime(const Duration(milliseconds: 300))
      .listen(_handleSaveToDraft);

    dashboardViewStateWorker = ever(mailboxDashBoardController.viewState, (state) {
      state.fold((failure) => null, (success) {
        if (success is SaveEmailAsDraftsSuccess) {
          _emailIdEditing = success.emailAsDrafts.id;
          log('ComposerController::_listenStreamEvent::dashboardViewStateWorker:SaveEmailAsDraftsSuccess:emailIdEditing: $_emailIdEditing');
        } else if (success is UpdateEmailDraftsSuccess) {
          _emailIdEditing = success.emailAsDrafts.id;
          log('ComposerController::_listenStreamEvent::dashboardViewStateWorker:UpdateEmailDraftsSuccess:emailIdEditing: $_emailIdEditing');
        }
      });
    });
  }

  void _listenBrowserTabRefresh() {
    html.window.onBeforeUnload.listen((event) async {
      final userProfile = mailboxDashBoardController.userProfile.value;
      _removeComposerCacheOnWebInteractor.execute();
      if (userProfile != null) {
        final draftEmail = await _generateEmail(currentContext!, userProfile);
        _saveComposerCacheOnWebInteractor.execute(draftEmail);
      }
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
    initTextEditor(content);
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

  void onTapOutsideRecipients(PrefixEmailAddress prefix) {
    switch(prefix) {
      case PrefixEmailAddress.to:
        toAddressFocusNode?.unfocus();
        break;
      case PrefixEmailAddress.cc:
        ccAddressFocusNode?.unfocus();
        break;
      case PrefixEmailAddress.bcc:
        bccAddressFocusNode?.unfocus();
        break;
      default:
        break;
    }
  }

  void onLoadCompletedMobileEditorAction(HtmlEditorApi editorApi, WebUri? url) {
    if (identitySelected.value == null) {
      _getAllIdentities();
    }
  }

  void _initEmail() {
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
          listToEmailAddress.add(arguments.emailAddress!);
          isInitialRecipient.value = true;
          toAddressExpandMode.value = ExpandMode.COLLAPSE;
          _updateStatusEmailSendButton();
          break;
        case EmailActionType.composeFromMailtoUri:
          if (arguments.subject != null) {
            setSubjectEmail(arguments.subject!);
            subjectEmailInputController.text = arguments.subject!;
          }
          if (arguments.emailAddress != null) {
            listToEmailAddress.add(arguments.emailAddress!);
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
          if (arguments.emailAddress != null) {
            listToEmailAddress.add(arguments.emailAddress!);
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

    _autoFocusFieldWhenLauncher();
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
      await _selectIdentity(listIdentitiesMayDeleted.first);
    }

    if (fromRecipientState.value == PrefixRecipientState.disabled) {
      _autoFocusFieldWhenLauncher();
    }
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
    final userProfile =  mailboxDashBoardController.userProfile.value;
    if (userProfile != null) {
      final isSender = presentationEmail.from.asList().every((element) => element.email == userProfile.email);
      if (isSender) {
        listToEmailAddress = List.from(recipients.value1.toSet());
        listCcEmailAddress = List.from(recipients.value2.toSet());
        listBccEmailAddress = List.from(recipients.value3.toSet());
      } else {
        listToEmailAddress = List.from(recipients.value1.toSet().filterEmailAddress(userProfile.email));
        listCcEmailAddress = List.from(recipients.value2.toSet().filterEmailAddress(userProfile.email));
        listBccEmailAddress = List.from(recipients.value3.toSet().filterEmailAddress(userProfile.email));
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

  String getEmailContentQuotedAsHtml({
    required BuildContext context,
    required String emailContent,
    required EmailActionType emailActionType,
    required PresentationEmail presentationEmail,
  }) {
    final headerEmailQuoted = emailActionType.getHeaderEmailQuoted(
      context: context,
      presentationEmail: presentationEmail
    );
    log('ComposerController::getEmailContentQuotedAsHtml(): headerEmailQuoted: $headerEmailQuoted');
    final headerEmailQuotedAsHtml = headerEmailQuoted != null
      ? headerEmailQuoted.addCiteTag()
      : '';
    final emailQuotedHtml = '${HtmlExtension.editorStartTags}$headerEmailQuotedAsHtml${emailContent.addBlockQuoteTag()}';

    return emailQuotedHtml;
  }

  Future<Email> _generateEmail(
    BuildContext context,
    UserProfile userProfile,
    {
      bool asDrafts = false,
      MailboxId? draftMailboxId,
      MailboxId? outboxMailboxId,
      ComposerArguments? arguments,
    }
  ) async {
    Set<EmailAddress> listFromEmailAddress = {EmailAddress(null, userProfile.email)};
    if (identitySelected.value?.email?.isNotEmpty == true) {
      listFromEmailAddress = {
        EmailAddress(
          identitySelected.value?.name,
          identitySelected.value?.email
        )
      };
    }
    Set<EmailAddress> listReplyToEmailAddress = {EmailAddress(null, userProfile.email)};
    if (identitySelected.value?.replyTo?.isNotEmpty == true) {
      listReplyToEmailAddress = identitySelected.value!.replyTo!;
    }

    final attachments = <EmailBodyPart>{};
    attachments.addAll(uploadController.generateAttachments() ?? []);

    var emailBodyText = await _getEmailBodyText(context, asDrafts: asDrafts);
    if (uploadController.mapInlineAttachments.isNotEmpty) {
      final mapContents = await _getMapContent(emailBodyText);
      emailBodyText = mapContents.value1;
      final listInlineAttachment = mapContents.value2;
      final listInlineEmailBodyPart = listInlineAttachment
          .map((attachment) => attachment.toEmailBodyPart(charset: 'base64'))
          .toSet();
      attachments.addAll(listInlineEmailBodyPart);
    }

    emailBodyText = PlatformInfo.isMobile
      ? await compute(HtmlUtils.removeCollapsedSignatureEffect, emailBodyText)
      : await HtmlUtils.removeCollapsedSignatureEffect(emailBodyText);

    final userAgent = await userAgentPlatform;
    log('ComposerController::_generateEmail(): userAgent: $userAgent');

    Map<MailboxId, bool> mailboxIds = {};
    if (asDrafts && draftMailboxId != null) {
      mailboxIds[draftMailboxId] = true;
    }
    if (outboxMailboxId != null) {
      mailboxIds[outboxMailboxId] = true;
    }

    Map<KeyWordIdentifier, bool>? mapKeywords = {};
    if (asDrafts) {
      mapKeywords[KeyWordIdentifier.emailDraft] = true;
      mapKeywords[KeyWordIdentifier.emailSeen] = true;
    }

    final inReplyTo = _generateInReplyTo(arguments);
    final references = _generateReferences(arguments);

    final generatePartId = PartId(uuid.v1());

    return Email(
      mailboxIds: mailboxIds.isNotEmpty ? mailboxIds : null,
      from: listFromEmailAddress,
      to: listToEmailAddress.toSet(),
      cc: listCcEmailAddress.toSet(),
      bcc: listBccEmailAddress.toSet(),
      replyTo: listReplyToEmailAddress,
      inReplyTo: inReplyTo,
      references: references,
      keywords: mapKeywords.isNotEmpty ? mapKeywords : null,
      subject: subjectEmail.value,
      htmlBody: {
        EmailBodyPart(
          partId: generatePartId,
          type: MediaType.parse('text/html')
        )},
      bodyValues: {
        generatePartId: EmailBodyValue(
          value: emailBodyText,
          isEncodingProblem: false,
          isTruncated: false,
          acceptLanguageHeader: {IndividualHeaderIdentifier.acceptLanguageHeader: LocalizationService.supportedLocalesToLanguageTags()},
          contentLanguageHeader: {IndividualHeaderIdentifier.contentLanguageHeader: LocalizationService.getLocaleFromLanguage().toLanguageTag()},
        )
      },
      headerUserAgent: {IndividualHeaderIdentifier.headerUserAgent : userAgent},
      attachments: attachments.isNotEmpty ? attachments : null,
      headerMdn: hasRequestReadReceipt.value ? {IndividualHeaderIdentifier.headerMdn: getEmailAddressSender()} : {},
    );
  }

  MessageIdsHeaderValue? _generateInReplyTo(ComposerArguments? arguments) {
    if (arguments?.emailActionType == EmailActionType.reply ||
        arguments?.emailActionType == EmailActionType.replyAll) {
      return arguments?.messageId;
    }
    return null;
  }

  MessageIdsHeaderValue? _generateReferences(ComposerArguments? arguments) {
    if (arguments?.emailActionType == EmailActionType.reply ||
        arguments?.emailActionType == EmailActionType.replyAll ||
        arguments?.emailActionType == EmailActionType.forward) {
      Set<String> ids = {};
      if (arguments?.messageId?.ids.isNotEmpty == true) {
        ids.addAll(arguments!.messageId!.ids);
      }
      if (arguments?.references?.ids.isNotEmpty == true) {
        ids.addAll(arguments!.references!.ids);
      }
      if (ids.isNotEmpty) {
        return MessageIdsHeaderValue(ids);
      }
    }
    return null;
  }

  Future<Tuple2<String, List<Attachment>>> _getMapContent(String emailBodyText) async {
    if (kIsWeb) {
      return await richTextWebController.refactorContentHasInlineImage(
          emailBodyText,
          uploadController.mapInlineAttachments);
    } else {
      return await richTextMobileTabletController.refactorContentHasInlineImage(
          emailBodyText,
          uploadController.mapInlineAttachments);
    }
  }

  Future<String> get userAgentPlatform async {
    String userAgent;
    try {
      if (kIsWeb) {
        final webBrowserInfo = await _deviceInfoPlugin.webBrowserInfo;
        userAgent = webBrowserInfo.userAgent ?? '';
      } else {
        userAgent = FkUserAgent.userAgent ?? '';
      }
    } on Exception {
      userAgent = '';
    }
    return 'Team-Mail/${mailboxDashBoardController.appInformation.value?.version} $userAgent';
  }

  void validateInformationBeforeSending(BuildContext context) async {
    if (isSendEmailLoading.isTrue) {
      return;
    }

    clearFocusEditor(context);

    isSendEmailLoading.value = true;

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
        onConfirmAction: () => isSendEmailLoading.value = false,
        title: AppLocalizations.of(context).sending_failed,
        icon: SvgPicture.asset(imagePaths.icSendToastError, fit: BoxFit.fill),
        hasCancelButton: false,
        showAsBottomSheet: true,
      ).whenComplete(() => isSendEmailLoading.value = false);
      return;
    }

    final allListEmailAddress = listToEmailAddress + listCcEmailAddress + listBccEmailAddress;
    final listEmailAddressInvalid = allListEmailAddress
        .where((emailAddress) => !GetUtils.isEmail(emailAddress.emailAddress))
        .toList();
    if (listEmailAddressInvalid.isNotEmpty) {
      showConfirmDialogAction(context,
        AppLocalizations.of(context).message_dialog_send_email_with_email_address_invalid,
        AppLocalizations.of(context).fix_email_addresses,
        onConfirmAction: () {
          toAddressExpandMode.value = ExpandMode.EXPAND;
          ccAddressExpandMode.value = ExpandMode.EXPAND;
          bccAddressExpandMode.value = ExpandMode.EXPAND;
          isSendEmailLoading.value = false;
        },
        showAsBottomSheet: true,
        title: AppLocalizations.of(context).sending_failed,
        icon: SvgPicture.asset(imagePaths.icSendToastError, fit: BoxFit.fill),
        hasCancelButton: false
      ).whenComplete(() => isSendEmailLoading.value = false);
      return;
    }

    if (subjectEmail.value == null || subjectEmail.isEmpty == true) {
      showConfirmDialogAction(context,
        AppLocalizations.of(context).message_dialog_send_email_without_a_subject,
        AppLocalizations.of(context).send_anyway,
        onConfirmAction: () => _handleSendMessages(context),
        onCancelAction: () => isSendEmailLoading.value = false,
        title: AppLocalizations.of(context).empty_subject,
        showAsBottomSheet: true,
        icon: SvgPicture.asset(imagePaths.icEmpty, fit: BoxFit.fill),
      ).whenComplete(() => isSendEmailLoading.value = false);
      return;
    }

    if (!uploadController.allUploadAttachmentsCompleted) {
      showConfirmDialogAction(
        context,
        AppLocalizations.of(context).messageDialogSendEmailUploadingAttachment,
        AppLocalizations.of(context).got_it,
        onConfirmAction: () => isSendEmailLoading.value = false,
        title: AppLocalizations.of(context).sending_failed,
        showAsBottomSheet: true,
        icon: SvgPicture.asset(imagePaths.icSendToastError, fit: BoxFit.fill),
        hasCancelButton: false
      ).whenComplete(() => isSendEmailLoading.value = false);
      return;
    }

    if (!uploadController.hasEnoughMaxAttachmentSize()) {
      showConfirmDialogAction(
        context,
        AppLocalizations.of(context).message_dialog_send_email_exceeds_maximum_size(
            filesize(mailboxDashBoardController.maxSizeAttachmentsPerEmail?.value ?? 0, 0)),
        AppLocalizations.of(context).got_it,
        onConfirmAction: () => isSendEmailLoading.value = false,
        title: AppLocalizations.of(context).sending_failed,
        icon: SvgPicture.asset(imagePaths.icSendToastError, fit: BoxFit.fill),
        hasCancelButton: false
      ).whenComplete(() => isSendEmailLoading.value = false);
      return;
    }

    _handleSendMessages(context);
  }

  bool get _isParamUserNull {
    if (composerArguments.value == null ||
        mailboxDashBoardController.userProfile.value == null ||
        mailboxDashBoardController.sessionCurrent == null ||
        mailboxDashBoardController.accountId.value == null
    ) {
      logError('ComposerController::isParamUserNotNull: Param is NULL');
      return true;
    }
    return false;
  }

  void _handleSendMessages(BuildContext context) async {
    if (_isParamUserNull) {
      logError('ComposerController::_handleSendMessages: Param is NULL');
      _closeComposerAction();
      return;
    }

    final sendingArgs = await _createSendingEmailArguments(context);
    _closeComposerAction(result: sendingArgs);
  }

  Future<SendingEmailArguments> _createSendingEmailArguments(BuildContext context) async {
    final session = mailboxDashBoardController.sessionCurrent!;
    final arguments = composerArguments.value!;
    final accountId = mailboxDashBoardController.accountId.value!;
    final userProfile = mailboxDashBoardController.userProfile.value!;

    final createdEmail = await _generateEmail(
      context,
      userProfile,
      outboxMailboxId: mailboxDashBoardController.outboxMailbox?.id,
      arguments: arguments
    );

    final emailRequest = arguments.emailActionType == EmailActionType.editSendingEmail
      ? arguments.sendingEmail!.toEmailRequest(newEmail: createdEmail)
      : EmailRequest(
          email: createdEmail,
          sentMailboxId: mailboxDashBoardController.mapDefaultMailboxIdByRole[PresentationMailbox.roleSent],
          identityId: identitySelected.value?.id,
          emailIdDestroyed: arguments.emailActionType == EmailActionType.editDraft
            ? arguments.presentationEmail?.id
            : null,
          emailIdAnsweredOrForwarded: arguments.presentationEmail?.id,
          emailActionType: arguments.emailActionType,
          previousEmailId: arguments.previousEmailId,
        );

    final mailboxRequest = mailboxDashBoardController.outboxMailbox?.id == null
      ? CreateNewMailboxRequest(
          Id(uuid.v1()),
          MailboxName(PresentationMailbox.outboxRole.inCaps)
        )
      : null;

    return SendingEmailArguments(
      session,
      accountId,
      emailRequest,
      mailboxRequest,
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
    clearFocusEditor(context);

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

  void _pickFileFailure(Failure failure) {
    if (failure is LocalFilePickerFailure) {
      if (currentOverlayContext != null && currentContext != null) {
        appToast.showToastErrorMessage(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).can_not_upload_this_file_as_attachments);
      }
    }
  }

  void _pickFileSuccess(LocalFilePickerSuccess success) {
    if (uploadController.hasEnoughMaxAttachmentSize(fileInfoTotalSize: uploadController.getTotalSizeFromListFileInfo(success.pickedFiles))) {
      _uploadAttachmentsAction(success.pickedFiles);
    } else {
      if (currentContext != null) {
        showConfirmDialogAction(
            currentContext!,
            AppLocalizations.of(currentContext!).message_dialog_upload_attachments_exceeds_maximum_size(
                filesize(mailboxDashBoardController.maxSizeAttachmentsPerEmail?.value ?? 0, 0)),
            AppLocalizations.of(currentContext!).got_it,
            onConfirmAction: () => {isSendEmailLoading.value = false},
            title: AppLocalizations.of(currentContext!).maximum_files_size,
            hasCancelButton: false);
      }
    }
  }

  void _uploadAttachmentsAction(List<FileInfo> pickedFiles) async {
    final session = mailboxDashBoardController.sessionCurrent;
    final accountId = mailboxDashBoardController.accountId.value;
    if (session != null && accountId != null) {
      final uploadUri = session.getUploadUri(accountId, jmapUrl: _dynamicUrlInterceptors.jmapUrl);
      uploadController.justUploadAttachmentsAction(pickedFiles, uploadUri);
    }
  }

  void deleteAttachmentUploaded(UploadTaskId uploadId) {
    uploadController.deleteFileUploaded(uploadId);
  }

  Future<bool> _isEmailChanged({
    required BuildContext context,
    required EmailActionType emailActionType,
    PresentationEmail? presentationEmail,
    Role? mailboxRole,
  }) async {
    final newEmailBody = await _getEmailBodyText(context, asDrafts: true);
    log('ComposerController::_isEmailChanged(): newEmailBody: $newEmailBody');
    final oldEmailBody = _initTextEditor ?? '';
    log('ComposerController::_isEmailChanged(): oldEmailBody: $oldEmailBody');
    final isEmailBodyChanged = !oldEmailBody.trim().isSame(newEmailBody.trim());
    log('ComposerController::_isEmailChanged(): isEmailBodyChanged: $isEmailBodyChanged');
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

    if (isEmailBodyChanged || isEmailSubjectChanged
        || isToEmailAddressChanged || isCcEmailAddressChanged
        || isBccEmailAddressChanged || isAttachmentsChanged) {
      return true;
    }

    return false;
  }

  void saveToDraftAndClose(BuildContext context) async {
    log('ComposerController::saveToDraftAndClose:');
    clearFocusEditor(context);

    final arguments = composerArguments.value;
    final userProfile = mailboxDashBoardController.userProfile.value;
    final accountId = mailboxDashBoardController.accountId.value;
    final session = mailboxDashBoardController.sessionCurrent;
    final draftMailboxId = mailboxDashBoardController.mapDefaultMailboxIdByRole[PresentationMailbox.roleDrafts];

    if (arguments == null ||
        draftMailboxId == null ||
        userProfile == null ||
        session == null ||
        accountId == null
    ) {
      logError('ComposerController::saveToDraftAndClose: Param is NULL');
      _closeComposerAction();
      return;
    }

    if (_emailIdEditing != null && _emailIdEditing != arguments.presentationEmail?.id) {
      final newEmail = await _generateEmail(
        context,
        userProfile,
        asDrafts: true,
        draftMailboxId: draftMailboxId,
        arguments: arguments,
      );

      _closeComposerAction(result: SaveToDraftArguments(
        session: session,
        accountId: accountId,
        newEmail: newEmail,
        oldEmailId: _emailIdEditing!
      ));
    } else {
      final isChanged = await _isEmailChanged(
        context: context,
        emailActionType: arguments.emailActionType,
        presentationEmail: arguments.presentationEmail,
        mailboxRole: arguments.mailboxRole
      );
      log('ComposerController::saveToDraftAndClose: isChanged: $isChanged');
      if (isChanged && context.mounted) {
        final newEmail = await _generateEmail(
          context,
          userProfile,
          asDrafts: true,
          draftMailboxId: draftMailboxId,
          arguments: arguments,
        );

        _closeComposerAction(result: SaveToDraftArguments(
          session: session,
          accountId: accountId,
          newEmail: newEmail,
          oldEmailId: arguments.emailActionType == EmailActionType.editDraft
            ? arguments.presentationEmail?.id
            : null
        ));
      } else {
        _closeComposerAction();
      }
    }
  }

  void saveToDraftAction(BuildContext context) {
    final userProfile = mailboxDashBoardController.userProfile.value;
    final accountId = mailboxDashBoardController.accountId.value;
    final session = mailboxDashBoardController.sessionCurrent;
    final draftMailboxId = mailboxDashBoardController.mapDefaultMailboxIdByRole[PresentationMailbox.roleDrafts];

    if (draftMailboxId == null || userProfile == null || session == null || accountId == null) {
      logError('ComposerController::saveToDraftAction: Param is NULL');
      return;
    }

    _saveToDraftEventController.add(
      SaveToDraftViewEvent(
        context: context,
        session: session,
        accountId: accountId,
        userProfile: userProfile,
        draftMailboxId: draftMailboxId,
        emailIdEditing: _emailIdEditing,
        arguments: mailboxDashBoardController.composerArguments,
      )
    );
  }

  void _handleSaveToDraft(SaveToDraftViewEvent event) async {
    log('ComposerController::_handleSaveToDraft:emailIdEditing: ${event.emailIdEditing}');
    final newEmail = await _generateEmail(
      event.context,
      event.userProfile,
      asDrafts: true,
      draftMailboxId: event.draftMailboxId,
      arguments: event.arguments
    );
    mailboxDashBoardController.saveEmailToDraft(
      arguments: SaveToDraftArguments(
        session: event.session,
        accountId: event.accountId,
        newEmail: newEmail,
        oldEmailId: event.emailIdEditing
      )
    );
  }

  File _covertSharedMediaFileToFile(SharedMediaFile sharedMediaFile) {
    return File(
      Platform.isIOS
          ? sharedMediaFile.type == SharedMediaType.FILE
          ? sharedMediaFile.path.toString().replaceAll('file:/', '').replaceAll('%20', ' ')
          : sharedMediaFile.path.toString().replaceAll('%20', ' ')
          : sharedMediaFile.path,
    );
  }

  FileInfo _covertFileToFileInfo(File file) {
    return FileInfo(
      file.path.split('/').last,
      file.path,
      file.existsSync() ? file.lengthSync() : 0,
    );
  }

  List<InlineImage> covertListSharedMediaFileToInlineImage(List<SharedMediaFile> value) {
    List<File> newFiles = List.empty(growable: true);
    if (value.isNotEmpty) {
      for (var element in value) {
        newFiles.add(_covertSharedMediaFileToFile(element));
      }
    }

    final List<InlineImage> listInlineImage = newFiles.map(
            (e) => InlineImage(
              ImageSource.local,
              fileInfo: _covertFileToFileInfo(e),
            )
    ).toList();
    return listInlineImage;
  }

  List<FileInfo> covertListSharedMediaFileToFileInfo(List<SharedMediaFile> value) {
    List<File> newFiles = List.empty(growable: true);
    if (value.isNotEmpty) {
      for (var element in value) {
        newFiles.add(_covertSharedMediaFileToFile(element));
      }
    }

    final List<FileInfo> listFileInfo = newFiles.map(
            (e) => _covertFileToFileInfo(e),
    ).toList();
    return listFileInfo;
  }

  void _addAttachmentFromFileShare(List<SharedMediaFile> listSharedMediaFile) {
    final listImageSharedMediaFile = listSharedMediaFile.where((element) => element.type == SharedMediaType.IMAGE);
    final listFileAttachmentSharedMediaFile = listSharedMediaFile.where((element) => element.type != SharedMediaType.IMAGE);
    if (listImageSharedMediaFile.isNotEmpty) {
      final listInlineImage = covertListSharedMediaFileToInlineImage(listSharedMediaFile);
      for (var e in listInlineImage) {
        _uploadInlineAttachmentsAction(e.fileInfo!, fromFileShared: true);
      }
    }
    if (listFileAttachmentSharedMediaFile.isNotEmpty) {
      final listFile = covertListSharedMediaFileToFileInfo(listSharedMediaFile);
      if (uploadController.hasEnoughMaxAttachmentSize(fileInfoTotalSize: uploadController.getTotalSizeFromListFileInfo(listFile))) {
        _uploadAttachmentsAction(listFile);
      } else {
        if (currentContext != null) {
          showConfirmDialogAction(
            currentContext!,
            AppLocalizations.of(currentContext!).message_dialog_upload_attachments_exceeds_maximum_size(
              filesize(mailboxDashBoardController.maxSizeAttachmentsPerEmail?.value ?? 0, 0)),
            AppLocalizations.of(currentContext!).got_it,
            title: AppLocalizations.of(currentContext!).maximum_files_size,
            hasCancelButton: false,
          );
        }
      }
    }
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
        return mailboxDashBoardController.userProfile.value?.email ?? '';
      }
    }
    return '';
  }

  void clearFocusEditor(BuildContext context) {
    if (PlatformInfo.isMobile) {
      htmlEditorApi?.unfocus();
      KeyboardUtils.hideSystemKeyboardMobile();
    }
    FocusScope.of(context).unfocus();
  }

  void _closeComposerAction({dynamic result}) {
    uploadController.clearInlineFileUploaded();

    if (PlatformInfo.isWeb) {
      _closeComposerWeb(result: result);
    } else {
      isSendEmailLoading.value = false;
      popBack(result: result);
    }
  }

  void _closeComposerWeb({dynamic result}) {
    isSendEmailLoading.value = false;
    mailboxDashBoardController.closeComposerOverlay(result: result);
  }

  void displayScreenTypeComposerAction(ScreenDisplayMode displayMode) {
    FocusManager.instance.primaryFocus?.unfocus();
    createFocusNodeInput();
    _updateTextForEditor();
    screenDisplayMode.value = displayMode;
    _autoFocusFieldWhenLauncher();
  }

  void _updateTextForEditor() async {
    final textCurrent = await richTextWebController.editorController.getText();
    richTextWebController.editorController.setText(textCurrent);
  }

  void deleteComposer() {
    FocusManager.instance.primaryFocus?.unfocus();
    mailboxDashBoardController.closeComposerOverlay();
  }

  void toggleDisplayAttachments() {
    final newExpandMode = expandModeAttachments.value == ExpandMode.COLLAPSE
        ? ExpandMode.EXPAND : ExpandMode.COLLAPSE;
    expandModeAttachments.value = newExpandMode;
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
      await htmlEditorApi?.insertSignature(signature);
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
    clearFocusEditor(context);

    if (responsiveUtils.isMobile(context)) {
      maxWithEditor = maxWith - 40;
    } else {
      maxWithEditor = maxWith - 120;
    }
    final inlineImage = await _selectFromFile();
    if (inlineImage != null) {
      if (PlatformInfo.isWeb) {
        _insertImageOnWeb(inlineImage);
      } else {
        _insertImageOnMobileAndTablet(inlineImage);
      }
    } else {
      if (context.mounted) {
        appToast.showToastErrorMessage(context, AppLocalizations.of(context).cannotSelectThisImage);
      }
    }
  }

  Future<InlineImage?> _selectFromFile() async {
    final filePickerResult = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: PlatformInfo.isWeb
    );
    if (filePickerResult?.files.isNotEmpty == true) {
      PlatformFile platformFile = filePickerResult!.files.first;
      final fileSelected = FileInfo(
        platformFile.name,
        PlatformInfo.isWeb ? '' : platformFile.path ?? '',
        platformFile.size,
        bytes: PlatformInfo.isWeb ? platformFile.bytes : null,
      );
      return InlineImage(ImageSource.local, fileInfo: fileSelected);
    }

    return null;
  }

  void _insertImageOnWeb(InlineImage inlineImage) {
    if (inlineImage.source == ImageSource.local) {
      _uploadInlineAttachmentsAction(inlineImage.fileInfo!);
    } else {
      richTextWebController.insertImage(inlineImage);
    }
  }

  void _insertImageOnMobileAndTablet(InlineImage inlineImage) {
    if (inlineImage.source == ImageSource.local) {
      _uploadInlineAttachmentsAction(inlineImage.fileInfo!);
    } else {
      richTextMobileTabletController.insertImage(inlineImage);
    }
  }

  void _uploadInlineAttachmentsAction(FileInfo pickedFile, {bool fromFileShared = false}) async {
    if (uploadController.hasEnoughMaxAttachmentSize(fileInfoTotalSize: uploadController.getTotalSizeFromListFileInfo([pickedFile]))) {
      final session = mailboxDashBoardController.sessionCurrent;
      final accountId = mailboxDashBoardController.accountId.value;
      if (session != null && accountId != null) {
        final uploadUri = session.getUploadUri(accountId, jmapUrl: _dynamicUrlInterceptors.jmapUrl);
        uploadController.uploadFileAction(
          pickedFile,
          uploadUri,
          isInline: true,
          fromFileShared: fromFileShared
        );
      }
    } else {
      if (currentContext != null) {
        showConfirmDialogAction(
            currentContext!,
            AppLocalizations.of(currentContext!).message_dialog_upload_attachments_exceeds_maximum_size(
                filesize(mailboxDashBoardController.maxSizeAttachmentsPerEmail?.value ?? 0, 0)),
            AppLocalizations.of(currentContext!).got_it,
            onConfirmAction: () => {isSendEmailLoading.value = false},
            title: AppLocalizations.of(currentContext!).maximum_files_size,
            hasCancelButton: false);
      }
    }
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
        fromFileShared: uploadState.fromFileShared,
      ));
    }
  }

  void closeComposer(BuildContext context) {
    FocusScope.of(context).unfocus();

    if (PlatformInfo.isWeb) {
      mailboxDashBoardController.closeComposerOverlay();
    } else {
      popBack();
    }
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
    FocusManager.instance.primaryFocus?.unfocus();

    if (listToEmailAddress.isEmpty) {
      toAddressFocusNode?.requestFocus();
    } else if (subjectEmailInputController.text.isEmpty) {
      subjectEmailInputFocusNode?.requestFocus();
    } else if (PlatformInfo.isWeb) {
      Future.delayed(
        const Duration(milliseconds: 500),
        richTextWebController.editorController.setFocus
      );
    }
  }

  void handleInitHtmlEditorWeb(String initContent) {
    richTextWebController.editorController.setFullScreen();
    onChangeTextEditorWeb(initContent);
    richTextWebController.setEnableCodeView();
    if (identitySelected.value == null) {
      _getAllIdentities();
    }
  }

  void handleOnFocusHtmlEditorWeb() {
    FocusManager.instance.primaryFocus?.unfocus();
    Future.delayed(const Duration(milliseconds: 500), () {
      richTextWebController.editorController.setFocus();
    });
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

  void handleImageUploadSuccess (
    BuildContext context,
    web_html_editor.FileUpload fileUpload
  ) async {
    log('ComposerController::handleImageUploadSuccess:NAME: ${fileUpload.name} | TYPE: ${fileUpload.type} | SIZE: ${fileUpload.size}');
    if (fileUpload.base64 == null) {
      appToast.showToastErrorMessage(
        context,
        AppLocalizations.of(context).can_not_upload_this_file_as_attachments
      );
      return;
    }

    if (fileUpload.type?.startsWith(MediaTypeExtension.imageType) == true) {
      final fileInfo = await fileUpload.toFileInfo();
      if (fileInfo != null) {
        _uploadInlineAttachmentsAction(fileInfo);
      } else if (context.mounted) {
        appToast.showToastErrorMessage(
          context,
          AppLocalizations.of(context).can_not_upload_this_file_as_attachments
        );
      }
    } else {
      final fileInfo = await fileUpload.toFileInfo();
      if (fileInfo != null) {
        _addAttachmentFromDragAndDrop(fileInfo: fileInfo);
      } else if (context.mounted) {
        appToast.showToastErrorMessage(
          context,
          AppLocalizations.of(context).can_not_upload_this_file_as_attachments
        );
      }
    }
  }

  void handleImageUploadFailure({
    required BuildContext context,
    required web_html_editor.UploadError uploadError,
    web_html_editor.FileUpload? fileUpload,
    String? base64Str,
  }) {
    logError('ComposerController::handleImageUploadFailure:fileUpload: $fileUpload | uploadError: $uploadError');
    appToast.showToastErrorMessage(
      context,
      '${AppLocalizations.of(context).can_not_upload_this_file_as_attachments}. (${uploadError.name})'
    );
  }

  void _addAttachmentFromDragAndDrop({required FileInfo fileInfo}) {
    if (uploadController.hasEnoughMaxAttachmentSize(fileInfoTotalSize: uploadController.getTotalSizeFromListFileInfo([fileInfo]))) {
      _uploadAttachmentsAction([fileInfo]);
    } else {
      if (currentContext != null) {
        showConfirmDialogAction(
          currentContext!,
          AppLocalizations.of(currentContext!).message_dialog_upload_attachments_exceeds_maximum_size(
            filesize(mailboxDashBoardController.maxSizeAttachmentsPerEmail?.value ?? 0, 0)),
          AppLocalizations.of(currentContext!).got_it,
          title: AppLocalizations.of(currentContext!).maximum_files_size,
          hasCancelButton: false,
        );
      }
    }
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

  UserProfile? get userProfile => mailboxDashBoardController.userProfile.value;

  String? get textEditorWeb => _textEditorWeb;

  HtmlEditorApi? get htmlEditorApi => richTextMobileTabletController.htmlEditorApi;

  void onChangeTextEditorWeb(String? text) {
    initTextEditor(text);
    _textEditorWeb = text;
  }

  void initTextEditor(String? text) {
    _initTextEditor ??= text;
  }

  void setSubjectEmail(String subject) => subjectEmail.value = subject;

  Future<String> _getEmailBodyText(BuildContext context, {bool asDrafts = false}) async {
    var contentHtml = '';

    if (PlatformInfo.isWeb) {
      if (responsiveUtils.isDesktop(context) &&
          screenDisplayMode.value == ScreenDisplayMode.minimize) {
        contentHtml = _textEditorWeb ?? '';
      } else {
        if (asDrafts) {
          contentHtml = await richTextWebController.editorController.getText();
        } else {
          contentHtml = await richTextWebController.editorController.getTextWithSignatureContent();
        }
      }
    } else {
      if (asDrafts) {
        contentHtml = (await htmlEditorApi?.getText()) ?? '';
      } else {
        contentHtml = (await htmlEditorApi?.getTextWithSignatureContent()) ?? '';
      }
    }

    final newContentHtml = contentHtml.removeEditorStartTag();
    return newContentHtml;
  }

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

  void addAttachmentFromDropZone(Attachment attachment) {
    log('ComposerController::addAttachmentFromDropZone: $attachment');
    if (uploadController.hasEnoughMaxAttachmentSize(fileInfoTotalSize: attachment.size?.value)) {
      uploadController.initializeUploadAttachments([attachment]);
    } else {
      if (currentContext != null) {
        showConfirmDialogAction(
          currentContext!,
          AppLocalizations.of(currentContext!).message_dialog_upload_attachments_exceeds_maximum_size(
              filesize(mailboxDashBoardController.maxSizeAttachmentsPerEmail?.value ?? 0, 0)),
          AppLocalizations.of(currentContext!).got_it,
          title: AppLocalizations.of(currentContext!).maximum_files_size,
          hasCancelButton: false,
        );
      }
    }
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

  void onEditLinkAction(
    BuildContext context,
    String? text,
    String? url,
    bool? isOpenNewTab,
    String linkTagId
  ) async {
    Get.dialog(
      PointerInterceptor(
        child: InsertLinkDialogWidget(
          responsiveUtils: responsiveUtils,
          editorController: richTextWebController.editorController,
          linkTagId: linkTagId,
          displayText: text ?? url ?? '',
          link: url ?? '',
          openNewTab: isOpenNewTab ?? true,
        )
      )
    );
  }
}