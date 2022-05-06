
import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/model/identity_creator_arguments.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/model/signature_type.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/empty_name_validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/state/verify_name_view_state.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/extensions/validator_failure_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/identity_action_type.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class IdentityCreatorController extends BaseController {

  final VerifyNameInteractor _verifyNameInteractor;

  final noneEmailAddress = EmailAddress(null, 'None');
  final signatureType = SignatureType.plainText.obs;
  final listEmailAddressDefault = <EmailAddress>[].obs;
  final listEmailAddressOfReplyTo = <EmailAddress>[].obs;
  final errorNameIdentity = Rxn<String>();
  final emailOfIdentity = Rxn<EmailAddress>();
  final replyToOfIdentity = Rxn<EmailAddress>();
  final bccOfIdentity = Rxn<EmailAddress>();

  final HtmlEditorController signatureHtmlEditorController = HtmlEditorController(processNewLineAsBr: true);
  final TextEditingController signaturePlainEditorController = TextEditingController();
  final TextEditingController inputNameIdentityController = TextEditingController();
  final FocusNode inputNameIdentityFocusNode = FocusNode();

  AccountId? accountId;
  UserProfile? userProfile;
  IdentityActionType? actionType;
  Identity? identity;
  String? _nameIdentity;
  String? _contentHtmlEditor;

  void updateNameIdentity(BuildContext context, String? value) {
    _nameIdentity = value;
    errorNameIdentity.value = _getErrorInputNameString(context);
  }

  void updateContentHtmlEditor(String? text) => _contentHtmlEditor = text;

  String? get contentHtmlEditor => _contentHtmlEditor;

  IdentityCreatorController(this._verifyNameInteractor);

  @override
  void onReady() {
    _getArguments();
    if (actionType == IdentityActionType.edit && identity != null) {
      _setUpValueFromIdentity();
    } else {
      _setDefaultValueForIdentity();
    }
    super.onReady();
  }

  @override
  void onClose() {
    signaturePlainEditorController.dispose();
    inputNameIdentityFocusNode.dispose();
    inputNameIdentityController.dispose();
    super.onClose();
  }

  @override
  void onDone() {
  }

  @override
  void onError(error) {}

  void _getArguments() {
    final arguments = Get.arguments;
    if (arguments is IdentityCreatorArguments) {
      accountId = arguments.accountId;
      userProfile = arguments.userProfile;
      actionType = arguments.actionType;
      identity = arguments.identity;
    }
  }

  void _setDefaultValueForIdentity() {
    listEmailAddressOfReplyTo.add(noneEmailAddress);
    bccOfIdentity.value = noneEmailAddress;
    replyToOfIdentity.value = noneEmailAddress;

    if (userProfile != null && userProfile?.email.isNotEmpty == true) {
      final userEmailAddress = EmailAddress(null, userProfile!.email);
      listEmailAddressDefault.add(userEmailAddress);
      listEmailAddressOfReplyTo.add(userEmailAddress);
      emailOfIdentity.value = userEmailAddress;
    }
  }

  void _setUpValueFromIdentity() {
    Set<EmailAddress> listEmailAddress = {};
    listEmailAddress.add(noneEmailAddress);

    _nameIdentity = identity?.name ?? '';
    inputNameIdentityController.text = identity?.name ?? '';

    if (identity?.replyTo?.isNotEmpty == true) {
      replyToOfIdentity.value = identity!.replyTo!.first;
      listEmailAddress.add(identity!.replyTo!.first);
    } else {
      replyToOfIdentity.value = noneEmailAddress;
    }

    if (identity?.bcc?.isNotEmpty == true) {
      bccOfIdentity.value = identity!.bcc!.first;
      listEmailAddress.add(identity!.bcc!.first);
    } else {
      bccOfIdentity.value = noneEmailAddress;
    }

    if (identity?.email?.isNotEmpty == true) {
      emailOfIdentity.value = EmailAddress(null, identity?.email!);
      listEmailAddress.add(EmailAddress(null, identity?.email!));
    }

    listEmailAddressOfReplyTo.value = listEmailAddress.toList();
    listEmailAddressDefault.value = listEmailAddress
        .where((emailAddress) => emailAddress != noneEmailAddress)
        .toList();

    if (identity?.textSignature?.value.isNotEmpty == true) {
      signaturePlainEditorController.text = identity?.textSignature?.value ?? '';
    }

    if (identity?.htmlSignature?.value.isNotEmpty == true) {
      updateContentHtmlEditor(identity?.htmlSignature?.value ?? '');
      signatureHtmlEditorController.setText(identity?.htmlSignature?.value ?? '');
    }
  }

  void selectSignatureType(SignatureType newSignatureType) {
    signatureType.value = newSignatureType;
  }

  void updateEmailOfIdentity(EmailAddress? newEmailAddress) {
    emailOfIdentity.value = newEmailAddress;
  }

  void updaterReplyToOfIdentity(EmailAddress? newEmailAddress) {
    replyToOfIdentity.value = newEmailAddress;
  }

  void updateBccOfIdentity(EmailAddress? newEmailAddress) {
    bccOfIdentity.value = newEmailAddress;
  }

  void createNewIdentity(BuildContext context) async {
    final error = _getErrorInputNameString(context);
    if (error?.isNotEmpty == true) {
      log('IdentityCreatorController::createNewIdentity(): error: $error');
      errorNameIdentity.value = error;
      return;
    }

    final newIdentity = Identity(
      name: _nameIdentity,
      email: emailOfIdentity.value?.email,
      replyTo: replyToOfIdentity.value != null && replyToOfIdentity.value != noneEmailAddress
          ? {replyToOfIdentity.value!}
          : null,
      bcc: bccOfIdentity.value != null && bccOfIdentity.value != noneEmailAddress
          ? {bccOfIdentity.value!}
          : null,
      textSignature: Signature(signaturePlainEditorController.text),
      htmlSignature: Signature(contentHtmlEditor ?? ''));

    log('IdentityCreatorController::createNewIdentity(): $newIdentity');

    _clearAll();
    FocusScope.of(context).unfocus();
    popBack(result: newIdentity);
  }

  String? _getErrorInputNameString(BuildContext context) {
    return _verifyNameInteractor.execute(
        _nameIdentity,
        [EmptyNameValidator()]
    ).fold(
      (failure) {
          if (failure is VerifyNameFailure) {
            return failure.getMessageIdentity(context);
          } else {
            return null;
          }
        },
      (success) => null
    );
  }

  void _clearAll() {
    signaturePlainEditorController.clear();
    inputNameIdentityController.clear();
  }

  void closeView(BuildContext context) {
    _clearAll();
    FocusScope.of(context).unfocus();
    popBack();
  }
}