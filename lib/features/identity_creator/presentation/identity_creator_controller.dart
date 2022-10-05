
import 'package:core/core.dart';
import 'package:enough_html_editor/enough_html_editor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/model.dart';
import 'package:rich_text_composer/richtext_controller.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/model/signature_type.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/email_address_validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/empty_name_validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/state/verify_name_view_state.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/extensions/validator_failure_extension.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/create_new_identity_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/edit_identity_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_all_identities_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_identities_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/identity_action_type.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/identities/identities_controller.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:uuid/uuid.dart';

class IdentityCreatorController extends BaseController {

  final VerifyNameInteractor _verifyNameInteractor;
  final GetAllIdentitiesInteractor _getAllIdentitiesInteractor;

  final noneEmailAddress = EmailAddress(null, 'None');
  final signatureType = SignatureType.plainText.obs;
  final listEmailAddressDefault = <EmailAddress>[].obs;
  final listEmailAddressOfReplyTo = <EmailAddress>[].obs;
  final errorNameIdentity = Rxn<String>();
  final errorBccIdentity = Rxn<String>();
  final emailOfIdentity = Rxn<EmailAddress>();
  final replyToOfIdentity = Rxn<EmailAddress>();
  final bccOfIdentity = Rxn<EmailAddress>();
  final _uuid = Get.find<Uuid>();
  final _identitiesController = Get.find<IdentitiesController>();
  final _accountDashBoardController = Get.find<ManageAccountDashBoardController>();

  final RichTextController keyboardRichTextController = RichTextController();

  final HtmlEditorController signatureHtmlEditorController = HtmlEditorController(processNewLineAsBr: true);
  final TextEditingController signaturePlainEditorController = TextEditingController();
  final TextEditingController inputNameIdentityController = TextEditingController();
  final TextEditingController inputBccIdentityController = TextEditingController();
  final FocusNode inputNameIdentityFocusNode = FocusNode();

  late Worker identityCreatorIsActiveWorker;

  HtmlEditorApi? signatureHtmlEditorMobileController;
  AccountId? get accountId => _identitiesController.identityCreatorArguments.value!.accountId;
  UserProfile? get userProfile => _identitiesController.identityCreatorArguments.value!.userProfile;
  Identity? get identity => _identitiesController.identityCreatorArguments.value!.identity;
  IdentityActionType get actionType => _identitiesController.identityCreatorArguments.value!.actionType;
  String? _nameIdentity;
  String? _contentHtmlEditor;

