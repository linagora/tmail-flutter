
import 'dart:async';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:enough_html_editor/enough_html_editor.dart';
import 'package:file_picker/file_picker.dart';
import 'package:filesize/filesize.dart';
import 'package:fk_user_agent/fk_user_agent.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart' as html_editor_browser;
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
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/composer/domain/model/contact_suggestion_source.dart';
import 'package:tmail_ui_user/features/composer/domain/model/email_request.dart';
import 'package:tmail_ui_user/features/composer/domain/state/get_autocomplete_state.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_autocomplete_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/get_autocomplete_with_device_contact_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/state/upload_attachment_state.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/save_email_as_drafts_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/send_email_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/update_email_drafts_interactor.dart';
import 'package:tmail_ui_user/features/composer/domain/usecases/upload_mutiple_attachment_interactor.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/email_action_type_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/screen_display_mode.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_email_content_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_email_content_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/dashboard_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_all_identities_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_identities_interactor.dart';
import 'package:tmail_ui_user/features/upload/domain/state/local_file_picker_state.dart';
import 'package:tmail_ui_user/features/upload/domain/usecases/local_file_picker_interactor.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:uuid/uuid.dart';

class ComposerController extends BaseController {

  final mailboxDashBoardController = Get.find<MailboxDashBoardController>();
  final _appToast = Get.find<AppToast>();
  final _imagePaths = Get.find<ImagePaths>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();

  final expandModeAttachments = ExpandMode.COLLAPSE.obs;
  final composerArguments = Rxn<ComposerArguments>();
  final isEnableEmailSendButton = false.obs;
  final isInitialRecipient = false.obs;
  final attachments = <Attachment>[].obs;
  final emailContents = Rxn<List<EmailContent>>();
  final listEmailAddressType = <PrefixEmailAddress>[].obs;
  final subjectEmail = Rxn<String>();
  final screenDisplayMode = ScreenDisplayMode.normal.obs;
  final toAddressExpandMode = ExpandMode.EXPAND.obs;
  final ccAddressExpandMode = ExpandMode.EXPAND.obs;
  final bccAddressExpandMode = ExpandMode.EXPAND.obs;
  final identitySelected = Rxn<Identity>();
  final listIdentities = <Identity>[].obs;

  final SendEmailInteractor _sendEmailInteractor;
  final GetAutoCompleteInteractor _getAutoCompleteInteractor;
  final GetAutoCompleteWithDeviceContactInteractor _getAutoCompleteWithDeviceContactInteractor;
  final Uuid _uuid;
  final LocalFilePickerInteractor _localFilePickerInteractor;
  final UploadMultipleAttachmentInteractor _uploadMultipleAttachmentInteractor;
  final DeviceInfoPlugin _deviceInfoPlugin;
  final SaveEmailAsDraftsInteractor _saveEmailAsDraftsInteractor;
  final GetEmailContentInteractor _getEmailContentInteractor;
  final UpdateEmailDraftsInteractor _updateEmailDraftsInteractor;
  final GetAllIdentitiesInteractor _getAllIdentitiesInteractor;

  List<EmailAddress> listToEmailAddress = <EmailAddress>[];
  List<EmailAddress> listCcEmailAddress = <EmailAddress>[];
  List<EmailAddress> listBccEmailAddress = <EmailAddress>[];
  ContactSuggestionSource _contactSuggestionSource = ContactSuggestionSource.tMailContact;
  HtmlEditorApi? htmlEditorApi;
  final html_editor_browser.HtmlEditorController htmlControllerBrowser =
    html_editor_browser.HtmlEditorController(processNewLineAsBr: true);

  final subjectEmailInputController = TextEditingController();
  final toEmailAddressController = TextEditingController();
  final ccEmailAddressController = TextEditingController();
  final bccEmailAddressController = TextEditingController();

  List<Attachment> initialAttachments = <Attachment>[];
  String? _textEditorWeb;

  void setTextEditorWeb(String? text) => _textEditorWeb = text;

  String? get textEditorWeb => _textEditorWeb;

  void setSubjectEmail(String subject) => subjectEmail.value = subject;

