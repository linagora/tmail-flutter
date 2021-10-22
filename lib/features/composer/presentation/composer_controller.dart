
import 'dart:async';

import 'package:core/core.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:dartz/dartz.dart';
import 'package:enough_html_editor/enough_html_editor.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_chips_input/flutter_chips_input.dart';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
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
import 'package:tmail_ui_user/features/composer/domain/usecases/save_email_addresses_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/send_email_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/upload_mutiple_attachment_interactor.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/email_action_type_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/upload/domain/state/local_file_picker_state.dart';
import 'package:tmail_ui_user/features/upload/domain/usecases/local_file_picker_interactor.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:uuid/uuid.dart';

class ComposerController extends BaseController {

  final mailboxDashBoardController = Get.find<MailboxDashBoardController>();
  
  final expandMode = ExpandMode.COLLAPSE.obs;
  final composerArguments = Rxn<ComposerArguments>();
  final isEnableEmailSendButton = false.obs;
  final attachments = <Attachment>[].obs;

  final SendEmailInteractor _sendEmailInteractor;
  final SaveEmailAddressesInteractor _saveEmailAddressInteractor;
  final GetAutoCompleteInteractor _getAutoCompleteInteractor;
  final GetAutoCompleteWithDeviceContactInteractor _getAutoCompleteWithDeviceContactInteractor;
  final AppToast _appToast;
  final Uuid _uuid;
  final TextEditingController subjectEmailInputController;
  final LocalFilePickerInteractor _localFilePickerInteractor;
  final UploadMultipleAttachmentInteractor _uploadMultipleAttachmentInteractor;

  List<EmailAddress> listToEmailAddress = [];
  List<EmailAddress> listCcEmailAddress = [];
  List<EmailAddress> listBccEmailAddress = [];
  String? _subjectEmail;
  ContactSuggestionSource _contactSuggestionSource = ContactSuggestionSource.localContact;
  HtmlEditorApi? htmlEditorApi;
  final keyToEmailAddress = GlobalKey<ChipsInputState>();
  final keyCcEmailAddress = GlobalKey<ChipsInputState>();
  final keyBccEmailAddress = GlobalKey<ChipsInputState>();

  void setSubjectEmail(String subject) => _subjectEmail = subject;

  ComposerController(
    this._sendEmailInteractor,
    this._saveEmailAddressInteractor,
    this._getAutoCompleteInteractor,
    this._getAutoCompleteWithDeviceContactInteractor,
    this._appToast,
    this._uuid,
    this.subjectEmailInputController,
    this._localFilePickerInteractor,
    this._uploadMultipleAttachmentInteractor,
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
    if (Get.context != null) {
      final subjectEmail = composerArguments.value?.presentationEmail?.getEmailTitle().trim() ?? '';
      final newSubject = composerArguments.value?.emailActionType.getSubjectComposer(Get.context!, subjectEmail) ?? '';
      setSubjectEmail(newSubject);
      subjectEmailInputController.text = newSubject;
    }
  }

  String getContentEmail() {
    if (composerArguments.value != null
        && composerArguments.value!.emailActionType != EmailActionType.compose
        && Get.context != null) {
      final contentEmailQuoted = _getBodyEmailQuotedAsHtml(Get.context!);
      return contentEmailQuoted;
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

  void expandEmailAddressAction() {
    final newExpandMode = expandMode.value == ExpandMode.COLLAPSE ? ExpandMode.EXPAND : ExpandMode.COLLAPSE;
    expandMode.value = newExpandMode;
  }

  void _initToEmailAddress() {
    if (composerArguments.value != null && composerArguments.value?.presentationEmail != null) {
      final userEmailAddress = EmailAddress(null, composerArguments.value!.userProfile.email);

      final recipients = composerArguments.value!.presentationEmail!.generateRecipientsEmailAddressForComposer(
        composerArguments.value?.emailActionType,
        composerArguments.value?.mailboxRole);

      if (composerArguments.value?.mailboxRole == PresentationMailbox.roleSent) {
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

      if (listToEmailAddress.isNotEmpty) {
        keyToEmailAddress.currentState?.addMultipleValue(listToEmailAddress);
      }

      if (listCcEmailAddress.isNotEmpty) {
        keyCcEmailAddress.currentState?.addMultipleValue(listCcEmailAddress);
      }

      if (listBccEmailAddress.isNotEmpty) {
        keyBccEmailAddress.currentState?.addMultipleValue(listBccEmailAddress);
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

  String _getBodyEmailQuotedAsHtml(BuildContext context) {
    final headerEmailQuoted = getHeaderEmailQuoted(Localizations.localeOf(context).toLanguageTag());

    final headerEmailQuotedAsHtml = headerEmailQuoted != null
      ? AppLocalizations.of(context).header_email_quoted(headerEmailQuoted.value1, headerEmailQuoted.value2)
          .addBlockTag('p', attribute: 'style=\"font-size:14px;font-style:italic;color:#182952;\"')
      : '';

    final trustAsHtml = composerArguments.value?.emailContents
      ?.map((emailContent) => emailContent.content)
      .toList()
      .join('</br>') ?? '';

    final emailQuotedHtml = '</br></br></br>$headerEmailQuotedAsHtml${trustAsHtml.addBlockQuoteTag()}</br>';

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

    final emailBodyText = (await htmlEditorApi?.getFullHtml()) ?? '';

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
          type: MediaType.parse('text/html')
        )},
      bodyValues: {
        generatePartId: EmailBodyValue(emailBodyText, false, false)
      },
      attachments: attachments.isNotEmpty ? _generateAttachments() : null
    );
  }

  Set<EmailBodyPart> _generateAttachments() {
    return attachments.map((attachment) =>
      attachment.toEmailBodyPart(ContentDisposition.attachment.value)).toSet();
  }

  void sendEmailAction(BuildContext context) async {
    if (isEnableEmailSendButton.value) {
      _saveEmailAddress();

      final email = await generateEmail();
      final accountId = composerArguments.value!.session.accounts.keys.first;
      final sentMailboxId = composerArguments.value!.mapMailboxId[PresentationMailbox.roleSent];
      final submissionCreateId = Id(_uuid.v1());

      mailboxDashBoardController.consumeState(_sendEmailInteractor.execute(
          accountId,
          EmailRequest(email, submissionCreateId, mailboxIdSaved: sentMailboxId)));

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

  void backToEmailViewAction() {
    popBack();
  }
}