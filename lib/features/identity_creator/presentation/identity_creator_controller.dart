
import 'package:core/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
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
import 'package:tmail_ui_user/features/manage_account/domain/state/get_all_identities_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_identities_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/identity_action_type.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class IdentityCreatorController extends BaseController {

  final VerifyNameInteractor _verifyNameInteractor;
  final GetAllIdentitiesInteractor _getAllIdentitiesInteractor;

  final noneEmailAddress = EmailAddress(null, 'None');
  final signatureType = SignatureType.plainText.obs;
  final listEmailAddressDefault = <EmailAddress>[].obs;
  final listEmailAddressOfReplyTo = <EmailAddress>[].obs;
  final errorNameIdentity = Rxn<String>();
  final emailOfIdentity = Rxn<EmailAddress>();
  final replyToOfIdentity = Rxn<EmailAddress>();
  final bccOfIdentity = Rxn<EmailAddress>();
  final actionType = IdentityActionType.create.obs;

  final HtmlEditorController signatureHtmlEditorController = HtmlEditorController(processNewLineAsBr: true);
  final TextEditingController signaturePlainEditorController = TextEditingController();
  final TextEditingController inputNameIdentityController = TextEditingController();
  final FocusNode inputNameIdentityFocusNode = FocusNode();

  AccountId? accountId;
  UserProfile? userProfile;
  Identity? identity;
  String? _nameIdentity;
  String? _contentHtmlEditor;

  void updateNameIdentity(BuildContext context, String? value) {
    _nameIdentity = value;
    errorNameIdentity.value = _getErrorInputNameString(context);
  }

  void updateContentHtmlEditor(String? text) => _contentHtmlEditor = text;

  String? get contentHtmlEditor => _contentHtmlEditor;

  IdentityCreatorController(
      this._verifyNameInteractor,
      this._getAllIdentitiesInteractor
  );

  @override
  void onReady() {
    _getArguments();
    _getAllIdentities();
    if (actionType.value == IdentityActionType.edit && identity != null) {
      _setUpValueFromIdentity();
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
    viewState.value.fold(
        (failure) {
          if (failure is GetAllIdentitiesFailure) {
            _getALlIdentitiesFailure(failure);
          }
        },
        (success) {
          if (success is GetAllIdentitiesSuccess) {
            _getALlIdentitiesSuccess(success);
          }
        }
    );
  }

  @override
  void onError(error) {}

  void _getArguments() {
    final arguments = Get.arguments;
    if (arguments is IdentityCreatorArguments) {
      accountId = arguments.accountId;
      userProfile = arguments.userProfile;
      actionType.value = arguments.actionType;
      identity = arguments.identity;
    }
  }

  void _setUpValueFromIdentity() {
    _nameIdentity = identity?.name ?? '';
    inputNameIdentityController.text = identity?.name ?? '';

    if (identity?.textSignature?.value.isNotEmpty == true) {
      signaturePlainEditorController.text = identity?.textSignature?.value ?? '';
    }

    if (identity?.htmlSignature?.value.isNotEmpty == true) {
      updateContentHtmlEditor(identity?.htmlSignature?.value ?? '');
      signatureHtmlEditorController.setText(identity?.htmlSignature?.value ?? '');
    }
  }

  void _getAllIdentities() {
    if (accountId != null) {
      consumeState(_getAllIdentitiesInteractor.execute(
        accountId!,
        properties: Properties({'email'})
      ));
    }
  }

  void _getALlIdentitiesSuccess(GetAllIdentitiesSuccess success) {
    if (success.identities?.isNotEmpty == true) {
      listEmailAddressDefault.value = success.identities
          !.map((identity) => identity.toEmailAddressNoName())
          .toSet()
          .toList();
      listEmailAddressOfReplyTo.add(noneEmailAddress);
      listEmailAddressOfReplyTo.addAll(listEmailAddressDefault);

      _setUpAllFieldEmailAddress();
    } else {
      _setDefaultEmailAddressList();
    }
  }

  void _getALlIdentitiesFailure(GetAllIdentitiesFailure failure) {
    _setDefaultEmailAddressList();
  }

  void _setDefaultEmailAddressList() {
    listEmailAddressOfReplyTo.add(noneEmailAddress);

    if (userProfile != null && userProfile?.email.isNotEmpty == true) {
      final userEmailAddress = EmailAddress(null, userProfile!.email);
      listEmailAddressDefault.add(userEmailAddress);
      listEmailAddressOfReplyTo.addAll(listEmailAddressDefault);
    }

    _setUpAllFieldEmailAddress();
  }

  void _setUpAllFieldEmailAddress() {
    if (actionType.value == IdentityActionType.edit && identity != null) {
      replyToOfIdentity.value = identity?.replyTo?.isNotEmpty == true
          ? identity!.replyTo!.first
          : noneEmailAddress;

      bccOfIdentity.value = identity?.bcc?.isNotEmpty == true
          ? identity!.bcc!.first
          : noneEmailAddress;

      if (identity?.email?.isNotEmpty == true) {
        emailOfIdentity.value = EmailAddress(null, identity?.email!);
      } else {
        emailOfIdentity.value = listEmailAddressDefault.isNotEmpty
            ? listEmailAddressDefault.first
            : null;
      }
    } else {
      replyToOfIdentity.value = noneEmailAddress;
      bccOfIdentity.value = noneEmailAddress;
      emailOfIdentity.value = listEmailAddressDefault.isNotEmpty
          ? listEmailAddressDefault.first
          : null;
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