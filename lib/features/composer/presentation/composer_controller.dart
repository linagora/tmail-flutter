
import 'dart:async';

import 'package:core/core.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:http_parser/http_parser.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_body_part.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_body_value.dart';
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
import 'package:tmail_ui_user/features/composer/domain/state/search_email_address_state.dart';
import 'package:tmail_ui_user/features/composer/domain/state/send_email_state.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/upload_attachment_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/save_email_addresses_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/send_email_interactor.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/email_action_type_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/constants/email_constants.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/email_content_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/email/presentation/model/message_content.dart';
import 'package:tmail_ui_user/features/upload/domain/state/local_file_picker_state.dart';
import 'package:tmail_ui_user/features/upload/domain/usecases/local_file_picker_interactor.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:uuid/uuid.dart';

class ComposerController extends BaseController {

  final expandMode = ExpandMode.COLLAPSE.obs;
  final composerArguments = Rxn<ComposerArguments>();
  final isEnableEmailSendButton = false.obs;
  final listReplyToEmailAddress = <EmailAddress>[].obs;
  final attachments = <Attachment>[].obs;

  final SendEmailInteractor _sendEmailInteractor;
  final SaveEmailAddressesInteractor _saveEmailAddressInteractor;
  final GetAutoCompleteInteractor _getAutoCompleteInteractor;
  final GetAutoCompleteWithDeviceContactInteractor _getAutoCompleteWithDeviceContactInteractor;
  final AppToast _appToast;
  final Uuid _uuid;
  final HtmlEditorController composerEditorController;
  final TextEditingController subjectEmailInputController;
  final HtmlMessagePurifier _htmlMessagePurifier;
  final HtmlEditorController htmlEditorController;
  final LocalFilePickerInteractor _localFilePickerInteractor;
  final UploadAttachmentInteractor _uploadAttachmentInteractor;

  List<EmailAddress> listToEmailAddress = [];
  List<EmailAddress> listCcEmailAddress = [];
  List<EmailAddress> listBccEmailAddress = [];
  String? _subjectEmail;
  ContactSuggestionSource _contactSuggestionSource = ContactSuggestionSource.localContact;

  void setSubjectEmail(String subject) => _subjectEmail = subject;

  ComposerController(
    this._sendEmailInteractor,
    this._saveEmailAddressInteractor,
    this._getAutoCompleteInteractor,
    this._getAutoCompleteWithDeviceContactInteractor,
    this._appToast,
    this._uuid,
    this.composerEditorController,
    this.subjectEmailInputController,
    this._htmlMessagePurifier,
    this.htmlEditorController,
    this._localFilePickerInteractor,
    this._uploadAttachmentInteractor,
  );

  @override
  void onReady() async {
    super.onReady();
    _getSelectedEmail();

    Future.delayed(Duration(milliseconds: 500), () => _checkContactPermission());
  }

  @override
  void onDone() {
    viewState.value.fold(
      (failure) {
        if (failure is SendEmailFailure) {
          _sendEmailFailure(failure);
        } else if (failure is LocalFilePickerFailure || failure is LocalFilePickerCancel) {
          _pickFileFailure(failure);
        } else if (failure is UploadAttachmentFailure) {
          _uploadAttachmentsFailure(failure);
        }
      },
      (success) {
        if (success is SendEmailSuccess) {
          _sendEmailSuccess(success);
        } else if (success is LocalFilePickerSuccess) {
          _pickFileSuccess(success);
        } else if (success is UploadAttachmentSuccess) {
          _uploadAttachmentsSuccess(success);
        }
      });
  }

  @override
  void onError(error) {
    _appToast.showErrorToast(AppLocalizations.of(Get.context!).error_message_sent);
    popBack();
  }
  
  void _getSelectedEmail() {
    final arguments = Get.arguments;
    if (arguments is ComposerArguments) {
      composerArguments.value = arguments;
      _initToEmailAddress();
      _initSubjectEmail();
    }
  }

