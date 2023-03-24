
import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:filesize/filesize.dart';
import 'package:fk_user_agent/fk_user_agent.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
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
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:rich_text_composer/rich_text_composer.dart';
import 'package:super_tag_editor/tag_editor.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/composer/domain/model/contact_suggestion_source.dart';
import 'package:tmail_ui_user/features/composer/domain/model/email_request.dart';
import 'package:tmail_ui_user/features/composer/domain/state/download_image_as_base64_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/get_autocomplete_state.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/download_image_as_base64_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_autocomplete_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_autocomplete_with_device_contact_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/save_email_as_drafts_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/update_email_drafts_interactor.dart';
import 'package:tmail_ui_user/features/composer/presentation/controller/rich_text_web_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/controller/rich_text_mobile_tablet_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/email_action_type_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/image_source.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/inline_image.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/screen_display_mode.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_email_content_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_email_content_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/remove_composer_cache_on_web_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/save_composer_cache_on_web_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_all_identities_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_identities_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/identity_extension.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';
import 'package:tmail_ui_user/features/upload/domain/state/attachment_upload_state.dart';
import 'package:tmail_ui_user/features/upload/domain/state/local_file_picker_state.dart';
import 'package:tmail_ui_user/features/upload/domain/usecases/local_file_picker_interactor.dart';
import 'package:tmail_ui_user/features/upload/presentation/controller/upload_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:uuid/uuid.dart';
import 'package:universal_html/html.dart' as html;

class ComposerController extends BaseController {

  final mailboxDashBoardController = Get.find<MailboxDashBoardController>();
  final richTextMobileTabletController = Get.find<RichTextMobileTabletController>();
  final _appToast = Get.find<AppToast>();
  final _imagePaths = Get.find<ImagePaths>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();
  final _uuid = Get.find<Uuid>();

  final expandModeAttachments = ExpandMode.COLLAPSE.obs;
  final composerArguments = Rxn<ComposerArguments>();
  final isEnableEmailSendButton = false.obs;
  final isInitialRecipient = false.obs;
  final listEmailAddressType = <PrefixEmailAddress>[].obs;
  final subjectEmail = Rxn<String>();
  final screenDisplayMode = ScreenDisplayMode.normal.obs;
  final toAddressExpandMode = ExpandMode.EXPAND.obs;
  final ccAddressExpandMode = ExpandMode.EXPAND.obs;
  final bccAddressExpandMode = ExpandMode.EXPAND.obs;
  final identitySelected = Rxn<Identity>();
  final listIdentities = <Identity>[].obs;
  final emailContentsViewState = Rx<Either<Failure, Success>>(Right(UIState.idle));
  final hasRequestReadReceipt = false.obs;

  final LocalFilePickerInteractor _localFilePickerInteractor;
  final DeviceInfoPlugin _deviceInfoPlugin;
  final SaveEmailAsDraftsInteractor _saveEmailAsDraftsInteractor;
  final GetEmailContentInteractor _getEmailContentInteractor;
  final UpdateEmailDraftsInteractor _updateEmailDraftsInteractor;
  final GetAllIdentitiesInteractor _getAllIdentitiesInteractor;
  final UploadController uploadController;
  final RemoveComposerCacheOnWebInteractor _removeComposerCacheOnWebInteractor;
  final SaveComposerCacheOnWebInteractor _saveComposerCacheOnWebInteractor;
  final RichTextWebController richTextWebController;
  final DownloadImageAsBase64Interactor _downloadImageAsBase64Interactor;

  GetAutoCompleteWithDeviceContactInteractor? _getAutoCompleteWithDeviceContactInteractor;
  GetAutoCompleteInteractor? _getAutoCompleteInteractor;

  List<EmailAddress> listToEmailAddress = <EmailAddress>[];
  List<EmailAddress> listCcEmailAddress = <EmailAddress>[];
  List<EmailAddress> listBccEmailAddress = <EmailAddress>[];
  ContactSuggestionSource _contactSuggestionSource = ContactSuggestionSource.tMailContact;

  final subjectEmailInputController = TextEditingController();
  final toEmailAddressController = TextEditingController();
  final ccEmailAddressController = TextEditingController();
  final bccEmailAddressController = TextEditingController();

  final GlobalKey<TagsEditorState> keyToEmailTagEditor = GlobalKey<TagsEditorState>();
  final GlobalKey<TagsEditorState> keyCcEmailTagEditor = GlobalKey<TagsEditorState>();
  final GlobalKey<TagsEditorState> keyBccEmailTagEditor = GlobalKey<TagsEditorState>();
  final GlobalKey headerEditorMobileWidgetKey = GlobalKey();
  final double defaultPaddingCoordinateYCursorEditor = 8;
  final double maxKeyBoardHeight = 500;
  final double richTextBarHeight = 200;

  FocusNode? subjectEmailInputFocusNode;
  FocusNode? toAddressFocusNode;
  FocusNode? ccAddressFocusNode;
  FocusNode? bccAddressFocusNode;

  final RichTextController keyboardRichTextController = RichTextController();

  final ScrollController scrollController = ScrollController();

  List<Attachment> initialAttachments = <Attachment>[];
  String? _textEditorWeb;
  String? _initTextEditor;
  List<EmailContent>? _emailContents;
  double? maxWithEditor;
  late Worker uploadInlineImageWorker;

  void onChangeTextEditorWeb(String? text) {
    initTextEditor(text);
    _textEditorWeb = text;
  }

  void initTextEditor(String? text) {
   if (_initTextEditor == null) {
     _initTextEditor = text;
     log('ComposerController::initTextEditor():$_initTextEditor');
   }
  }

  String? get textEditorWeb => _textEditorWeb;

  HtmlEditorApi? get htmlEditorApi => richTextMobileTabletController.htmlEditorApi;