  Future<String> _getEmailBodyText({bool changedEmail = false}) async {
    if (kIsWeb) {
      return await htmlControllerBrowser.getText();
    } else {
      if (changedEmail) {
        return await htmlEditorApi?.getText() ?? '';
      } else {
        final content = await htmlEditorApi?.getText() ?? '';
        if (_isMobileApp && identitySelected.value?.textSignature?.value.isNotEmpty == true) {
          final newContent = '$content<br><br><br>--<br><br><div>${identitySelected.value?.textSignature?.value}</div><br>';
          log('ComposerController::_generateEmail()_MOBILE: $newContent');
          return newContent;
        } else {
          return content;
        }
      }
    }
  }

  ComposerController(
    this._sendEmailInteractor,
    this._getAutoCompleteInteractor,
    this._getAutoCompleteWithDeviceContactInteractor,
    this._uuid,
    this._deviceInfoPlugin,
    this._localFilePickerInteractor,
    this._uploadMultipleAttachmentInteractor,
    this._saveEmailAsDraftsInteractor,
    this._getEmailContentInteractor,
    this._updateEmailDraftsInteractor,
    this._getAllIdentitiesInteractor,
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
    subjectEmailInputController.dispose();
    toEmailAddressController.dispose();
    ccEmailAddressController.dispose();
    bccEmailAddressController.dispose();
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
        } if (success is GetAllIdentitiesSuccess) {
          if (success.identities?.isNotEmpty == true) {
            listIdentities.value = success.identities ?? [];
            setIdentityDefault();
          }
        }
      });
  }

  @override
  void onError(error) {
    if (currentOverlayContext != null && currentContext != null) {
      _appToast.showToastWithIcon(
          currentOverlayContext!,
          textColor: AppColor.toastErrorBackgroundColor,
          message: AppLocalizations.of(currentContext!).message_has_been_sent_failure,
          icon: _imagePaths.icSendToast);
    }
    popBack();
  }
  
  void _initEmail() {
    final arguments = kIsWeb ? mailboxDashBoardController.routerArguments : Get.arguments;
    if (arguments is ComposerArguments) {
      composerArguments.value = arguments;
      if (arguments.emailActionType == EmailActionType.edit) {
        _getEmailContentAction(arguments);
      }
      _initToEmailAddress(arguments);
      _initSubjectEmail(arguments);
      _initAttachments(arguments);
    }
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
    attachments.value = arguments.attachments ?? [];
    initialAttachments = arguments.attachments ?? [];
  }

  void _getAllIdentities() {
    final accountId = mailboxDashBoardController.accountId.value;
    if (accountId != null) {
      consumeState(_getAllIdentitiesInteractor.execute(accountId));
    }
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

  void setFullScreenEditor() {
    htmlControllerBrowser.setFullScreen();
  }

  String? _getHeaderEmailQuoted(BuildContext context, ComposerArguments arguments) {
    final presentationEmail = arguments.presentationEmail;
    if (presentationEmail != null) {
      final locale = Localizations.localeOf(context).toLanguageTag();
      log('ComposerController::_getHeaderEmailQuoted(): emailActionType: ${arguments.emailActionType}');
      switch(arguments.emailActionType) {
        case EmailActionType.reply:
        case EmailActionType.replyAll:
          final sentDate = presentationEmail.sentAt;
          final emailAddress = presentationEmail.from.listEmailAddressToString(isFullEmailAddress: true);
          return AppLocalizations.of(context).header_email_quoted(
              sentDate.formatDate(pattern: 'MMM d, y h:mm a', locale: locale),
              emailAddress);
        case EmailActionType.forward:
          var headerQuoted = '------- ${AppLocalizations.of(context).forwarded_message} -------'.addNewLineTag();

          final subject = presentationEmail.subject ?? '';
          final sentDate = presentationEmail.sentAt;
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
          if (sentDate != null) {
            headerQuoted = headerQuoted
                .append('${AppLocalizations.of(context).date}: ')
                .append(sentDate.formatDate(pattern: 'MMM d, y h:mm a', locale: locale))
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

  void _initToEmailAddress(ComposerArguments arguments) {
    final userProfile =  mailboxDashBoardController.userProfile.value;
    if (arguments.presentationEmail != null && userProfile != null) {
      final userEmailAddress = EmailAddress(null, userProfile.email);

      final recipients = arguments.presentationEmail!.generateRecipientsEmailAddressForComposer(
          arguments.emailActionType,
          arguments.mailboxRole);

      if (arguments.mailboxRole == PresentationMailbox.roleSent
          || arguments.emailActionType == EmailActionType.edit) {
        listToEmailAddress = recipients.value1;
        listCcEmailAddress = recipients.value2;
        listBccEmailAddress = recipients.value3;
      } else {
        listToEmailAddress = recipients.value1.toSet().filterEmailAddress(userEmailAddress);
        listCcEmailAddress = recipients.value2.toSet().filterEmailAddress(userEmailAddress);
        listBccEmailAddress = recipients.value3.toSet().filterEmailAddress(userEmailAddress);
      }

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

  void updateListEmailAddress(PrefixEmailAddress prefixEmailAddress,
      List<EmailAddress> newListEmailAddress) {
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
    final emailQuotedHtml = '<p></br></p>$headerEmailQuotedAsHtml${trustAsHtml.addBlockQuoteTag()}</br></br></br>';

    return emailQuotedHtml;
  }

  Future<Email> _generateEmail(Map<Role, MailboxId> mapDefaultMailboxId,
      UserProfile userProfile, {bool asDrafts = false}) async {
    final generateEmailId = EmailId(Id(_uuid.v1()));
    final outboxMailboxId = mapDefaultMailboxId[PresentationMailbox.roleOutbox];
    final draftMailboxId = mapDefaultMailboxId[PresentationMailbox.roleDrafts];
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
    final generatePartId = PartId(_uuid.v1());
    final generateBlobId = Id(_uuid.v1());

    var emailBodyText = await _getEmailBodyText();
    log('ComposerController::_generateEmail(): $emailBodyText');
    final userAgent = await userAgentPlatform;

    return Email(
      generateEmailId,
      mailboxIds: asDrafts ? {draftMailboxId!: true} : {outboxMailboxId!: true},
      from: listFromEmailAddress,
      to: listToEmailAddress.toSet(),
      cc: listCcEmailAddress.toSet(),
      bcc: listBccEmailAddress.toSet(),
      replyTo: listReplyToEmailAddress,
      keywords: asDrafts ? {KeyWordIdentifier.emailDraft : true} : null,
      subject: subjectEmail.value,
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
    clearFocusEditor(context);

    if (!isEnableEmailSendButton.value) {
      showConfirmDialogAction(context,
          AppLocalizations.of(context).message_dialog_send_email_without_recipient,
          AppLocalizations.of(context).add_recipients,
          () => {},
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
          () {
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
          () => _handleSendMessages(context),
          title: AppLocalizations.of(context).empty_subject,
          icon: SvgPicture.asset(_imagePaths.icEmpty, fit: BoxFit.fill),
      );
      return;
    }

    if (!_validateAttachmentsSize()) {
      showConfirmDialogAction(
          context,
          AppLocalizations.of(context).message_dialog_send_email_exceeds_maximum_size(
              filesize(mailboxDashBoardController.maxSizeAttachmentsPerEmail?.value ?? 0, 0)),
          AppLocalizations.of(context).got_it,
          () => {},
          title: AppLocalizations.of(context).sending_failed,
          icon: SvgPicture.asset(_imagePaths.icSendToastError, fit: BoxFit.fill),
          hasCancelButton: false);
      return;
    }

    _handleSendMessages(context);
  }

  void _handleSendMessages(BuildContext context) async {
    final arguments = composerArguments.value;
    final session = mailboxDashBoardController.sessionCurrent;
    final mapDefaultMailboxId = mailboxDashBoardController.mapDefaultMailboxId;
    final userProfile = mailboxDashBoardController.userProfile.value;
    if (arguments != null && session != null && mapDefaultMailboxId.isNotEmpty
        && userProfile != null) {

      final email = await _generateEmail(mapDefaultMailboxId, userProfile);
      final accountId = session.accounts.keys.first;
      final sentMailboxId = mapDefaultMailboxId[PresentationMailbox.roleSent];
      final submissionCreateId = Id(_uuid.v1());

      mailboxDashBoardController.consumeState(_sendEmailInteractor.execute(
        accountId,
        EmailRequest(email, submissionCreateId, mailboxIdSaved: sentMailboxId,
          emailIdDestroyed: arguments.emailActionType == EmailActionType.edit
            ? arguments.presentationEmail?.id
            : null)));
    }

    if (kIsWeb) {
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

  Future<List<EmailAddress>> getAutoCompleteSuggestion(
      {required String word}) async {
    if (_contactSuggestionSource == ContactSuggestionSource.all) {
      return await _getAutoCompleteWithDeviceContactInteractor
        .execute(AutoCompletePattern(word: word, accountId: mailboxDashBoardController.accountId.value))
        .then((value) => value.fold(
          (failure) => <EmailAddress>[],
          (success) => success is GetAutoCompleteSuccess ? success.listEmailAddress : <EmailAddress>[]));
    }
    return await _getAutoCompleteInteractor
      .execute(AutoCompletePattern(word: word, accountId: mailboxDashBoardController.accountId.value))
      .then((value) => value.fold(
        (failure) => <EmailAddress>[],
        (success) => success is GetAutoCompleteSuccess ? success.listEmailAddress : <EmailAddress>[]));
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
      if (currentContext != null) {
        _appToast.showErrorToast(AppLocalizations.of(currentContext!).can_not_upload_this_file_as_attachments);
      }
    }
  }

  void _pickFileSuccess(Success success) {
    if (success is LocalFilePickerSuccess) {
      if (_validateAttachmentsSize(listFiles: success.pickedFiles)) {
        _uploadAttachmentsAction(success.pickedFiles);
      } else {
        if (currentContext != null) {
          showConfirmDialogAction(
              currentContext!,
              AppLocalizations.of(currentContext!).message_dialog_upload_attachments_exceeds_maximum_size(
                  filesize(mailboxDashBoardController.maxSizeAttachmentsPerEmail?.value ?? 0, 0)),
              AppLocalizations.of(currentContext!).got_it,
              () => {},
              title: AppLocalizations.of(currentContext!).maximum_files_size,
              hasCancelButton: false);
        }
      }
    }
  }

  bool _validateAttachmentsSize({List<FileInfo>? listFiles}) {
    final currentTotalAttachmentsSize = attachments.totalSize();
    log('ComposerController::_validateAttachmentsSize(): $currentTotalAttachmentsSize');
    num uploadedTotalSize = 0;
    if (listFiles != null && listFiles.isNotEmpty) {
      final uploadedListSize = listFiles.map((file) => file.fileSize).toList();
      uploadedTotalSize = uploadedListSize.reduce((sum, size) => sum + size);
      log('ComposerController::_validateAttachmentsSize(): uploadedTotalSize: $uploadedTotalSize');
    }

    final totalSizeReadyToUpload = currentTotalAttachmentsSize + uploadedTotalSize;
    log('ComposerController::_validateAttachmentsSize(): totalSizeReadyToUpload: $totalSizeReadyToUpload');

    final maxSizeAttachmentsPerEmail = mailboxDashBoardController.maxSizeAttachmentsPerEmail?.value;
    if (maxSizeAttachmentsPerEmail != null) {
      return totalSizeReadyToUpload <= maxSizeAttachmentsPerEmail;
    } else {
      return false;
    }
  }

  void _uploadAttachmentsAction(List<FileInfo> pickedFiles) async {
    final session = mailboxDashBoardController.sessionCurrent;
    if (session != null) {
      final accountId = session.accounts.keys.first;
      final uploadUrl = session.getUploadUrl(accountId);
      consumeState(_uploadMultipleAttachmentInteractor.execute(pickedFiles, accountId, uploadUrl));
    }
  }

  void _uploadAttachmentsFailure(Failure failure) {
    if (currentContext != null) {
      _appToast.showErrorToast(AppLocalizations.of(currentContext!).can_not_upload_this_file_as_attachments);
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
    if (currentContext != null) {
      _appToast.showSuccessToast(AppLocalizations.of(currentContext!).attachments_uploaded_successfully);
    }
  }

  void removeAttachmentAction(Attachment attachmentRemoved) {
    attachments.removeWhere((attachment) => attachment == attachmentRemoved);
  }

  Future<bool> _isEmailChanged(BuildContext context, ComposerArguments arguments) async {
    final newEmailBody = (await _getEmailBodyText(changedEmail: true))
        .replaceAll('<p><br><br><br></p>', '');
    log('ComposerController::_isEmailChanged(): newEmailBody: $newEmailBody');
    var oldEmailBody = '';
    final contentEmail = getContentEmail(context);
    if (arguments.emailActionType != EmailActionType.compose && contentEmail != null && contentEmail.isNotEmpty) {
      oldEmailBody = kIsWeb ? contentEmail : '\n$contentEmail\n';
    }
    log('ComposerController::_isEmailChanged(): oldEmailBody: $oldEmailBody');
    final isEmailBodyChanged = !oldEmailBody.trim().isSame(newEmailBody.trim());
    log('ComposerController::_isEmailChanged(): isEmailBodyChanged: $isEmailBodyChanged');

    final newEmailSubject = subjectEmail.value;
    final titleEmail = arguments.presentationEmail?.getEmailTitle().trim() ?? '';
    final oldEmailSubject = arguments.emailActionType.getSubjectComposer(currentContext!, titleEmail);
    final isEmailSubjectChanged = !oldEmailSubject.isSame(newEmailSubject);

    final recipients = arguments.presentationEmail
        ?.generateRecipientsEmailAddressForComposer(arguments.emailActionType, arguments.mailboxRole)
        ?? const Tuple3(<EmailAddress>[], <EmailAddress>[], <EmailAddress>[]);

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

  void saveEmailAsDrafts(BuildContext context) async {
    clearFocusEditor(context);

    final arguments = composerArguments.value;
    final mapDefaultMailboxId = mailboxDashBoardController.mapDefaultMailboxId;
    final userProfile = mailboxDashBoardController.userProfile.value;
    final session = mailboxDashBoardController.sessionCurrent;

    if (arguments != null && mapDefaultMailboxId.isNotEmpty && userProfile != null && session != null) {
      log('ComposerController::saveEmailAsDrafts(): saveEmailAsDrafts START');
      final isChanged = await _isEmailChanged(context, arguments);
      if (isChanged) {
        log('ComposerController::saveEmailAsDrafts(): saveEmailAsDrafts isChanged: $isChanged');
        final newEmail = await _generateEmail(mapDefaultMailboxId, userProfile, asDrafts: true);
        final accountId = session.accounts.keys.first;
        final oldEmail = arguments.presentationEmail;

        if (arguments.emailActionType == EmailActionType.edit && oldEmail != null) {
          mailboxDashBoardController.consumeState(
              _updateEmailDraftsInteractor.execute(accountId, newEmail, oldEmail.id));
        } else {
          mailboxDashBoardController.consumeState(
              _saveEmailAsDraftsInteractor.execute(accountId, newEmail));
        }
      }
    }
  }

  void _getEmailContentAction(ComposerArguments arguments) async {
    final baseDownloadUrl = mailboxDashBoardController.sessionCurrent?.getDownloadUrl();
    final accountId = mailboxDashBoardController.sessionCurrent?.accounts.keys.first;
    final emailId = arguments.presentationEmail?.id;
    if (emailId != null && baseDownloadUrl != null && accountId != null) {
      consumeState(_getEmailContentInteractor.execute(accountId, emailId, baseDownloadUrl));
    }
  }

  void _getEmailContentSuccess(GetEmailContentSuccess success) {
    emailContents.value = success.emailContents;
    attachments.value = success.attachments;
    initialAttachments = success.attachments;
  }

  String? getEmailContentDraftsAsHtml() {
    final listContents = emailContents.value;
    if (listContents != null) {
      return listContents.asHtmlString;
    } else {
      return null;
    }
  }

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
      htmlEditorApi?.unfocus(context);
      htmlControllerBrowser.clearFocus();
    }
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void closeComposerWeb() {
    FocusManager.instance.primaryFocus?.unfocus();
    mailboxDashBoardController.dispatchAction(CloseComposeEmailAction());
  }

  void displayScreenTypeComposerAction(ScreenDisplayMode displayMode) {
    FocusManager.instance.primaryFocus?.unfocus();
    _updateTextForEditor();
    screenDisplayMode.value = displayMode;
  }

  void _updateTextForEditor() async {
    final textCurrent = await htmlControllerBrowser.getText();
    htmlControllerBrowser.setText(textCurrent);
  }

  void deleteComposer() {
    FocusManager.instance.primaryFocus?.unfocus();
    mailboxDashBoardController.dispatchAction(CloseComposeEmailAction());
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

  void onSubjectEmailFocusChange(bool isFocus) {
    log('ComposerController::onSubjectEmailFocusChange(): Focus: $isFocus');
    if (isFocus) {
      toAddressExpandMode.value = ExpandMode.COLLAPSE;
      ccAddressExpandMode.value = ExpandMode.COLLAPSE;
      bccAddressExpandMode.value = ExpandMode.COLLAPSE;
    }
  }

  void onEditorFocusChange(bool isFocus) {
    log('ComposerController::onEditorFocusChange(): Focus: $isFocus');
    if (isFocus) {
      toAddressExpandMode.value = ExpandMode.COLLAPSE;
      ccAddressExpandMode.value = ExpandMode.COLLAPSE;
      bccAddressExpandMode.value = ExpandMode.COLLAPSE;
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
    }
  }

  void setIdentityDefault() {
    try {
      final identityDefault = listIdentities.firstWhere((identity) => identity.mayDelete == false);
      selectIdentity(identityDefault);
    } catch (exception) {
      selectIdentity(listIdentities.first);
    }
  }

  void selectIdentity(Identity? newIdentity) {
    final formerIdentity = identitySelected.value;
    identitySelected.value = newIdentity;
    if (newIdentity != null) {
      _applyIdentityForAllFieldComposer(formerIdentity, newIdentity);
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  bool get _isMobileApp {
    return !BuildUtils.isWeb
        && currentContext != null
        && _responsiveUtils.isMobile(currentContext!);
  }

  void _applyIdentityForAllFieldComposer(Identity? formerIdentity, Identity newIdentity) {
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
      _applyBccEmailAddressFromIdentity(newIdentity.bcc!);
    }

    if (!_isMobileApp) {
      if (newIdentity.htmlSignature?.value.isNotEmpty == true) {
        _applySignature(newIdentity.htmlSignature!);
      } else if (newIdentity.textSignature?.value.isNotEmpty == true) {
        _applySignature(newIdentity.textSignature!);
      }
    }
  }

  void _applyBccEmailAddressFromIdentity(Set<EmailAddress> listEmailAddress) {
    if (!listEmailAddressType.contains(PrefixEmailAddress.bcc)) {
      listEmailAddressType.add(PrefixEmailAddress.bcc);
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
      listEmailAddressType.remove(PrefixEmailAddress.bcc);
    }
    toAddressExpandMode.value = ExpandMode.COLLAPSE;
    ccAddressExpandMode.value = ExpandMode.COLLAPSE;
    bccAddressExpandMode.value = ExpandMode.COLLAPSE;
    _updateStatusEmailSendButton();
  }

  void _applySignature(Signature signature) {
    final signatureAsHtml = '--<br><br>${signature.value}';
    log('ComposerController::_applySignature(): $signatureAsHtml');
    if (BuildUtils.isWeb) {
      htmlControllerBrowser.insertSignature(signatureAsHtml);
    } else {
      htmlEditorApi?.insertSignature(signatureAsHtml);
    }
  }

  void _removeSignature() {
    log('ComposerController::_removeSignature():');
    if (BuildUtils.isWeb) {
      htmlControllerBrowser.removeSignature();
    } else {
      htmlEditorApi?.removeSignature();
    }
  }

  void closeComposer() {
    FocusManager.instance.primaryFocus?.unfocus();
    popBack();
  }
}