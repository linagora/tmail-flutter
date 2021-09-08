
import 'dart:async';

import 'package:core/core.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:dartz/dartz.dart';
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
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/composer/domain/model/auto_complete_pattern.dart';
import 'package:tmail_ui_user/features/composer/domain/model/email_request.dart';
import 'package:tmail_ui_user/features/composer/domain/state/search_email_address_state.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/save_email_addresses_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/search_email_address_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/send_email_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/constants/email_constants.dart';
import 'package:tmail_ui_user/features/email/presentation/model/attachment_file.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/email_content_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/email_action_type_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/model/message_content.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:uuid/uuid.dart';

class ComposerController extends BaseController {

  final expandMode = ExpandMode.COLLAPSE.obs;
  final composerArguments = Rxn<ComposerArguments>();
  final isEnableEmailSendButton = false.obs;
  final listReplyToEmailAddress = <EmailAddress>[].obs;

  final SendEmailInteractor _sendEmailInteractor;
  final SaveEmailAddressesInteractor _saveEmailAddressInteractor;
  final SearchEmailAddressInteractor _searchEmailAddressInteractor;
  final AppToast _appToast;
  final Uuid _uuid;
  final HtmlEditorController htmlEditorController;

  List<EmailAddress> listToEmailAddress = [];
  List<EmailAddress> listCcEmailAddress = [];
  List<EmailAddress> listBccEmailAddress = [];
  String? _subjectEmail;

  void setSubjectEmail(String subject) => _subjectEmail = subject;

  ComposerController(
    this._sendEmailInteractor,
    this._saveEmailAddressInteractor,
    this._searchEmailAddressInteractor,
    this._appToast,
    this._uuid,
    this.htmlEditorController,
  );

  @override
  void onReady() async {
    super.onReady();
    _getSelectedEmail();
    await searchEmailAddressSuggestion('');
  }

  @override
  void onDone() {
    viewState.value.fold(
      (failure) {
        _appToast.showErrorToast(AppLocalizations.of(Get.context!).error_message_sent);
        Get.back();
      },
      (success) {
        _saveEmailAddress();
        _appToast.showSuccessToast(AppLocalizations.of(Get.context!).message_sent);
        Get.back();
      });
  }

  @override
  void onError(error) {
    _appToast.showErrorToast(AppLocalizations.of(Get.context!).error_message_sent);
    Get.back();
  }
  
  void _getSelectedEmail() {
    final arguments = Get.arguments;
    if (arguments is ComposerArguments) {
      composerArguments.value = arguments;
      _initToEmailAddress();
    }
  }

  EmailActionType getEmailActionType() => composerArguments.value != null
      ? composerArguments.value!.emailActionType
      : EmailActionType.compose;

  String getEmailSubject(BuildContext context) {
    if (composerArguments.value != null && composerArguments.value?.presentationEmail != null) {
      final subject = composerArguments.value!.presentationEmail?.subject;
      return '${composerArguments.value!.emailActionType.prefixSubjectComposer(context)} $subject';
    }
    return '';
  }

  Tuple2<String, String>? getHeaderEmailQuoted(String locale) {
    if (composerArguments.value != null && composerArguments.value?.presentationEmail != null) {
      final sentDate = composerArguments.value!.presentationEmail?.sentAt;
      final emailAddress = composerArguments.value!.presentationEmail?.from.listEmailAddressToString(isFullEmailAddress: true) ?? '';
      return Tuple2(sentDate.formatDate(pattern: 'MMM d, y h:mm a', locale: locale), emailAddress);
    }
    return null;
  }

  Tuple3<List<MessageContent>, List<AttachmentFile>, Session>? getContentEmailQuoted() {
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

  String getBodyEmailQuotedAsHtml(BuildContext context, HtmlMessagePurifier htmlMessagePurifier) {
    final headerEmailQuoted = getHeaderEmailQuoted(Localizations.localeOf(context).toLanguageTag());
    final contentEmail = getContentEmailQuoted();

    final placeHolderBodyEmailEditor = AppLocalizations.of(context).hint_content_email_composer
      .addBlockTag('p', attribute: 'style=\"font-size:14px;color:#182952;\"')
      .addNewLineTag();

    final headerEmailQuotedAsHtml = headerEmailQuoted != null
        ? AppLocalizations.of(context).header_email_quoted(headerEmailQuoted.value1, headerEmailQuoted.value2)
            .addBlockTag('p', attribute: 'style=\"font-size:14px;font-style:italic;color:#182952;\"')
        : '';

    var trustAsHtml = '';
    if (contentEmail != null && contentEmail.value1.isNotEmpty) {

      final messageContent = contentEmail.value1.first;
      final attachmentInlines = contentEmail.value2;
      final session = contentEmail.value3;
      final accountId = session.accounts.keys.first;

      final message = (attachmentInlines.isNotEmpty && messageContent.hasImageInlineWithCid())
          ? '${messageContent.getContentHasInlineAttachment(session, accountId, attachmentInlines)}'
          : '${messageContent.content}';

      trustAsHtml = htmlMessagePurifier.purifyHtmlMessage(message, allowAttributes: {'style', 'input', 'form'})
          .addBlockTag('div', attribute: 'style=\"margin-left:8px;margin-right:8px;padding-left:12px;padding-right:12px;border-left:6px solid #EFEFEF;\"')
          .addNewLineTag(count: 2);
    }

    final emailQuotedHtml = '$placeHolderBodyEmailEditor$headerEmailQuotedAsHtml$trustAsHtml'
        .addBlockTag('div', attribute: 'style=\"padding-right:16px;padding-left:16px;background-color:#FBFBFF;width:100%\"');

    return emailQuotedHtml;
  }

  Future<Email> generateEmail() async {
    final generateEmailId = EmailId(Id(_uuid.v1()));
    final outboxMailboxId = composerArguments.value!.mapMailboxId[PresentationMailbox.roleOutbox];
    final listFromEmailAddress = {
      EmailAddress(
        composerArguments.value!.userProfile.getNameDisplay(),
        composerArguments.value!.userProfile.getEmailAddress())
    };
    final generatePartId = PartId(_uuid.v1());
    final generateBlobId = Id(_uuid.v1());

    final emailBodyText = await htmlEditorController.getText();

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

  void _saveEmailAddress() {
    final listEmailAddressCanSave = Set<EmailAddress>();
    listEmailAddressCanSave.addAll(listToEmailAddress + listCcEmailAddress + listBccEmailAddress);
    _saveEmailAddressInteractor.execute(listEmailAddressCanSave.toList());
  }

  Future<List<EmailAddress>> searchEmailAddressSuggestion(String word) async {
    return await _searchEmailAddressInteractor.execute(AutoCompletePattern(word: word))
      .then((value) => value.fold(
        (failure) => [],
        (success) => success is SearchEmailAddressSuccess ? success.listEmailAddress : []));
  }

  void backToEmailViewAction() {
    Get.back();
  }
}