  void _initSubjectEmail() {
    if (composerArguments.value != null
        && composerArguments.value?.presentationEmail != null
        && Get.context != null) {
      final subject = '${composerArguments.value!.emailActionType.prefixSubjectComposer(Get.context!)} '
          '${composerArguments.value!.presentationEmail?.subject}';
      setSubjectEmail(subject);
      subjectEmailInputController.text = subject;
    }
  }

  void initContentEmail() {
    if (composerArguments.value != null
        && composerArguments.value!.emailActionType != EmailActionType.compose
        && Get.context != null) {
      final contentEmailQuoted = _getBodyEmailQuotedAsHtml(Get.context!, _htmlMessagePurifier);
      composerEditorController.setText(contentEmailQuoted);
    }
  }

  Tuple2<String, String>? getHeaderEmailQuoted(String locale) {
    if (composerArguments.value != null && composerArguments.value?.presentationEmail != null) {
      final sentDate = composerArguments.value!.presentationEmail?.sentAt;
      final emailAddress = composerArguments.value!.presentationEmail?.from.listEmailAddressToString(isFullEmailAddress: true) ?? '';
      return Tuple2(sentDate.formatDate(pattern: 'MMM d, y h:mm a', locale: locale), emailAddress);
    }
    return null;
  }

  Tuple3<List<MessageContent>, List<Attachment>, Session>? getContentEmailQuoted() {
    if (composerArguments.value != null) {
      final emailContent = composerArguments.value!.emailContent;
      final session = composerArguments.value!.session;
      if (emailContent != null) {
        final messageContents = emailContent.getListMessageContent();
        final attachmentsInline = emailContent.getListAttachmentInline();
        return Tuple3(messageContents, attachmentsInline, session);
      }
    }
    return null;
  }

  void expandEmailAddressAction() {
    final newExpandMode = expandMode.value == ExpandMode.COLLAPSE ? ExpandMode.EXPAND : ExpandMode.COLLAPSE;
    expandMode.value = newExpandMode;
  }

  void _initToEmailAddress() {
    if (composerArguments.value != null
        && composerArguments.value?.presentationEmail != null
        && composerArguments.value?.emailActionType == EmailActionType.reply) {
      final replyToEmailAddress = composerArguments.value!.presentationEmail?.replyTo;
      final fromEmailAddress = composerArguments.value!.presentationEmail?.from;
      if (replyToEmailAddress != null && replyToEmailAddress.isNotEmpty) {
        listReplyToEmailAddress.value = replyToEmailAddress.toList();
      } else if (fromEmailAddress != null && fromEmailAddress.isNotEmpty) {
        listReplyToEmailAddress.value = fromEmailAddress.toList();
      }
    }
    _updateStatusEmailSendButton();
  }

  void updateListEmailAddress(PrefixEmailAddress prefixEmailAddress, List<EmailAddress> newListEmailAddress) {
    switch(prefixEmailAddress) {
      case PrefixEmailAddress.to:
        listToEmailAddress = newListEmailAddress;
        listReplyToEmailAddress.clear();
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
        || listCcEmailAddress.isNotEmpty
        || listReplyToEmailAddress.isNotEmpty) {
      isEnableEmailSendButton.value = true;
    } else {
      isEnableEmailSendButton.value = false;
    }
  }

  String _getBodyEmailQuotedAsHtml(BuildContext context, HtmlMessagePurifier htmlMessagePurifier) {
    final headerEmailQuoted = getHeaderEmailQuoted(Localizations.localeOf(context).toLanguageTag());
    final contentEmail = getContentEmailQuoted();

    final headerEmailQuotedAsHtml = headerEmailQuoted != null
        ? AppLocalizations.of(context).header_email_quoted(headerEmailQuoted.value1, headerEmailQuoted.value2)
            .addBlockTag('p', attribute: 'style=\"font-size:14px;font-style:italic;color:#182952;\"')
        : '';

    var trustAsHtml = '';
    if (contentEmail != null && contentEmail.value1.isNotEmpty) {

      final messageContent = contentEmail.value1.first;
      final attachmentInlines = contentEmail.value2;
      final session = contentEmail.value3;
      final baseDownloadUrl = session.getDownloadUrl();
      final accountId = session.accounts.keys.first;

      final message = (attachmentInlines.isNotEmpty && messageContent.hasImageInlineWithCid())
          ? '${messageContent.getContentHasInlineAttachment(baseDownloadUrl, accountId, attachmentInlines)}'
          : '${messageContent.content}';

      trustAsHtml = htmlMessagePurifier.purifyHtmlMessage(message, allowAttributes: {'style', 'input', 'form'})
          .addBlockTag('div', attribute: 'style=\"margin-left:8px;margin-right:8px;padding-left:12px;padding-right:12px;border-left:6px solid #EFEFEF;\"')
          .addNewLineTag(count: 2);
    }

    final emailQuotedHtml = '$headerEmailQuotedAsHtml$trustAsHtml'
        .addBlockTag('div', attribute: 'style=\"padding-right:16px;padding-left:16px;background-color:#FBFBFF;width:100%\"');

    return emailQuotedHtml;
  }

