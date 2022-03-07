
import 'dart:async';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:enough_html_editor/enough_html_editor.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fk_user_agent/fk_user_agent.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart' as HtmlEditorBrowser;
import 'package:http_parser/http_parser.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_body_part.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_body_value.dart';
import 'package:jmap_dart_client/jmap/mail/email/individual_header_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:model/model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/composer/domain/model/auto_complete_pattern.dart';
import 'package:tmail_ui_user/features/composer/domain/model/contact_suggestion_source.dart';
import 'package:tmail_ui_user/features/composer/domain/model/email_request.dart';
import 'package:tmail_ui_user/features/composer/domain/state/get_autocomplete_state.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_autocomplete_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_autocomplete_with_device_contact_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/state/upload_attachment_state.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/save_email_addresses_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/save_email_as_drafts_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/send_email_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/update_email_drafts_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/upload_mutiple_attachment_interactor.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/email_action_type_extension.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_email_content_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_email_content_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/upload/domain/state/local_file_picker_state.dart';
import 'package:tmail_ui_user/features/upload/domain/usecases/local_file_picker_interactor.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/utils/app_logger.dart';
import 'package:uuid/uuid.dart';

class ComposerController extends BaseController {

  final mailboxDashBoardController = Get.find<MailboxDashBoardController>();
  
  final expandMode = ExpandMode.COLLAPSE.obs;
  final composerArguments = Rxn<ComposerArguments>();
  final isEnableEmailSendButton = false.obs;
  final isInitialRecipient = false.obs;
  final attachments = <Attachment>[].obs;
  final emailContents = <EmailContent>[].obs;

  final SendEmailInteractor _sendEmailInteractor;
  final SaveEmailAddressesInteractor _saveEmailAddressInteractor;
  final GetAutoCompleteInteractor _getAutoCompleteInteractor;
  final GetAutoCompleteWithDeviceContactInteractor _getAutoCompleteWithDeviceContactInteractor;
  final AppToast _appToast;
  final ImagePaths _imagePaths;
  final Uuid _uuid;
  final TextEditingController subjectEmailInputController;
  final LocalFilePickerInteractor _localFilePickerInteractor;
  final UploadMultipleAttachmentInteractor _uploadMultipleAttachmentInteractor;
  final DeviceInfoPlugin _deviceInfoPlugin;
  final SaveEmailAsDraftsInteractor _saveEmailAsDraftsInteractor;
  final GetEmailContentInteractor _getEmailContentInteractor;
  final UpdateEmailDraftsInteractor _updateEmailDraftsInteractor;

  List<EmailAddress> listToEmailAddress = <EmailAddress>[];
  List<EmailAddress> listCcEmailAddress = <EmailAddress>[];
  List<EmailAddress> listBccEmailAddress = <EmailAddress>[];
  String? _subjectEmail;
  ContactSuggestionSource _contactSuggestionSource = ContactSuggestionSource.localContact;
  HtmlEditorApi? htmlEditorApi;
  final HtmlEditorBrowser.HtmlEditorController htmlControllerBrowser = HtmlEditorBrowser.HtmlEditorController();

  final toEmailAddressController = TextEditingController();
  final ccEmailAddressController = TextEditingController();
  final bccEmailAddressController = TextEditingController();

  List<Attachment> initialAttachments = <Attachment>[];

  void setSubjectEmail(String subject) => _subjectEmail = subject;

  Future<String> _getEmailBodyText({bool onlyText = false}) async {
    if (kIsWeb) {
      return await htmlControllerBrowser.getText();
    } else {
      if (onlyText) {
        return (await htmlEditorApi?.getText()) ?? '';
      } else {
        return (await htmlEditorApi?.getFullHtml()) ?? '';
      }
    }
  }