  void setSubjectEmail(String subject) => subjectEmail.value = subject;

  Future<String> _getEmailBodyText(BuildContext context, {
    bool changedEmail = false
  }) async {
    if (BuildUtils.isWeb) {
      var contentHtml = '';
      if (_responsiveUtils.isWebDesktop(context) &&
          screenDisplayMode.value == ScreenDisplayMode.minimize) {
        contentHtml = textEditorWeb ?? '';
      } else {
        contentHtml = await richTextWebController.editorController.getText();
      }
      log('ComposerController::_getEmailBodyText():WEB: contentHtml: $contentHtml');
      final newContentHtml = contentHtml.removeEditorStartTag();
      log('ComposerController::_getEmailBodyText():WEB: newContentHtml: $newContentHtml');
      return newContentHtml;
    } else {
      String contentHtml = await htmlEditorApi?.getText() ?? '';
      log('ComposerController::_getEmailBodyText():MOBILE: $contentHtml');
      final newContentHtml = contentHtml.removeEditorStartTag();
      if (changedEmail) {
        return newContentHtml;
      } else if (_isMobileApp && identitySelected.value?.signatureAsString.isNotEmpty == true) {
        await htmlEditorApi?.removeSignature();
        await htmlEditorApi?.insertSignature(identitySelected.value!.signatureAsString.asSignatureHtml());

        contentHtml = await htmlEditorApi?.getText() ?? '';
        final contentHtmlWithSignature = contentHtml.removeEditorStartTag();
        log('ComposerController::_getEmailBodyText():MOBILE:SIGNATURE: $contentHtmlWithSignature');

        return contentHtmlWithSignature;
      } else {
        return newContentHtml;
      }
    }
  }

  ComposerController(
    this._deviceInfoPlugin,
    this._localFilePickerInteractor,
    this._saveEmailAsDraftsInteractor,
    this._getEmailContentInteractor,
    this._updateEmailDraftsInteractor,
    this._getAllIdentitiesInteractor,
    this.uploadController,
    this._removeComposerCacheOnWebInteractor,
    this._saveComposerCacheOnWebInteractor,
    this.richTextWebController,
    this._downloadImageAsBase64Interactor,
  );