  Future<Email> generateEmail() async {
    final generateEmailId = EmailId(Id(_uuid.v1()));
    final outboxMailboxId = composerArguments.value!.mapMailboxId[PresentationMailbox.roleOutbox];
    final listFromEmailAddress = {
      EmailAddress(null, composerArguments.value!.userProfile.email)
    };
    final generatePartId = PartId(_uuid.v1());
    final generateBlobId = Id(_uuid.v1());

    final emailBodyText = await composerEditorController.getText();

    return Email(
      generateEmailId,
      mailboxIds: {outboxMailboxId!: true},
      from: listFromEmailAddress,
      to: listToEmailAddress.toSet(),
      cc: listCcEmailAddress.toSet(),
      bcc: listBccEmailAddress.toSet(),
      subject: _subjectEmail,
      htmlBody: {
        EmailBodyPart(
          partId: generatePartId,
          blobId: generateBlobId,
          type: MediaType.parse(EmailConstants.HTML_TEXT)
        )},
      bodyValues: {
        generatePartId: EmailBodyValue(emailBodyText, false, false)
      }
    );
  }

  void sendEmailAction(BuildContext context) async {
    if (isEnableEmailSendButton.value) {
      _appToast.showToast(AppLocalizations.of(context).your_email_being_sent);

      final email = await generateEmail();
      final accountId = composerArguments.value!.session.accounts.keys.first;
      final sentMailboxId = composerArguments.value!.mapMailboxId[PresentationMailbox.roleSent];
      final submissionCreateId = Id(_uuid.v1());

      consumeState(_sendEmailInteractor.execute(accountId, EmailRequest(email, submissionCreateId, mailboxIdSaved: sentMailboxId)));
    } else {
      _appToast.showErrorToast(AppLocalizations.of(context).your_email_should_have_at_least_one_recipient);
    }
  }

  void _sendEmailSuccess(Success success) {
    _saveEmailAddress();
    _appToast.showSuccessToast(AppLocalizations.of(Get.context!).message_sent);
    popBack();
  }

  void _sendEmailFailure(Failure failure) {
    _appToast.showErrorToast(AppLocalizations.of(Get.context!).error_message_sent);
    popBack();
  }

  void _saveEmailAddress() {
    final listEmailAddressCanSave = Set<EmailAddress>();
    listEmailAddressCanSave.addAll(listToEmailAddress + listCcEmailAddress + listBccEmailAddress);
    _saveEmailAddressInteractor.execute(listEmailAddressCanSave.toList());
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
      _uploadAttachmentsAction(success.fileInfo);
    }
  }

  void _uploadAttachmentsAction(FileInfo fileInfo) async {
    if (composerArguments.value != null) {
      final accountId = composerArguments.value!.session.accounts.keys.first;
      final uploadUrl = composerArguments.value!.session.getUploadUrl(accountId);

      consumeState(_uploadAttachmentInteractor.execute(fileInfo, accountId, uploadUrl));
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
      if (Get.context != null) {
        _appToast.showSuccessToast(AppLocalizations.of(Get.context!).attachments_uploaded_successfully);
      }
    }
  }

  void removeAttachmentAction(Attachment attachmentRemoved) {
    attachments.removeWhere((attachment) => attachment == attachmentRemoved);
  }

  void backToEmailViewAction() {
    Get.back();
  }
}