  ComposerController(
    this._sendEmailInteractor,
    this._saveEmailAddressInteractor,
    this._getAutoCompleteInteractor,
    this._getAutoCompleteWithDeviceContactInteractor,
    this._appToast,
    this._imagePaths,
    this._uuid,
    this._deviceInfoPlugin,
    this.subjectEmailInputController,
    this._localFilePickerInteractor,
    this._uploadMultipleAttachmentInteractor,
    this._saveEmailAsDraftsInteractor,
    this._getEmailContentInteractor,
    this._updateEmailDraftsInteractor,
  );

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
      await FkUserAgent.init();
    });
  }

  @override
  void onReady() async {
    super.onReady();
    _initEmail();

    Future.delayed(Duration(milliseconds: 500), () => _checkContactPermission());
  }

  @override
  void onClose() {
    subjectEmailInputController.dispose();

    toEmailAddressController.dispose();
    ccEmailAddressController.dispose();
    bccEmailAddressController.dispose();

    htmlControllerBrowser.clearFocus();
    super.onClose();
  }

  @override
  void onDone() {
    viewState.value.fold(
      (failure) {
        if (failure is LocalFilePickerFailure || failure is LocalFilePickerCancel) {
          _pickFileFailure(failure);
        } else if (failure is UploadAttachmentFailure
          || failure is UploadMultipleAttachmentAllFailure) {
          _uploadAttachmentsFailure(failure);
        }
      },
      (success) {
        if (success is LocalFilePickerSuccess) {
          _pickFileSuccess(success);
        } else if (success is UploadAttachmentSuccess
          || success is UploadMultipleAttachmentAllSuccess
          || success is UploadMultipleAttachmentHasSomeFailure) {
          _uploadAttachmentsSuccess(success);
        } else if (success is GetEmailContentSuccess) {
          _getEmailContentSuccess(success);
        }
      });
  }

  @override
  void onError(error) {
    if (Get.overlayContext != null && Get.context != null) {
      _appToast.showToastWithIcon(
          Get.overlayContext!,
          textColor: AppColor.toastErrorBackgroundColor,
          message: AppLocalizations.of(Get.context!).message_has_been_sent_failure,
          icon: _imagePaths.icSendToast);
    }
    popBack();
  }
  
  void _initEmail() {
    final arguments = Get.arguments;
    if (arguments is ComposerArguments) {
      composerArguments.value = arguments;
      if (arguments.emailActionType == EmailActionType.edit) {
        _getEmailContentAction(arguments);
      }
      _initToEmailAddress(arguments);
      _initSubjectEmail(arguments);
    }
  }

  void _initSubjectEmail(ComposerArguments arguments) {
    if (Get.context != null) {
      final subjectEmail = arguments.presentationEmail?.getEmailTitle().trim() ?? '';
      final newSubject = arguments.emailActionType.getSubjectComposer(Get.context!, subjectEmail);
      setSubjectEmail(newSubject);
      subjectEmailInputController.text = newSubject;
    }
  }

  String getContentEmail() {
    if (composerArguments.value != null
        && composerArguments.value!.emailActionType != EmailActionType.compose
        && Get.context != null) {
      if (composerArguments.value?.emailActionType == EmailActionType.edit) {
        return _getOldEmailContentAsHtml();
      } else {
        return _getBodyEmailQuotedAsHtml(Get.context!, composerArguments.value!);
      }
    }
    return '';
  }

  Tuple2<String, String>? _getHeaderEmailQuoted(String locale, ComposerArguments arguments) {
    if (arguments.presentationEmail != null) {
      final sentDate = arguments.presentationEmail?.sentAt;
      final emailAddress = arguments.presentationEmail?.from.listEmailAddressToString(isFullEmailAddress: true) ?? '';
      return Tuple2(sentDate.formatDate(pattern: 'MMM d, y h:mm a', locale: locale), emailAddress);
    }
    return null;
  }

  void expandEmailAddressAction() {
    final newExpandMode = expandMode.value == ExpandMode.COLLAPSE ? ExpandMode.EXPAND : ExpandMode.COLLAPSE;
    expandMode.value = newExpandMode;
  }

  void _initToEmailAddress(ComposerArguments arguments) {
    if (arguments.presentationEmail != null) {
      final userEmailAddress = EmailAddress(null, arguments.userProfile.email);

      final recipients = arguments.presentationEmail!.generateRecipientsEmailAddressForComposer(arguments.emailActionType, arguments.mailboxRole);

      if (arguments.mailboxRole == PresentationMailbox.roleSent || arguments.emailActionType == EmailActionType.edit) {
        listToEmailAddress = recipients.value1;
        listCcEmailAddress = recipients.value2;
        listBccEmailAddress = recipients.value3;
      } else {
        listToEmailAddress = recipients.value1.toSet().filterEmailAddress(userEmailAddress);
        listCcEmailAddress = recipients.value2.toSet().filterEmailAddress(userEmailAddress);
        listBccEmailAddress = recipients.value3.toSet().filterEmailAddress(userEmailAddress);
      }

      if (listCcEmailAddress.isNotEmpty || listBccEmailAddress.isNotEmpty) {
        expandMode.value = ExpandMode.EXPAND;
      } else {
        expandMode.value = ExpandMode.COLLAPSE;
      }

      if (listToEmailAddress.isNotEmpty || listCcEmailAddress.isNotEmpty || listBccEmailAddress.isNotEmpty) {
        isInitialRecipient.value = true;
      }
    }
    _updateStatusEmailSendButton();
  }

  void updateListEmailAddress(PrefixEmailAddress prefixEmailAddress, List<EmailAddress> newListEmailAddress) {
    switch(prefixEmailAddress) {
      case PrefixEmailAddress.to:
        listToEmailAddress = newListEmailAddress;
        break;
      case PrefixEmailAddress.cc:
        listCcEmailAddress = newListEmailAddress;
        break;
      case PrefixEmailAddress.bcc:
        listBccEmailAddress = newListEmailAddress;
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

  String _getBodyEmailQuotedAsHtml(BuildContext context, ComposerArguments arguments) {
    final headerEmailQuoted = _getHeaderEmailQuoted(Localizations.localeOf(context).toLanguageTag(), arguments);

    final headerEmailQuotedAsHtml = headerEmailQuoted != null
      ? AppLocalizations.of(context).header_email_quoted(headerEmailQuoted.value1, headerEmailQuoted.value2)
          .addBlockTag('p', attribute: 'style=\"font-size:14px;font-style:italic;color:#182952;\"')
      : '';

    final trustAsHtml = arguments.emailContents
      ?.map((emailContent) => emailContent.asHtml)
      .toList()
      .join('<br>') ?? '';

    final emailQuotedHtml = '<br><br><br>$headerEmailQuotedAsHtml${trustAsHtml.addBlockQuoteTag()}<br>';

    return emailQuotedHtml;
  }

  Future<Email> _generateEmail(ComposerArguments arguments, {bool asDrafts = false}) async {
    final generateEmailId = EmailId(Id(_uuid.v1()));
    final outboxMailboxId = arguments.mapMailboxId[PresentationMailbox.roleOutbox];
    final draftMailboxId = arguments.mapMailboxId[PresentationMailbox.roleDrafts];
    final listFromEmailAddress = {
      EmailAddress(null, arguments.userProfile.email)
    };
    final generatePartId = PartId(_uuid.v1());
    final generateBlobId = Id(_uuid.v1());

    final emailBodyText = await _getEmailBodyText();
    final userAgent = await userAgentPlatform;

    return Email(
      generateEmailId,
      mailboxIds: asDrafts ? {draftMailboxId!: true} : {outboxMailboxId!: true},
      from: listFromEmailAddress,
      to: listToEmailAddress.toSet(),
      cc: listCcEmailAddress.toSet(),
      bcc: listBccEmailAddress.toSet(),
      keywords: asDrafts ? {KeyWordIdentifier.emailDraft : true} : null,
      subject: _subjectEmail,
      htmlBody: {
        EmailBodyPart(
          partId: generatePartId,
          blobId: generateBlobId,
          type: MediaType.parse('text/html')
        )},
      bodyValues: {
        generatePartId: EmailBodyValue(emailBodyText, false, false)
      },
      headerUserAgent: {IndividualHeaderIdentifier.headerUserAgent : userAgent},
      attachments: attachments.isNotEmpty ? _generateAttachments() : null,
    );
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
      log('ComposerController - userAgentPlatform(): userAgent: $userAgent');
    } on Exception {
      userAgent = '';
    }
    return userAgent;
  }

  Set<EmailBodyPart> _generateAttachments() {
    return attachments.map((attachment) =>
      attachment.toEmailBodyPart(ContentDisposition.attachment.value)).toSet();
  }

  void sendEmailAction(BuildContext context) async {
    if (isEnableEmailSendButton.value) {
      final arguments = composerArguments.value;
      if (arguments != null) {
        _saveEmailAddress();

        final email = await _generateEmail(arguments);
        final accountId = arguments.session.accounts.keys.first;
        final sentMailboxId = arguments.mapMailboxId[PresentationMailbox.roleSent];
        final submissionCreateId = Id(_uuid.v1());

        mailboxDashBoardController.consumeState(_sendEmailInteractor.execute(
            accountId,
            EmailRequest(
                email,
                submissionCreateId,
                mailboxIdSaved: sentMailboxId,
                emailIdDestroyed: arguments.emailActionType == EmailActionType.edit ? arguments.presentationEmail?.id : null)));
      }

      popBack();
    } else {
      _appToast.showErrorToast(AppLocalizations.of(context).your_email_should_have_at_least_one_recipient);
    }
  }

  void _saveEmailAddress() async {
    final listEmailAddressCanSave = Set<EmailAddress>();
    listEmailAddressCanSave.addAll(listToEmailAddress + listCcEmailAddress + listBccEmailAddress);
    await _saveEmailAddressInteractor.execute(listEmailAddressCanSave.toList());
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
    if (_contactSuggestionSource == ContactSuggestionSource.all) {
      return await _getAutoCompleteWithDeviceContactInteractor.execute(AutoCompletePattern(word: word))
        .then((value) => value.fold(
          (failure) => <EmailAddress>[],
          (success) => success is GetAutoCompleteSuccess ? success.listEmailAddress : <EmailAddress>[]));
    }
    return await _getAutoCompleteInteractor.execute(AutoCompletePattern(word: word))
      .then((value) => value.fold(
        (failure) => <EmailAddress>[],
        (success) => success is GetAutoCompleteSuccess ? success.listEmailAddress : <EmailAddress>[]));
  }

  void openPickAttachmentMenu(BuildContext context, List<Widget> actionTiles) {
      (ContextMenuBuilder(context)
        ..addHeader(
              (ContextMenuHeaderBuilder(Key('attachment_picker_context_menu_header_builder'))
              ..addLabel(AppLocalizations.of(context).pick_attachments))
            .build())
        ..addTiles(actionTiles))
    .build();
  }

  void openFilePickerByType(BuildContext context, FileType fileType) async {
    popBack();
    consumeState(_localFilePickerInteractor.execute(fileType: fileType));
  }

  void _pickFileFailure(Failure failure) {
    if (failure is LocalFilePickerFailure) {
      if (Get.context != null) {
        _appToast.showErrorToast(AppLocalizations.of(Get.context!).can_not_upload_this_file_as_attachments);
      }
    }
  }

  void _pickFileSuccess(Success success) {
    if (success is LocalFilePickerSuccess) {
      _uploadAttachmentsAction(success.pickedFiles);
    }
  }

  void _uploadAttachmentsAction(List<FileInfo> pickedFiles) async {
    if (composerArguments.value != null) {
      final accountId = composerArguments.value!.session.accounts.keys.first;
      final uploadUrl = composerArguments.value!.session.getUploadUrl(accountId);

      consumeState(_uploadMultipleAttachmentInteractor.execute(pickedFiles, accountId, uploadUrl));
    }
  }

  void _uploadAttachmentsFailure(Failure failure) {
    if (Get.context != null) {
      _appToast.showErrorToast(AppLocalizations.of(Get.context!).can_not_upload_this_file_as_attachments);
    }
  }

  void _uploadAttachmentsSuccess(Success success) {
    if (success is UploadAttachmentSuccess) {
      attachments.add(success.attachment);
    } else if (success is UploadMultipleAttachmentAllSuccess) {
      final listAttachment = success.listResults.where((either) => either.isRight())
        .map((either) => either
          .map((result) => (result as UploadAttachmentSuccess).attachment)
          .toIterable().first)
        .toList();

      attachments.addAll(listAttachment);
    } else if (success is UploadMultipleAttachmentHasSomeFailure) {
      final listAttachment = success.listResults
        .map((either) => either
        .map((result) => (result as UploadAttachmentSuccess).attachment)
        .toIterable().first)
        .toList();

      attachments.addAll(listAttachment);
    }
    if (Get.context != null) {
      _appToast.showSuccessToast(AppLocalizations.of(Get.context!).attachments_uploaded_successfully);
    }
  }

  void removeAttachmentAction(Attachment attachmentRemoved) {
    attachments.removeWhere((attachment) => attachment == attachmentRemoved);
  }

  Future<bool> _isEmailChanged(ComposerArguments arguments) async {
    final newEmailBody = await _getEmailBodyText(onlyText: true);
    final oldEmailBody = kIsWeb ? getContentEmail() : '\n${getContentEmail()}\n';
    final isEmailBodyChanged = !oldEmailBody.isSame(newEmailBody);

    final newEmailSubject = _subjectEmail;
    final subjectEmail = arguments.presentationEmail?.getEmailTitle().trim() ?? '';
    final oldEmailSubject = arguments.emailActionType.getSubjectComposer(Get.context!, subjectEmail);
    final isEmailSubjectChanged = !oldEmailSubject.isSame(newEmailSubject);

    final recipients = arguments.presentationEmail
        ?.generateRecipientsEmailAddressForComposer(arguments.emailActionType, arguments.mailboxRole)
        ?? Tuple3(<EmailAddress>[], <EmailAddress>[], <EmailAddress>[]);

    final newToEmailAddress = listToEmailAddress;
    final oldToEmailAddress = recipients.value1;
    final isToEmailAddressChanged = !oldToEmailAddress.isSame(newToEmailAddress);

    final newCcEmailAddress = listToEmailAddress;
    final oldCcEmailAddress = recipients.value1;
    final isCcEmailAddressChanged = !oldCcEmailAddress.isSame(newCcEmailAddress);

    final newBccEmailAddress = listToEmailAddress;
    final oldBccEmailAddress = recipients.value1;
    final isBccEmailAddressChanged = !oldBccEmailAddress.isSame(newBccEmailAddress);

    final isAttachmentsChanged = !initialAttachments.isSame(attachments.toList());

    if (isEmailBodyChanged || isEmailSubjectChanged
        || isToEmailAddressChanged || isCcEmailAddressChanged
        || isBccEmailAddressChanged || isAttachmentsChanged) {
      return true;
    }

    return false;
  }

  void saveEmailAsDrafts() async {
    final arguments = composerArguments.value;
    if (arguments != null && Get.context != null) {
      final isChanged = await _isEmailChanged(arguments);
      if (isChanged) {
        _saveEmailAddress();

        final newEmail = await _generateEmail(arguments, asDrafts: true);
        final accountId = arguments.session.accounts.keys.first;
        final oldEmail = arguments.presentationEmail;

        if (arguments.emailActionType == EmailActionType.edit && oldEmail != null) {
          mailboxDashBoardController.consumeState(_updateEmailDraftsInteractor.execute(accountId, newEmail, oldEmail.id));
        } else {
          mailboxDashBoardController.consumeState(_saveEmailAsDraftsInteractor.execute(accountId, newEmail));
        }
      }
    }
  }

  void _getEmailContentAction(ComposerArguments arguments) async {
    final baseDownloadUrl = arguments.session.getDownloadUrl();
    final accountId = arguments.session.accounts.keys.first;
    final emailId = arguments.presentationEmail?.id;
    if (emailId != null) {
      consumeState(_getEmailContentInteractor.execute(accountId, emailId, baseDownloadUrl));
    }
  }

  void _getEmailContentSuccess(GetEmailContentSuccess success) {
    emailContents.value = success.emailContents;
    attachments.value = success.attachments;
    initialAttachments = success.attachments;
  }

  String _getOldEmailContentAsHtml() {
    if (emailContents.isNotEmpty) {
      final trustAsHtml = emailContents
          .map((emailContent) => emailContent.content)
          .toList()
          .join('</br>');
      return trustAsHtml;
    }
    return '';
  }

  String getEmailAddressSender() {
    final arguments = composerArguments.value;
    if (arguments != null) {
      if (arguments.emailActionType == EmailActionType.edit) {
        return arguments.presentationEmail?.from?.first.emailAddress ?? '';
      } else {
        return arguments.userProfile.email;
      }
    }
    return '';
  }

  void backToEmailViewAction() {
    popBack();
  }
}