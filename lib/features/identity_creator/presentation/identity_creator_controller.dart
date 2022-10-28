
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/build_utils.dart';
import 'package:enough_html_editor/enough_html_editor.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:model/extensions/identity_extension.dart';
import 'package:model/user/user_profile.dart';
import 'package:rich_text_composer/richtext_controller.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/model/identity_creator_arguments.dart';
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
import 'package:tmail_ui_user/features/manage_account/presentation/model/identity_action_type.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:uuid/uuid.dart';

typedef OnCreatedIdentityCallback = Function(dynamic arguments);

class IdentityCreatorController extends BaseController {

  final VerifyNameInteractor _verifyNameInteractor;
  final GetAllIdentitiesInteractor _getAllIdentitiesInteractor;

  final _uuid = Get.find<Uuid>();

  final noneEmailAddress = EmailAddress(null, 'None');
  final signatureType = SignatureType.plainText.obs;
  final listEmailAddressDefault = <EmailAddress>[].obs;
  final listEmailAddressOfReplyTo = <EmailAddress>[].obs;
  final errorNameIdentity = Rxn<String>();
  final errorBccIdentity = Rxn<String>();
  final emailOfIdentity = Rxn<EmailAddress>();
  final replyToOfIdentity = Rxn<EmailAddress>();
  final bccOfIdentity = Rxn<EmailAddress>();
  final actionType = IdentityActionType.create.obs;

  late RichTextController keyboardRichTextController;
  late HtmlEditorController signatureHtmlEditorController;
  TextEditingController? signaturePlainEditorController;
  TextEditingController? inputNameIdentityController;
  TextEditingController? inputBccIdentityController;
  FocusNode? inputNameIdentityFocusNode;

  HtmlEditorApi? signatureHtmlEditorMobileController;
  String? _nameIdentity;
  String? _contentHtmlEditor;
  AccountId? accountId;
  UserProfile? userProfile;
  Identity? identity;
  IdentityCreatorArguments? arguments;
  OnCreatedIdentityCallback? onCreatedIdentityCallback;
  VoidCallback? onDismissIdentityCreator;
  ScrollController? scrollController;

  final GlobalKey htmlKey = GlobalKey();

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
  void onInit() {
    super.onInit();
    keyboardRichTextController = RichTextController();
    signatureHtmlEditorController = HtmlEditorController(processNewLineAsBr: true);
    signaturePlainEditorController = TextEditingController();
    inputNameIdentityController = TextEditingController();
    inputBccIdentityController = TextEditingController();
    inputNameIdentityFocusNode = FocusNode();
    scrollController = ScrollController();
  }

  @override
  void onReady() {
    super.onReady();
    if (arguments != null) {
      accountId = arguments!.accountId;
      userProfile = arguments!.userProfile;
      identity = arguments!.identity;
      actionType.value = arguments!.actionType;
      _setUpValueFromIdentity();
      _getAllIdentities();
    }
  }

  @override
  void onClose() {
    keyboardRichTextController.dispose();
    _disposeWidget();
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

  void _setUpValueFromIdentity() {
    _nameIdentity = identity?.name ?? '';
    inputNameIdentityController?.text = identity?.name ?? '';

    if (identity?.textSignature?.value.isNotEmpty == true) {
      signaturePlainEditorController?.text = identity?.textSignature?.value ?? '';
    }

    if (identity?.htmlSignature?.value.isNotEmpty == true) {
      updateContentHtmlEditor(identity?.htmlSignature?.value ?? '');
      signatureHtmlEditorController.setText(identity?.htmlSignature?.value ?? '');
    }
  }

  void _getAllIdentities() {
    log('IdentityCreatorController::_getAllIdentities() ');
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
    listEmailAddressOfReplyTo.value = listEmailAddressOfReplyTo.toSet().toList();
    listEmailAddressDefault.value = listEmailAddressDefault.toSet().toList();

    if (actionType.value == IdentityActionType.edit && identity != null) {
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

      if (identity?.bcc?.isNotEmpty == true) {
        bccOfIdentity.value = identity?.bcc!.first;
        inputBccIdentityController?.text = identity?.bcc!.first.emailAddress ?? '';
      } else {
        bccOfIdentity.value = null;
      }

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
      errorNameIdentity.value = error;
      return;
    }

    final errorBcc = _getErrorInputAddressString(context);
    if (errorBcc?.isNotEmpty == true) {
      errorBccIdentity.value = errorBcc;
      return;
    }

    final signaturePlainText = signaturePlainEditorController?.text ?? '';
    final signatureHtmlText = BuildUtils.isWeb
        ? contentHtmlEditor
        : await _getSignatureHtmlText();
    final bccAddress = bccOfIdentity.value != null && bccOfIdentity.value != noneEmailAddress
        ? {bccOfIdentity.value!}
        : <EmailAddress>{};
    final replyToAddress = replyToOfIdentity.value != null && replyToOfIdentity.value != noneEmailAddress
        ? {replyToOfIdentity.value!}
        : <EmailAddress>{};

    final newIdentity = Identity(
      name: _nameIdentity,
      email: emailOfIdentity.value?.email,
      replyTo: replyToAddress,
      bcc: bccAddress,
      textSignature: Signature(signaturePlainText),
      htmlSignature: Signature(signatureHtmlText ?? ''));

    final generateCreateId = Id(_uuid.v1());

    if (actionType.value == IdentityActionType.create) {
      final identityRequest = CreateNewIdentityRequest(generateCreateId, newIdentity);

      if (BuildUtils.isWeb) {
        _disposeWidget();
        onCreatedIdentityCallback?.call(identityRequest);
      } else {
        popBack(result: identityRequest);
      }

    } else {
      final identityRequest = EditIdentityRequest(
          identityId: identity!.id!,
          identityRequest: newIdentity.toIdentityRequest());

      if (BuildUtils.isWeb) {
        _disposeWidget();
        onCreatedIdentityCallback?.call(identityRequest);
      } else {
        popBack(result: identityRequest);
      }
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
    final emailAddress = value ?? inputBccIdentityController?.text ?? '';
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
    signaturePlainEditorController?.clear();
    inputNameIdentityController?.clear();
    inputBccIdentityController?.clear();
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

    if (BuildUtils.isWeb) {
      _disposeWidget();
      onDismissIdentityCreator?.call();
    } else {
      popBack();
    }
  }

  void _disposeWidget() {
    signaturePlainEditorController?.dispose();
    signaturePlainEditorController = null;
    inputNameIdentityFocusNode?.dispose();
    inputNameIdentityFocusNode = null;
    inputNameIdentityController?.dispose();
    inputNameIdentityController = null;
    inputBccIdentityController?.dispose();
    inputBccIdentityController = null;
    scrollController?.dispose();
    scrollController = null;
  }

  void onFocusHTMLEditor() async {
    await Scrollable.ensureVisible(htmlKey.currentContext!);
    await Future.delayed(const Duration(milliseconds: 500), () {
      if (scrollController != null) {
        scrollController!.animateTo(
          scrollController!.position.pixels + defaultKeyboardToolbarHeight,
          duration: const Duration(milliseconds: 1),
          curve: Curves.linear,
        );
      }
    });
  }

  void onEnterKeyDown() {
    if(scrollController != null &&
        scrollController!.position.pixels < scrollController!.position.maxScrollExtent) {
      scrollController!.animateTo(
        scrollController!.position.pixels + 20,
        duration: const Duration(milliseconds: 1),
        curve: Curves.linear,
      );
    }
  }
}