  @override
  void onInit() {
    super.onInit();
    createFocusNodeInput();
    _listenWorker();
    if (!BuildUtils.isWeb) {
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
  void onReady() async {
    _initEmail();
    _getAllIdentities();
    if (!BuildUtils.isWeb) {
      Future.delayed(const Duration(milliseconds: 500), () =>
          _checkContactPermission());
    }
    super.onReady();
  }

  @override
  void onClose() {
    _initTextEditor = null;
    if (!BuildUtils.isWeb) {
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
    subjectEmailInputController.dispose();
    toEmailAddressController.dispose();
    ccEmailAddressController.dispose();
    bccEmailAddressController.dispose();
    uploadInlineImageWorker.dispose();
    keyboardRichTextController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  void onData(Either<Failure, Success> newState) {
    super.onData(newState);
    newState.map((success) async {
      if (success is GetEmailContentLoading) {
        emailContentsViewState.value = Right(success);
      }
    });
  }

  @override
  void onDone() {
    viewState.value.fold(
      (failure) {
        if (failure is LocalFilePickerFailure || failure is LocalFilePickerCancel) {
          _pickFileFailure(failure);
        } else if (failure is GetEmailContentFailure) {
          emailContentsViewState.value = Left(failure);
        }
      },
      (success) {
        if (success is LocalFilePickerSuccess) {
          _pickFileSuccess(success);
        } else if (success is GetEmailContentSuccess) {
          _getEmailContentSuccess(success);
        } else if (success is GetAllIdentitiesSuccess) {
          _handleGetAllIdentitiesSuccess(success);
        } else if (success is DownloadImageAsBase64Success) {
          if(kIsWeb) {
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
                    base64Uri: success.base64Uri));
          }
          maxWithEditor = null;
        }
      });
  }

  void _listenWorker() {
    uploadInlineImageWorker = ever(uploadController.uploadInlineViewState, (state) {
      log('ComposerController::_listenWorker(): $state');
      state.fold((failure) => null, (success) {
        if (success is SuccessAttachmentUploadState) {
          _handleUploadInlineSuccess(success);
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

  void createFocusNodeInput() {
    toAddressFocusNode = FocusNode();
    subjectEmailInputFocusNode = FocusNode();
    ccAddressFocusNode = FocusNode();
    bccAddressFocusNode = FocusNode();

    subjectEmailInputFocusNode?.addListener(() {
      log('ComposerController::createFocusNodeInput():subjectEmailInputFocusNode: ${subjectEmailInputFocusNode?.hasFocus}');
      if (subjectEmailInputFocusNode?.hasFocus == true) {
        if (!BuildUtils.isWeb) {
          htmlEditorApi?.unfocus();
        }
        _collapseAllRecipient();
        _autoCreateEmailTag();
      }
    });
  }

  void initRichTextForMobile(BuildContext context, HtmlEditorApi editorApi, String? content) {
    initTextEditor(content);
    richTextMobileTabletController.htmlEditorApi = editorApi;
    keyboardRichTextController.onCreateHTMLEditor(
      editorApi,
      onEnterKeyDown: _onEnterKeyDown,
      context: context,
      onFocus: _onEditorFocusOnMobile,
      onChangeCursor: _onChangeCursorOnMobile,
    );
  }

  void _initEmail() {
    final arguments = kIsWeb ? mailboxDashBoardController.routerArguments : Get.arguments;
    if (arguments is ComposerArguments) {
      composerArguments.value = arguments;
      injectAutoCompleteBindings(
          mailboxDashBoardController.sessionCurrent,
          mailboxDashBoardController.accountId.value);

      if (arguments.emailActionType == EmailActionType.edit) {
        _getEmailContentAction(arguments);
      }

      _initEmailAddress(arguments);
      _initSubjectEmail(arguments);
      _initAttachments(arguments);
    }

    _autoFocusFieldWhenLauncher();
  }

  void _initSubjectEmail(ComposerArguments arguments) {
    if (currentContext != null) {
      final subjectEmail = arguments.presentationEmail?.getEmailTitle().trim() ?? '';
      final newSubject = arguments.emailActionType.getSubjectComposer(currentContext!, subjectEmail);
      setSubjectEmail(newSubject);
      subjectEmailInputController.text = newSubject;
    }
  }

  void _initAttachments(ComposerArguments arguments) {
    if (arguments.attachments?.isNotEmpty == true) {
      initialAttachments = arguments.attachments!;
      uploadController.initializeUploadAttachments(
          arguments.attachments!.listAttachmentsDisplayedOutSide);
    }
    if (BuildUtils.isWeb) {
      expandModeAttachments.value = ExpandMode.EXPAND;
    }
  }

  void _getAllIdentities() {
    final accountId = mailboxDashBoardController.accountId.value;
    if (accountId != null) {
      consumeState(_getAllIdentitiesInteractor.execute(accountId));
    }
  }

  void _handleGetAllIdentitiesSuccess(GetAllIdentitiesSuccess success) async {
    if (success.identities?.isNotEmpty == true) {
      listIdentities.value = success.identities!
        .where((identity) => identity.mayDelete == true)
        .toList();

      if (listIdentities.isNotEmpty) {
        _initTextEditor = null;
        await selectIdentity(listIdentities.first);
      }
    }

    _autoFocusFieldWhenLauncher();
  }

  String? getContentEmail(BuildContext context) {
    if (composerArguments.value != null) {
      switch(composerArguments.value!.emailActionType) {
        case EmailActionType.reply:
        case EmailActionType.forward:
        case EmailActionType.replyAll:
          return getEmailContentQuotedAsHtml(context, composerArguments.value!);
        case EmailActionType.edit:
          return getEmailContentDraftsAsHtml();
        default:
          return '';
      }
    }
    return '';
  }

  String? _getHeaderEmailQuoted(BuildContext context, ComposerArguments arguments) {
    final presentationEmail = arguments.presentationEmail;
    if (presentationEmail != null) {
      final locale = Localizations.localeOf(context).toLanguageTag();
      log('ComposerController::_getHeaderEmailQuoted(): emailActionType: ${arguments.emailActionType}');
      switch(arguments.emailActionType) {
        case EmailActionType.reply:
        case EmailActionType.replyAll:
          final receivedAt = presentationEmail.receivedAt;
          final emailAddress = presentationEmail.from.listEmailAddressToString(isFullEmailAddress: true);
          return AppLocalizations.of(context).header_email_quoted(
              receivedAt.formatDateToLocal(pattern: 'MMM d, y h:mm a', locale: locale),
              emailAddress);
        case EmailActionType.forward:
          var headerQuoted = '------- ${AppLocalizations.of(context).forwarded_message} -------'.addNewLineTag();

          final subject = presentationEmail.subject ?? '';
          final receivedAt = presentationEmail.receivedAt;
          final fromEmailAddress = presentationEmail.from.listEmailAddressToString(isFullEmailAddress: true);
          final toEmailAddress = presentationEmail.to.listEmailAddressToString(isFullEmailAddress: true);
          final ccEmailAddress = presentationEmail.cc.listEmailAddressToString(isFullEmailAddress: true);
          final bccEmailAddress = presentationEmail.bcc.listEmailAddressToString(isFullEmailAddress: true);

          if (subject.isNotEmpty) {
            headerQuoted = headerQuoted
                .append('${AppLocalizations.of(context).subject_email}: ')
                .append(subject)
                .addNewLineTag();
          }
          if (receivedAt != null) {
            headerQuoted = headerQuoted
                .append('${AppLocalizations.of(context).date}: ')
                .append(receivedAt.formatDateToLocal(pattern: 'MMM d, y h:mm a', locale: locale))
                .addNewLineTag();
          }
          if (fromEmailAddress.isNotEmpty) {
            headerQuoted = headerQuoted
                .append('${AppLocalizations.of(context).from_email_address_prefix}: ')
                .append(fromEmailAddress)
                .addNewLineTag();
          }
          if (toEmailAddress.isNotEmpty) {
            headerQuoted = headerQuoted
                .append('${AppLocalizations.of(context).to_email_address_prefix}: ')
                .append(toEmailAddress)
                .addNewLineTag();
          }
          if (ccEmailAddress.isNotEmpty) {
            headerQuoted = headerQuoted
                .append('${AppLocalizations.of(context).cc_email_address_prefix}: ')
                .append(ccEmailAddress)
                .addNewLineTag();
          }
          if (bccEmailAddress.isNotEmpty) {
            headerQuoted = headerQuoted
                .append('${AppLocalizations.of(context).bcc_email_address_prefix}: ')
                .append(bccEmailAddress)
                .addNewLineTag();
          }

          return headerQuoted;
        default:
          return null;
      }
    }
    return null;
  }

  void _initEmailAddress(ComposerArguments arguments) {
    final userProfile =  mailboxDashBoardController.userProfile.value;
    if (arguments.presentationEmail != null && userProfile != null) {
      final recipients = arguments.presentationEmail!.generateRecipientsEmailAddressForComposer(
          arguments.emailActionType,
          arguments.mailboxRole);

      listToEmailAddress = List.from(recipients.value1);
      listCcEmailAddress = List.from(recipients.value2);
      listBccEmailAddress = List.from(recipients.value3);

      if (listToEmailAddress.isNotEmpty || listCcEmailAddress.isNotEmpty || listBccEmailAddress.isNotEmpty) {
        isInitialRecipient.value = true;
        toAddressExpandMode.value = ExpandMode.COLLAPSE;
      }

      if (listCcEmailAddress.isNotEmpty) {
        listEmailAddressType.add(PrefixEmailAddress.cc);
        ccAddressExpandMode.value = ExpandMode.COLLAPSE;
      }

      if (listBccEmailAddress.isNotEmpty) {
        listEmailAddressType.add(PrefixEmailAddress.bcc);
        bccAddressExpandMode.value = ExpandMode.COLLAPSE;
      }
    } else if (arguments.emailAddress != null) {
      listToEmailAddress.add(arguments.emailAddress!);
      isInitialRecipient.value = true;
      toAddressExpandMode.value = ExpandMode.COLLAPSE;
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

  String getEmailContentQuotedAsHtml(BuildContext context, ComposerArguments arguments) {
    final headerEmailQuoted = _getHeaderEmailQuoted(context, arguments);
    log('ComposerController::getEmailContentQuotedAsHtml(): headerEmailQuoted: $headerEmailQuoted');
    final headerEmailQuotedAsHtml = headerEmailQuoted != null ? headerEmailQuoted.addBlockTag('cite') : '';

    final trustAsHtml = arguments.emailContents?.asHtmlString ?? '';
    final emailQuotedHtml = '${HtmlExtension.editorStartTags}$headerEmailQuotedAsHtml${trustAsHtml.addBlockQuoteTag()}';

    return emailQuotedHtml;
  }

  Future<Email> _generateEmail(
      BuildContext context,
      UserProfile userProfile,
      {
        bool asDrafts = false,
        MailboxId? draftMailboxId,
        MailboxId? outboxMailboxId
      }
  ) async {
    Set<EmailAddress> listFromEmailAddress = {EmailAddress(null, userProfile.email)};
    if (identitySelected.value?.email?.isNotEmpty == true) {
      listFromEmailAddress = {EmailAddress(
          identitySelected.value?.name,
          identitySelected.value?.email)};
    }
    Set<EmailAddress> listReplyToEmailAddress = {EmailAddress(null, userProfile.email)};
    if (identitySelected.value?.replyTo?.isNotEmpty == true) {
      listReplyToEmailAddress = identitySelected.value!.replyTo!;
    }

    final attachments = <EmailBodyPart>{};
    attachments.addAll(uploadController.generateAttachments() ?? []);

    var emailBodyText = await _getEmailBodyText(context);
    if (uploadController.mapInlineAttachments.isNotEmpty) {
      final mapContents = await _getMapContent(emailBodyText);
      emailBodyText = mapContents.value1;
      final listInlineAttachment = mapContents.value2;
      final listInlineEmailBodyPart = listInlineAttachment
          .map((attachment) => attachment.toEmailBodyPart(charset: 'base64'))
          .toSet();
      attachments.addAll(listInlineEmailBodyPart);
    }

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

    final generateEmailId = EmailId(Id(_uuid.v1()));
    final generatePartId = PartId(_uuid.v1());

    return Email(
      generateEmailId,
      mailboxIds: mailboxIds.isNotEmpty ? mailboxIds : null,
      from: listFromEmailAddress,
      to: listToEmailAddress.toSet(),
      cc: listCcEmailAddress.toSet(),
      bcc: listBccEmailAddress.toSet(),
      replyTo: listReplyToEmailAddress,
      keywords: mapKeywords.isNotEmpty ? mapKeywords : null,
      subject: subjectEmail.value,
      htmlBody: {
        EmailBodyPart(
          partId: generatePartId,
          type: MediaType.parse('text/html')
        )},
      bodyValues: {
        generatePartId: EmailBodyValue(emailBodyText, false, false)
      },
      headerUserAgent: {IndividualHeaderIdentifier.headerUserAgent : userAgent},
      attachments: attachments.isNotEmpty ? attachments : null,
      headerMdn: hasRequestReadReceipt.value ? {IndividualHeaderIdentifier.headerMdn: getEmailAddressSender()} : {},
    );
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

  void sendEmailAction(BuildContext context) async {
    clearFocusEditor(context);

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
          onConfirmAction: () => {},
          title: AppLocalizations.of(context).sending_failed,
          icon: SvgPicture.asset(_imagePaths.icSendToastError, fit: BoxFit.fill),
          hasCancelButton: false);
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
          },
          title: AppLocalizations.of(context).sending_failed,
          icon: SvgPicture.asset(_imagePaths.icSendToastError, fit: BoxFit.fill),
          hasCancelButton: false);
      return;
    }

    if (subjectEmail.value == null || subjectEmail.isEmpty == true) {
      showConfirmDialogAction(context,
          AppLocalizations.of(context).message_dialog_send_email_without_a_subject,
          AppLocalizations.of(context).send_anyway,
          onConfirmAction: () => _handleSendMessages(context),
          title: AppLocalizations.of(context).empty_subject,
          icon: SvgPicture.asset(_imagePaths.icEmpty, fit: BoxFit.fill),
      );
      return;
    }

    if (!uploadController.allUploadAttachmentsCompleted) {
      showConfirmDialogAction(
          context,
          AppLocalizations.of(context).messageDialogSendEmailUploadingAttachment,
          AppLocalizations.of(context).got_it,
          onConfirmAction: () => {},
          title: AppLocalizations.of(context).sending_failed,
          icon: SvgPicture.asset(_imagePaths.icSendToastError, fit: BoxFit.fill),
          hasCancelButton: false);
      return;
    }

    if (!uploadController.hasEnoughMaxAttachmentSize()) {
      showConfirmDialogAction(
          context,
          AppLocalizations.of(context).message_dialog_send_email_exceeds_maximum_size(
              filesize(mailboxDashBoardController.maxSizeAttachmentsPerEmail?.value ?? 0, 0)),
          AppLocalizations.of(context).got_it,
          onConfirmAction: () => {},
          title: AppLocalizations.of(context).sending_failed,
          icon: SvgPicture.asset(_imagePaths.icSendToastError, fit: BoxFit.fill),
          hasCancelButton: false);
      return;
    }

    _handleSendMessages(context);
  }

  void _handleSendMessages(BuildContext context) async {
    final arguments = composerArguments.value;
    final accountId = mailboxDashBoardController.accountId.value;
    final sentMailboxId = mailboxDashBoardController.mapDefaultMailboxIdByRole[PresentationMailbox.roleSent];
    final outboxMailboxId = mailboxDashBoardController.outboxMailbox?.id;
    final userProfile = mailboxDashBoardController.userProfile.value;

    if (arguments != null && accountId != null && userProfile != null) {
      final email = await _generateEmail(context, userProfile, outboxMailboxId: outboxMailboxId);
      final submissionCreateId = Id(_uuid.v1());
      final emailRequest = EmailRequest(
        email,
        submissionCreateId,
        sentMailboxId: sentMailboxId,
        identity: identitySelected.value,
        emailIdDestroyed: arguments.emailActionType == EmailActionType.edit
          ? arguments.presentationEmail?.id
          : null
      );
      final mailboxRequest = outboxMailboxId == null
        ? CreateNewMailboxRequest(Id(_uuid.v1()), PresentationMailbox.outboxMailboxName)
        : null;

      mailboxDashBoardController.handleSendEmailAction(accountId, emailRequest, mailboxRequest);
      uploadController.clearInlineFileUploaded();
    }

    if (BuildUtils.isWeb) {
      closeComposerWeb();
    } else {
      popBack();
    }
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

  @override
  void injectAutoCompleteBindings(Session? session, AccountId? accountId) {
    try {
      super.injectAutoCompleteBindings(session, accountId);
      _getAutoCompleteWithDeviceContactInteractor = Get.find<GetAutoCompleteWithDeviceContactInteractor>();
      _getAutoCompleteInteractor = Get.find<GetAutoCompleteInteractor>();
    } catch (e) {
      logError('ComposerController::injectAutoCompleteBindings(): $e');
    }
  }

  Future<List<EmailAddress>> getAutoCompleteSuggestion(String word) async {
    log('ComposerController::getAutoCompleteSuggestion(): $word | $_contactSuggestionSource');
    try {
      _getAutoCompleteWithDeviceContactInteractor = Get.find<GetAutoCompleteWithDeviceContactInteractor>();
      _getAutoCompleteInteractor = Get.find<GetAutoCompleteInteractor>();
    } catch (e) {
      logError('ComposerController::getAutoCompleteSuggestion(): Exception $e');
    }

    final accountId = mailboxDashBoardController.accountId.value;

    if (_contactSuggestionSource == ContactSuggestionSource.all) {
      if (_getAutoCompleteWithDeviceContactInteractor == null || _getAutoCompleteInteractor == null) {
        return <EmailAddress>[];
      }

      final listEmailAddress = await _getAutoCompleteWithDeviceContactInteractor!
        .execute(AutoCompletePattern(word: word, accountId: accountId))
        .then((value) => value.fold(
          (failure) => <EmailAddress>[],
          (success) => success is GetAutoCompleteSuccess
              ? success.listEmailAddress
              : <EmailAddress>[]));
      return listEmailAddress;
    } else {
      if (_getAutoCompleteInteractor == null) {
        return <EmailAddress>[];
      }

      final listEmailAddress = await _getAutoCompleteInteractor!
          .execute(AutoCompletePattern(word: word, accountId: accountId))
          .then((value) => value.fold(
              (failure) => <EmailAddress>[],
              (success) => success is GetAutoCompleteSuccess
                  ? success.listEmailAddress
                  : <EmailAddress>[]));
      return listEmailAddress;
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
        _appToast.showToastErrorMessage(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).can_not_upload_this_file_as_attachments);
      }
    }
  }

  void _pickFileSuccess(LocalFilePickerSuccess success) {
    if (uploadController.hasEnoughMaxAttachmentSize(listFiles: success.pickedFiles)) {
      _uploadAttachmentsAction(success.pickedFiles);
    } else {
      if (currentContext != null) {
        showConfirmDialogAction(
            currentContext!,
            AppLocalizations.of(currentContext!).message_dialog_upload_attachments_exceeds_maximum_size(
                filesize(mailboxDashBoardController.maxSizeAttachmentsPerEmail?.value ?? 0, 0)),
            AppLocalizations.of(currentContext!).got_it,
            onConfirmAction: () => {},
            title: AppLocalizations.of(currentContext!).maximum_files_size,
            hasCancelButton: false);
      }
    }
  }

  void _uploadAttachmentsAction(List<FileInfo> pickedFiles) async {
    final session = mailboxDashBoardController.sessionCurrent;
    final accountId = mailboxDashBoardController.accountId.value;
    if (session != null && accountId != null) {
      final uploadUri = session.getUploadUri(accountId);
      uploadController.justUploadAttachmentsAction(pickedFiles, uploadUri);
    }
  }

  void deleteAttachmentUploaded(UploadTaskId uploadId) {
    uploadController.deleteFileUploaded(uploadId);
  }

  Future<bool> _isEmailChanged(
      BuildContext context,
      ComposerArguments arguments,
  ) async {
    final newEmailBody = await _getEmailBodyText(context, changedEmail: true);
    log('ComposerController::_isEmailChanged(): newEmailBody: $newEmailBody');
    var oldEmailBody = _initTextEditor ?? '';
    log('ComposerController::_isEmailChanged(): oldEmailBody: $oldEmailBody');
    final isEmailBodyChanged = !oldEmailBody.trim().isSame(newEmailBody.trim());
    log('ComposerController::_isEmailChanged(): isEmailBodyChanged: $isEmailBodyChanged');

    final newEmailSubject = subjectEmail.value ?? '';
    final titleEmail = arguments.presentationEmail?.getEmailTitle().trim() ?? '';
    final oldEmailSubject = arguments.emailActionType == EmailActionType.edit ? titleEmail : '';
    final isEmailSubjectChanged = !oldEmailSubject.trim().isSame(newEmailSubject.trim());

    final recipients = arguments.presentationEmail
        ?.generateRecipientsEmailAddressForComposer(arguments.emailActionType, arguments.mailboxRole)
        ?? const Tuple3(<EmailAddress>[], <EmailAddress>[], <EmailAddress>[]);

    final newToEmailAddress = listToEmailAddress;
    final oldToEmailAddress = arguments.emailActionType == EmailActionType.edit ? recipients.value1 : [];
    final isToEmailAddressChanged = !oldToEmailAddress.isSame(newToEmailAddress);

    final newCcEmailAddress = listCcEmailAddress;
    final oldCcEmailAddress = arguments.emailActionType == EmailActionType.edit ? recipients.value2 : [];
    final isCcEmailAddressChanged = !oldCcEmailAddress.isSame(newCcEmailAddress);

    final newBccEmailAddress = listBccEmailAddress;
    final oldBccEmailAddress = arguments.emailActionType == EmailActionType.edit ? recipients.value3 : [];
    final isBccEmailAddressChanged = !oldBccEmailAddress.isSame(newBccEmailAddress);

    final isAttachmentsChanged = !initialAttachments.isSame(uploadController.attachmentsUploaded.toList());

    if (isEmailBodyChanged || isEmailSubjectChanged
        || isToEmailAddressChanged || isCcEmailAddressChanged
        || isBccEmailAddressChanged || isAttachmentsChanged) {
      return true;
    }

    return false;
  }

  void saveEmailAsDrafts(BuildContext context, {bool canPop = true}) async {
    clearFocusEditor(context);

    final arguments = composerArguments.value;
    final draftMailboxId = mailboxDashBoardController.mapDefaultMailboxIdByRole[PresentationMailbox.roleDrafts];
    final userProfile = mailboxDashBoardController.userProfile.value;
    final accountId = mailboxDashBoardController.accountId.value;

    if (arguments != null && userProfile != null && accountId != null) {
      final isChanged = await _isEmailChanged(context, arguments);
      if (isChanged && context.mounted) {
        final newEmail = await _generateEmail(
            context,
            userProfile,
            asDrafts: true,
            draftMailboxId: draftMailboxId);
        final oldEmail = arguments.presentationEmail;

        if (arguments.emailActionType == EmailActionType.edit && oldEmail != null) {
          mailboxDashBoardController.consumeState(
              _updateEmailDraftsInteractor.execute(accountId, newEmail, oldEmail.id));
        } else {
          mailboxDashBoardController.consumeState(
              _saveEmailAsDraftsInteractor.execute(accountId, newEmail));
        }

        uploadController.clearInlineFileUploaded();
      }
    }

    if (BuildUtils.isWeb) {
      mailboxDashBoardController.closeComposerOverlay();
    } else {
      if (canPop) popBack();
    }
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

  void _getEmailContentAction(ComposerArguments arguments) async {

    final listSharedMediaFile = arguments.listSharedMediaFile;
    if (listSharedMediaFile != null && listSharedMediaFile.isNotEmpty) {
      final listImageSharedMediaFile = listSharedMediaFile.where((element) => element.type == SharedMediaType.IMAGE);
      final listFileAttachmentSharedMediaFile = listSharedMediaFile.where((element) => element.type != SharedMediaType.IMAGE);
      if (listImageSharedMediaFile.isNotEmpty) {
        final listInlineImage = covertListSharedMediaFileToInlineImage(arguments.listSharedMediaFile!);
        for (var e in listInlineImage) {
          _uploadInlineAttachmentsAction(e.fileInfo!);
        }
      }
      if (listFileAttachmentSharedMediaFile.isNotEmpty) {
        final listFile = covertListSharedMediaFileToFileInfo(arguments.listSharedMediaFile!);
        if (uploadController.hasEnoughMaxAttachmentSize(listFiles: listFile)) {
          _uploadAttachmentsAction(listFile);
        } else {
          if (currentContext != null) {
            showConfirmDialogAction(
              currentContext!,
              AppLocalizations.of(currentContext!).message_dialog_upload_attachments_exceeds_maximum_size(
                  filesize(mailboxDashBoardController.maxSizeAttachmentsPerEmail?.value ?? 0, 0)),
              AppLocalizations.of(currentContext!).got_it,
              onConfirmAction: () => {},
              title: AppLocalizations.of(currentContext!).maximum_files_size,
              hasCancelButton: false,
            );
          }
        }
      }
    }

    if(arguments.emailContents != null && arguments.emailContents!.isNotEmpty) {
      _emailContents = arguments.emailContents;
      emailContentsViewState.value = Right(GetEmailContentSuccess(_emailContents!, [], [], null));
    } else {
      final baseDownloadUrl = mailboxDashBoardController.sessionCurrent?.getDownloadUrl();
      final accountId = mailboxDashBoardController.sessionCurrent?.accounts.keys.first;
      final emailId = arguments.presentationEmail?.id;
      if (emailId != null && baseDownloadUrl != null && accountId != null) {
        consumeState(_getEmailContentInteractor.execute(
          accountId,
          emailId,
          baseDownloadUrl,
          composeEmail: true,
          draftsEmail: arguments.presentationEmail?.isDraft ?? false
        ));
      }
    }
  }

  void _getEmailContentSuccess(GetEmailContentSuccess success) {
    if (success.attachments.isNotEmpty) {
      initialAttachments = success.attachments;
      uploadController.initializeUploadAttachments(
          success.attachments.listAttachmentsDisplayedOutSide);
    }
    emailContentsViewState.value = Right(success);
    _emailContents = success.emailContents;
  }

  String? getEmailContentDraftsAsHtml() => _emailContents?.asHtmlString;

  String getEmailAddressSender() {
    final arguments = composerArguments.value;
    if (arguments != null) {
      if (arguments.emailActionType == EmailActionType.edit) {
        return arguments.presentationEmail?.from?.first.emailAddress ?? '';
      } else {
        return mailboxDashBoardController.userProfile.value?.email ?? '';
      }
    }
    return '';
  }

  void clearFocusEditor(BuildContext context) {
    if (!kIsWeb) {
      htmlEditorApi?.unfocus();
    }
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void closeComposerWeb() {
    FocusManager.instance.primaryFocus?.unfocus();
    mailboxDashBoardController.closeComposerOverlay();
  }

  void displayScreenTypeComposerAction(ScreenDisplayMode displayMode) {
    FocusManager.instance.primaryFocus?.unfocus();
    createFocusNodeInput();
    _updateTextForEditor();
    screenDisplayMode.value = displayMode;
    _autoFocusFieldWhenLauncher();

    Future.delayed(
      const Duration(milliseconds: 500),
      () => selectIdentity(identitySelected.value)
    );
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
    listEmailAddressType.add(prefixEmailAddress);
  }

  void deleteEmailAddressType(PrefixEmailAddress prefixEmailAddress) {
    listEmailAddressType.remove(prefixEmailAddress);
    updateListEmailAddress(prefixEmailAddress, <EmailAddress>[]);
    switch(prefixEmailAddress) {
      case PrefixEmailAddress.cc:
        ccEmailAddressController.clear();
        break;
      case PrefixEmailAddress.bcc:
        bccEmailAddressController.clear();
        break;
      default:
        break;
    }
  }

  void onEditorFocusChange(bool isFocus) {
    log('ComposerController::onEditorFocusChange(): Focus: $isFocus');
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
    log('ComposerController::_autoCreateEmailTag():inputToEmail: $inputToEmail');
    log('ComposerController::_autoCreateEmailTag():inputCcEmail: $inputCcEmail');
    log('ComposerController::_autoCreateEmailTag():inputBccEmail: $inputBccEmail');

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
          ccAddressExpandMode.value = ExpandMode.COLLAPSE;
          bccAddressExpandMode.value = ExpandMode.COLLAPSE;
          break;
        case PrefixEmailAddress.cc:
          ccAddressExpandMode.value = ExpandMode.EXPAND;
          toAddressExpandMode.value = ExpandMode.COLLAPSE;
          bccAddressExpandMode.value = ExpandMode.COLLAPSE;
          break;
        case PrefixEmailAddress.bcc:
          bccAddressExpandMode.value = ExpandMode.EXPAND;
          toAddressExpandMode.value = ExpandMode.COLLAPSE;
          ccAddressExpandMode.value = ExpandMode.COLLAPSE;
          break;
        default:
          break;
      }
      _closeSuggestionBox();
      if (!BuildUtils.isWeb) {
        htmlEditorApi?.unfocus();
      }
    } else {
      if (!BuildUtils.isWeb) {
        _collapseAllRecipient();
        _autoCreateEmailTag();
      }
    }
  }

  Future<void> selectIdentity(Identity? newIdentity) async {
    final formerIdentity = identitySelected.value;
    identitySelected.value = newIdentity;
    if (newIdentity != null) {
      await _applyIdentityForAllFieldComposer(formerIdentity, newIdentity);
    }
    return Future.value(null);
  }

  bool get _isMobileApp {
    return !BuildUtils.isWeb
      && currentContext != null
      && (_responsiveUtils.isLandscapeMobile(currentContext!) || _responsiveUtils.isPortraitMobile(currentContext!));
  }

  Future<void> _applyIdentityForAllFieldComposer(
    Identity? formerIdentity,
    Identity newIdentity
  ) async {
    if (formerIdentity != null) {
      // Remove former identity
      if (formerIdentity.bcc?.isNotEmpty == true) {
        _removeBccEmailAddressFromFormerIdentity(formerIdentity.bcc!);
      }

      if (!_isMobileApp) {
        _removeSignature();
      }
    }
    // Add new identity
    if (newIdentity.bcc?.isNotEmpty == true) {
      await _applyBccEmailAddressFromIdentity(newIdentity.bcc!);
    }

    if (!_isMobileApp && newIdentity.signatureAsString.isNotEmpty == true) {
      _applySignature(newIdentity.signatureAsString.asSignatureHtml());
    }

    return Future.value(null);
  }

  Future<void> _applyBccEmailAddressFromIdentity(Set<EmailAddress> listEmailAddress) {
    if (!listEmailAddressType.contains(PrefixEmailAddress.bcc)) {
      listEmailAddressType.add(PrefixEmailAddress.bcc);
    }
    listBccEmailAddress = listEmailAddress.toList();
    toAddressExpandMode.value = ExpandMode.COLLAPSE;
    ccAddressExpandMode.value = ExpandMode.COLLAPSE;
    bccAddressExpandMode.value = ExpandMode.COLLAPSE;
    _updateStatusEmailSendButton();

    return Future.value(null);
  }

  void _removeBccEmailAddressFromFormerIdentity(Set<EmailAddress> listEmailAddress) {
    listBccEmailAddress = listBccEmailAddress
        .where((address) => !listEmailAddress.contains(address))
        .toList();
    if (listBccEmailAddress.isEmpty) {
      listEmailAddressType.remove(PrefixEmailAddress.bcc);
    }
    toAddressExpandMode.value = ExpandMode.COLLAPSE;
    ccAddressExpandMode.value = ExpandMode.COLLAPSE;
    bccAddressExpandMode.value = ExpandMode.COLLAPSE;
    _updateStatusEmailSendButton();
  }

  void _applySignature(String signature) {
    if (BuildUtils.isWeb) {
      richTextWebController.editorController.insertSignature(signature);
    } else {
      htmlEditorApi?.insertSignature(signature);
    }
  }

  void _removeSignature() {
    log('ComposerController::_removeSignature():');
    if (BuildUtils.isWeb) {
      richTextWebController.editorController.removeSignature();
    } else {
      htmlEditorApi?.removeSignature();
    }
  }

  void insertImage(BuildContext context, double maxWith) async {
    if (_responsiveUtils.isMobile(context)) {
      maxWithEditor = maxWith - 40;
    } else {
      maxWithEditor = maxWith - 120;
    }
    final inlineImage = await _selectFromFile();
    log('ComposerController::insertImage(): $inlineImage');
    if (inlineImage != null) {
      if (BuildUtils.isWeb) {
        _insertImageOnWeb(inlineImage);
      } else {
        _insertImageOnMobileAndTablet(inlineImage);
      }
    }
  }

  Future<InlineImage?> _selectFromFile() async {
    final filePickerResult = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: !BuildUtils.isWeb,
        withReadStream: BuildUtils.isWeb);
    final platformFile = filePickerResult?.files.single;
    if (platformFile != null) {
      final fileSelected = FileInfo(
          platformFile.name,
          BuildUtils.isWeb ? '' : platformFile.path ?? '',
          platformFile.size,
          bytes: platformFile.bytes,
          readStream: platformFile.readStream);
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

  void _uploadInlineAttachmentsAction(FileInfo pickedFile) async {
    if (uploadController.hasEnoughMaxAttachmentSize(listFiles: [pickedFile])) {
      final session = mailboxDashBoardController.sessionCurrent;
      final accountId = mailboxDashBoardController.accountId.value;
      if (session != null && accountId != null) {
        final uploadUri = session.getUploadUri(accountId);
        uploadController.uploadFileAction(pickedFile, uploadUri, isInline: true);
      }
    } else {
      if (currentContext != null) {
        showConfirmDialogAction(
            currentContext!,
            AppLocalizations.of(currentContext!).message_dialog_upload_attachments_exceeds_maximum_size(
                filesize(mailboxDashBoardController.maxSizeAttachmentsPerEmail?.value ?? 0, 0)),
            AppLocalizations.of(currentContext!).got_it,
            onConfirmAction: () => {},
            title: AppLocalizations.of(currentContext!).maximum_files_size,
            hasCancelButton: false);
      }
    }
  }

  void _handleUploadInlineSuccess(SuccessAttachmentUploadState uploadState) {
    uploadController.clearUploadInlineViewState();

    final baseDownloadUrl = mailboxDashBoardController.sessionCurrent?.getDownloadUrl();
    final accountId = mailboxDashBoardController.accountId.value;

    if (baseDownloadUrl != null && accountId != null) {
      final imageUrl = uploadState.attachment.getDownloadUrl(baseDownloadUrl, accountId);
      log('ComposerController::_handleUploadInlineSuccess(): imageUrl: $imageUrl');
      consumeState(_downloadImageAsBase64Interactor.execute(
          imageUrl,
          uploadState.attachment.cid!,
          uploadState.fileInfo,
          maxWidth: maxWithEditor));
    }
  }

  void closeComposer() {
    FocusManager.instance.primaryFocus?.unfocus();
    popBack();
  }

  void _onEditorFocusOnMobile() {
    if (Platform.isAndroid) {
      _collapseAllRecipient();
      _autoCreateEmailTag();
    }
  }

  void removeFocusAllInputEditorHeader() {
    subjectEmailInputFocusNode?.unfocus();
    toAddressFocusNode?.unfocus();
    ccAddressFocusNode?.unfocus();
    bccAddressFocusNode?.unfocus();
  }

  void _onChangeCursorOnMobile(List<int>? coordinates) {
    final headerEditorMobileWidgetRenderObject = headerEditorMobileWidgetKey.currentContext?.findRenderObject();

    if (headerEditorMobileWidgetRenderObject is RenderBox?) {
      final headerEditorMobileSize = headerEditorMobileWidgetRenderObject?.size;
      if (coordinates?[1] != null && coordinates?[1] != 0) {
        final coordinateY = max((coordinates?[1] ?? 0) - defaultPaddingCoordinateYCursorEditor, 0);
        final realCoordinateY = coordinateY + (headerEditorMobileSize?.height ?? 0);
        final webViewEditorClientY = max(Get.height - maxKeyBoardHeight - richTextBarHeight, 0) + scrollController.position.pixels;
        if (scrollController.position.pixels >= realCoordinateY) {
          scrollController.jumpTo(
            realCoordinateY.toDouble() - (headerEditorMobileSize?.height ?? 0) / 2,
          );
        }

        if ((realCoordinateY) >= webViewEditorClientY) {
          scrollController.jumpTo(
            realCoordinateY.toDouble(),
          );
        }
      }
    }
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
    } else if (BuildUtils.isWeb) {
      Future.delayed(
        const Duration(milliseconds: 500),
        richTextWebController.editorController.setFocus
      );
    }
  }

  void handleInitHtmlEditorWeb(String initContent) {
    onChangeTextEditorWeb(initContent);
    richTextWebController.setEnableCodeView();
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
    onEditorFocusChange(true);
  }
}