  final ScrollController scrollController = ScrollController();

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
    _setUpValueFromIdentity();
    _getAllIdentities();
    _initWorker();
    super.onReady();
  }

  void _initWorker() {
    identityCreatorIsActiveWorker = ever(_accountDashBoardController.identityCreatorIsActive, (identityCreatorIsActive) {
      if (identityCreatorIsActive == true) {
        if (actionType == IdentityActionType.edit && identity != null) {
          _setUpValueFromIdentity();
          _setUpAllFieldEmailAddress();
        }
      }
    });
  }

  @override
  void onClose() {
    signaturePlainEditorController.dispose();
    inputNameIdentityFocusNode.dispose();
    inputNameIdentityController.dispose();
    inputBccIdentityController.dispose();
    identityCreatorIsActiveWorker.dispose();
    keyboardRichTextController.dispose();
    scrollController.dispose();
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

      log('IdentityCreatorController::_getALlIdentitiesSuccess(): listEmailAddressOfReplyTo: ${listEmailAddressOfReplyTo.toJson()}');

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
    if (actionType == IdentityActionType.edit && identity != null) {
      if (identity?.replyTo?.isNotEmpty == true) {
        try {
          replyToOfIdentity.value = listEmailAddressOfReplyTo
              .firstWhere((emailAddress) => emailAddress ==  identity?.replyTo!.first);
        } catch(e) {
          replyToOfIdentity.value = noneEmailAddress;
        }
      } else {
        replyToOfIdentity.value = noneEmailAddress;
      }
      log('IdentityCreatorController::_setUpAllFieldEmailAddress(): replyToOfIdentity: ${replyToOfIdentity.value}');

      if (identity?.bcc?.isNotEmpty == true) {
        bccOfIdentity.value = identity?.bcc!.first;
        inputBccIdentityController.text = identity?.bcc!.first.emailAddress ?? '';
      } else {
        bccOfIdentity.value = null;
      }

      log('IdentityCreatorController::_setUpAllFieldEmailAddress(): bccOfIdentity: ${bccOfIdentity.value}');

      if (identity?.email?.isNotEmpty == true) {
        try {
          emailOfIdentity.value = listEmailAddressDefault
              .firstWhere((emailAddress) => emailAddress.email ==  identity?.email);
        } catch(e) {
          emailOfIdentity.value = null;
        }
      } else {
        emailOfIdentity.value = listEmailAddressDefault.isNotEmpty
            ? listEmailAddressDefault.first
            : null;
      }
    } else {
      replyToOfIdentity.value = null;
      bccOfIdentity.value = null;
      emailOfIdentity.value = listEmailAddressDefault.isNotEmpty
          ? listEmailAddressDefault.first
          : null;
    }
  }

  void selectSignatureType(BuildContext context, SignatureType newSignatureType) async {
    if (newSignatureType == SignatureType.plainText && !BuildUtils.isWeb) {
      final signatureText = await _getSignatureHtmlText();
      log('IdentityCreatorController::selectSignatureType(): signatureText: $signatureText');
      updateContentHtmlEditor(signatureText);
    }
    clearFocusEditor(context);
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

  Future<String?> _getSignatureHtmlText() async {
    if (BuildUtils.isWeb) {
      return signatureHtmlEditorController.getText();
    } else {
      return signatureHtmlEditorMobileController?.getText();
    }
  }

  void createNewIdentity(BuildContext context) async {
    clearFocusEditor(context);

    final error = _getErrorInputNameString(context);
    if (error?.isNotEmpty == true) {
      log('IdentityCreatorController::createNewIdentity(): error: $error');
      errorNameIdentity.value = error;
      return;
    }

    final errorBcc = _getErrorInputAddressString(context);
    if (errorBcc?.isNotEmpty == true) {
      log('IdentityCreatorController::createNewIdentity(): errorBcc: $errorBcc');
      errorBccIdentity.value = errorBcc;
      return;
    }

    final signaturePlainText = signaturePlainEditorController.text;
    final signatureHtmlText = BuildUtils.isWeb
        ? contentHtmlEditor
        : await _getSignatureHtmlText();
    final bccAddress = bccOfIdentity.value != null && bccOfIdentity.value != noneEmailAddress
        ? {bccOfIdentity.value!}
        : <EmailAddress>{};
    final replyToAddress = replyToOfIdentity.value != null && replyToOfIdentity.value != noneEmailAddress
        ? {replyToOfIdentity.value!}
        : <EmailAddress>{};

    log('IdentityCreatorController::createNewIdentity(): bccAddress: $bccAddress');
    log('IdentityCreatorController::createNewIdentity(): replyToAddress: $replyToAddress');
    log('IdentityCreatorController::createNewIdentity(): signaturePlainText: $signaturePlainText');
    log('IdentityCreatorController::createNewIdentity(): signatureHtmlText: $signatureHtmlText');

    final newIdentity = Identity(
      name: _nameIdentity,
      email: emailOfIdentity.value?.email,
      replyTo: replyToAddress,
      bcc: bccAddress,
      textSignature: Signature(signaturePlainText),
      htmlSignature: Signature(signatureHtmlText ?? ''));

    log('IdentityCreatorController::createNewIdentity(): $newIdentity');

    final generateCreateId = Id(_uuid.v1());

    if(actionType == IdentityActionType.create) {
      _identitiesController.createNewIdentityAction(
        accountId!,
        CreateNewIdentityRequest(generateCreateId, newIdentity),
      );
    } else {
      _identitiesController.editIdentityAction(
        accountId!,
        EditIdentityRequest(
          identityId: identity!.id!,
          identityRequest: newIdentity.toIdentityRequest(),
        )
      );
    }

    if(kIsWeb) {
      _accountDashBoardController.identityCreatorIsActive.toggle();
    } else {
      popBack();
    }
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

  String? _getErrorInputAddressString(BuildContext context, {String? value}) {
    final emailAddress = value ?? inputBccIdentityController.text;
    if (emailAddress.trim().isEmpty) {
      return null;
    }
    return _verifyNameInteractor.execute(
        emailAddress,
        [EmailAddressValidator()]
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

  void validateInputBccAddress(BuildContext context, String? value) {
    final errorBcc = _getErrorInputAddressString(context, value: value);
    if (errorBccIdentity.value?.isNotEmpty == true
        && (errorBcc == null || errorBcc.isEmpty)) {
      errorBccIdentity.value = null;
    }
  }

  void _clearAll() {
    signaturePlainEditorController.clear();
    inputNameIdentityController.clear();
    inputBccIdentityController.clear();
  }

  List<EmailAddress> getSuggestionEmailAddress(String? pattern) {
    if (pattern == null || pattern.isEmpty) {
      return List.empty();
    }
   return listEmailAddressOfReplyTo
       .where((emailAddress) => emailAddress.email?.contains(pattern) == true)
       .toList();
  }

  void clearFocusEditor(BuildContext context) {
    if (!BuildUtils.isWeb) {
      signatureHtmlEditorMobileController?.unfocus();
    }
    FocusScope.of(context).unfocus();
  }

  void closeView(BuildContext context) {
    _clearAll();
    clearFocusEditor(context);
    if(kIsWeb) {
      _accountDashBoardController.identityCreatorIsActive.toggle();
    } else {
      popBack();
    }
  }
}