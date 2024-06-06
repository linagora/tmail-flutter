import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/keyboard_utils.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/capability/core_capability.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:model/extensions/identity_extension.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rich_text_composer/rich_text_composer.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/controller/rich_text_mobile_tablet_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/controller/rich_text_web_controller.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/extesions/size_extension.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/model/identity_creator_arguments.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/utils/identity_creator_constants.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/email_address_validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/empty_name_validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/state/verify_name_view_state.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/extensions/validator_failure_extension.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/create_new_identity_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/edit_identity_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_all_identities_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_identities_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/identity_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/identity_action_type.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/identities/utils/identity_utils.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class IdentityCreatorController extends BaseController {

  final VerifyNameInteractor _verifyNameInteractor;
  final GetAllIdentitiesInteractor _getAllIdentitiesInteractor;
  final IdentityUtils _identityUtils;

  final noneEmailAddress = EmailAddress(null, 'None');
  final listEmailAddressDefault = <EmailAddress>[].obs;
  final listEmailAddressOfReplyTo = <EmailAddress>[].obs;
  final errorNameIdentity = Rxn<String>();
  final errorBccIdentity = Rxn<String>();
  final emailOfIdentity = Rxn<EmailAddress>();
  final replyToOfIdentity = Rxn<EmailAddress>();
  final bccOfIdentity = Rxn<EmailAddress>();
  final actionType = IdentityActionType.create.obs;
  final isDefaultIdentity = RxBool(false);
  final isDefaultIdentitySupported = RxBool(false);
  final isMobileEditorFocus = RxBool(false);
  final isCompressingInlineImage = RxBool(false);

  final TextEditingController inputNameIdentityController = TextEditingController();
  final TextEditingController inputBccIdentityController = TextEditingController();
  final FocusNode inputNameIdentityFocusNode = FocusNode();
  final FocusNode inputBccIdentityFocusNode = FocusNode();
  final ScrollController scrollController = ScrollController();

  RichTextMobileTabletController? richTextMobileTabletController;
  RichTextWebController? richTextWebController;

  String? _nameIdentity;
  String? _contentHtmlEditor;
  AccountId? accountId;
  Session? session;
  Identity? identity;
  IdentityCreatorArguments? arguments;

  final GlobalKey htmlKey = GlobalKey();
  final htmlEditorMinHeight = 150;
  bool isLoadSignatureCompleted = false;

  void updateNameIdentity(BuildContext context, String? value) {
    _nameIdentity = value?.trim();
    errorNameIdentity.value = _getErrorInputNameString(context);
  }

  void updateContentHtmlEditor(String? text) => _contentHtmlEditor = text;

  String? get contentHtmlEditor {
    if (_contentHtmlEditor != null) {
      return _contentHtmlEditor;
    } else {
      return arguments?.identity?.signatureAsString;
    }
  }

  IdentityCreatorController(
      this._verifyNameInteractor,
      this._getAllIdentitiesInteractor,
      this._identityUtils
  );

  @override
  void onInit() {
    super.onInit();
    if (PlatformInfo.isWeb) {
      richTextWebController = RichTextWebController();
    } else {
      richTextMobileTabletController = RichTextMobileTabletController();
    }
    log('IdentityCreatorController::onInit():arguments: ${Get.arguments}');
    arguments = Get.arguments;
  }

  @override
  void onReady() {
    super.onReady();
    log('IdentityCreatorController::onReady():');
    if (arguments != null) {
      accountId = arguments!.accountId;
      session = arguments!.session;
      identity = arguments!.identity;
      actionType.value = arguments!.actionType;
      _checkDefaultIdentityIsSupported();
      _setUpValueFromIdentity();
      _getAllIdentities();
    }
  }

  @override
  void onClose() {
    log('IdentityCreatorController::onClose():');
    isLoadSignatureCompleted = false;
    inputNameIdentityFocusNode.dispose();
    inputBccIdentityFocusNode.dispose();
    inputNameIdentityController.dispose();
    inputBccIdentityController.dispose();
    scrollController.dispose();
    if (PlatformInfo.isWeb) {
      richTextWebController?.onClose();
      richTextWebController = null;
    } else {
      richTextMobileTabletController?.onClose();
      richTextMobileTabletController = null;
    }
    super.onClose();
  }

  @override
  void handleSuccessViewState(Success success) {
    super.handleSuccessViewState(success);
    if (success is GetAllIdentitiesSuccess) {
      _getALlIdentitiesSuccess(success);
    }
  }

  @override
  void handleFailureViewState(Failure failure) {
    super.handleFailureViewState(failure);
    if (failure is GetAllIdentitiesFailure) {
      _getALlIdentitiesFailure(failure);
    }
  }

  void _checkDefaultIdentityIsSupported() {
    if (session != null && accountId != null) {
      isDefaultIdentitySupported.value = [CapabilityIdentifier.jamesSortOrder].isSupported(session!, accountId!);
    }
  }

  void _setUpValueFromIdentity() {
    _nameIdentity = identity?.name ?? '';
    inputNameIdentityController.text = identity?.name ?? '';

    if (identity?.signatureAsString.isNotEmpty == true) {
      updateContentHtmlEditor(arguments?.identity?.signatureAsString ?? '');
      if (PlatformInfo.isWeb) {
        richTextWebController?.editorController.setText(arguments?.identity?.signatureAsString ?? '');
      }
    }
  }

  void _getAllIdentities() {
    if (accountId != null && session != null) {
      final propertiesRequired = isDefaultIdentitySupported.isTrue
        ? Properties({'email', 'sortOrder'})
        : Properties({'email'});

      consumeState(_getAllIdentitiesInteractor.execute(session!, accountId!, properties: propertiesRequired));
    }
  }

  void _getALlIdentitiesSuccess(GetAllIdentitiesSuccess success) {
    if (success.identities?.isNotEmpty == true) {
      listEmailAddressDefault.value = success.identities!
          .map((identity) => identity.toEmailAddressNoName())
          .toSet()
          .toList();
      listEmailAddressOfReplyTo.add(noneEmailAddress);
      listEmailAddressOfReplyTo.addAll(listEmailAddressDefault);
      _setUpAllFieldEmailAddress();

      if (isDefaultIdentitySupported.isTrue) {
        _setUpDefaultIdentity(success.identities);
      }
    } else {
      _setDefaultEmailAddressList();
    }
  }

  void _getALlIdentitiesFailure(GetAllIdentitiesFailure failure) {
    _setDefaultEmailAddressList();
  }

  void _setDefaultEmailAddressList() {
    listEmailAddressOfReplyTo.add(noneEmailAddress);

    if (session?.username.value.isNotEmpty == true) {
      final userEmailAddress = EmailAddress(null, session?.username.value);
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
        inputBccIdentityController.text = identity?.bcc!.first.emailAddress ?? '';
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

  void _setUpDefaultIdentity(List<Identity>? identities) {
    final listDefaultIdentityIds = _identityUtils
        .getSmallestOrderedIdentity(identities)
        ?.map((identity) => identity.id!);
    
    if (haveDefaultIdentities(identities, listDefaultIdentityIds) && 
      listDefaultIdentityIds?.contains(identity?.id) == true
    ) {
      isDefaultIdentity.value = true;
    } else {
      isDefaultIdentity.value = false;
    }
  }

  bool haveDefaultIdentities(
    Iterable<Identity>? allIdentities, 
    Iterable<IdentityId>? defaultIdentityIds
  ) {
    return defaultIdentityIds?.length != allIdentities?.length;
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
    if (PlatformInfo.isWeb) {
      return richTextWebController?.editorController.getText();
    } else {
      return richTextMobileTabletController?.richTextController.htmlEditorApi?.getText();
    }
  }

  void createNewIdentity(BuildContext context) async {
    isCompressingInlineImage.value = false;
    clearFocusEditor(context);

    final error = _getErrorInputNameString(context);
    if (error?.isNotEmpty == true) {
      errorNameIdentity.value = error;
      inputNameIdentityFocusNode.requestFocus();
      return;
    }

    final errorBcc = _getErrorInputAddressString(context);
    if (errorBcc?.isNotEmpty == true) {
      errorBccIdentity.value = errorBcc;
      inputBccIdentityFocusNode.requestFocus();
      return;
    }

    final signatureHtmlText = PlatformInfo.isWeb
        ? contentHtmlEditor
        : await _getSignatureHtmlText();
    final bccAddress = bccOfIdentity.value != null && bccOfIdentity.value != noneEmailAddress
        ? {bccOfIdentity.value!}
        : <EmailAddress>{};
    final replyToAddress = replyToOfIdentity.value != null && replyToOfIdentity.value != noneEmailAddress
        ? {replyToOfIdentity.value!}
        : <EmailAddress>{};

    final sortOrder = isDefaultIdentitySupported.isTrue
      ? UnsignedInt(isDefaultIdentity.value ? 0 : 100)
      : null;
    
    final newIdentity = Identity(
      name: _nameIdentity,
      email: emailOfIdentity.value?.email,
      replyTo: replyToAddress,
      bcc: bccAddress,
      htmlSignature: Signature(signatureHtmlText ?? ''),
      sortOrder: sortOrder);

    final generateCreateId = Id(uuid.v1());

    if (actionType.value == IdentityActionType.create) {
      final identityRequest = CreateNewIdentityRequest(
        generateCreateId, 
        newIdentity,
        isDefaultIdentity: isDefaultIdentity.value);
      popBack(result: identityRequest);
    } else {
      final identityRequest = EditIdentityRequest(
        identityId: identity!.id!,
        identityRequest: newIdentity.toIdentityRequest(),
        isDefaultIdentity: isDefaultIdentity.value);
      popBack(result: identityRequest);
    }
  }

  void onCheckboxChanged() {
    isDefaultIdentity.value = !isDefaultIdentity.value;
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

  List<EmailAddress> getSuggestionEmailAddress(String? pattern) {
    if (pattern == null || pattern.isEmpty) {
      return List.empty();
    }
   return listEmailAddressOfReplyTo
       .where((emailAddress) => emailAddress.email?.contains(pattern) == true)
       .toList();
  }

  void clearFocusEditor(BuildContext context) {
    if (PlatformInfo.isMobile) {
      richTextMobileTabletController?.htmlEditorApi?.unfocus();
      KeyboardUtils.hideSystemKeyboardMobile();
    }
    KeyboardUtils.hideKeyboard(context);
  }

  void closeView(BuildContext context) {
    isCompressingInlineImage.value = false;
    clearFocusEditor(context);
    popBack();
  }

  void initRichTextForMobile(BuildContext context, HtmlEditorApi editorApi) {
    richTextMobileTabletController?.htmlEditorApi = editorApi;
    richTextMobileTabletController?.richTextController.onCreateHTMLEditor(
      editorApi,
      onEnterKeyDown: _onEnterKeyDownOnMobile,
      onFocus: _onFocusHTMLEditorOnMobile,
      context: context
    );
    richTextMobileTabletController?.htmlEditorApi?.onFocusOut = () {
      richTextMobileTabletController?.richTextController.hideRichTextView();
      isMobileEditorFocus.value = false;
    };
  }

  void _onFocusHTMLEditorOnMobile() async {
    inputBccIdentityFocusNode.unfocus();
    inputNameIdentityFocusNode.unfocus();
    isMobileEditorFocus.value = true;
    if (htmlKey.currentContext != null) {
      await Scrollable.ensureVisible(htmlKey.currentContext!);
    }
    await Future.delayed(const Duration(milliseconds: 500), () {
      final offset = scrollController.position.pixels +
        defaultKeyboardToolbarHeight +
        htmlEditorMinHeight;
      scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 1),
        curve: Curves.linear,
      );
    });
  }

  void _onEnterKeyDownOnMobile() {
    if (scrollController.position.pixels < scrollController.position.maxScrollExtent) {
      scrollController.animateTo(
        scrollController.position.pixels + 20,
        duration: const Duration(milliseconds: 1),
        curve: Curves.linear,
      );
    }
  }

  void pickImage(BuildContext context) async {
    clearFocusEditor(context);

    final filePickerResult = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: PlatformInfo.isWeb
    );

    if (context.mounted) {
      if (filePickerResult?.files.isNotEmpty == true) {
        final platformFile = filePickerResult!.files.first;
        _insertInlineImage(context, platformFile, _getMaxWidthInlineImage(context).toInt());
      } else {
        appToast.showToastErrorMessage(
          context,
          AppLocalizations.of(context).cannotSelectThisImage
        );
      }
    } else {
      logError("IdentityCreatorController::pickImage: context is unmounted");
    }
  }

  bool _isExceedMaxSizeInlineImage(int fileSize) =>
    fileSize > IdentityCreatorConstants.maxKBSizeIdentityInlineImage.toBytes;
  
  bool _isExceedMaxUploadSize(int fileSize) {
    final coreCapability = session?.getCapabilityProperties<CoreCapability>(
      accountId!,
      CapabilityIdentifier.jmapCore
    );

    int maxUploadSize = coreCapability?.maxSizeUpload?.value.toInt() ?? 0;

    return fileSize > maxUploadSize;
  }

  void _insertInlineImage(
    BuildContext context,
    PlatformFile platformFile,
    int maxWidth
  ) async {
    final PlatformFile file;
    try {
      isCompressingInlineImage.value = true;
      file = await _compressImage(platformFile, maxWidth);
      isCompressingInlineImage.value = false;
    } catch (e) {
      logError("IdentityCreatorController::_insertInlineImage: compress image error: $e");
      isCompressingInlineImage.value = false;
      if (context.mounted) {
        appToast.showToastErrorMessage(
          context,
          AppLocalizations.of(context).cannotCompressInlineImage);
      }
      return;
    }
    if (_isExceedMaxSizeInlineImage(file.size) || _isExceedMaxUploadSize(file.size)) {
      if (context.mounted) {
        appToast.showToastErrorMessage(
          context,
          AppLocalizations.of(context).pleaseChooseAnImageSizeCorrectly(
            IdentityCreatorConstants.maxKBSizeIdentityInlineImage
          )
        );
      } else {
        logError("IdentityCreatorController::_insertInlineImage: context is unmounted");
      }
    } else {
      if (PlatformInfo.isWeb) {
        richTextWebController?.insertImageAsBase64(platformFile: file, maxWidth: maxWidth);
      } else if (PlatformInfo.isMobile) {
        richTextMobileTabletController?.insertImageData(platformFile: file, maxWidth: maxWidth);
        if (file.path != null) {
          _deleteCompressedFileOnMobile(file.path!);
        }
      } else {
        logError("IdentityCreatorController::_insertInlineImage: Platform not supported");
      }
    }
  }

  Future<PlatformFile> _compressImage(PlatformFile originalFile, int maxWidthCompressedImage) async {
    if (originalFile.size <= IdentityCreatorConstants.maxKBSizeIdentityInlineImage.toBytes) {
      return originalFile;
    }
    
    final Uint8List? fileBytes;

    if (PlatformInfo.isWeb) {
      fileBytes = originalFile.bytes;
    } else if (originalFile.path == null) {
      log('IdentityCreatorController::_compressImage: path is null');
      return originalFile;
    } else {
      fileBytes = await File(originalFile.path!).readAsBytes();
    }

    if (fileBytes == null || fileBytes.isEmpty) {
      log('IdentityCreatorController::_compressImage: fileBytes is null or empty');
      return originalFile;
    }

    log('IdentityCreatorController::_compressImage: BEFORE_COMPRESS: bytesData: ${fileBytes.lengthInBytes}');
    final Uint8List compressedBytes = await FlutterImageCompress.compressWithList(
      fileBytes,
      quality: IdentityCreatorConstants.qualityCompressedInlineImage,
      minWidth: maxWidthCompressedImage
    );
    log('IdentityCreatorController::_compressImage: AFTER_COMPRESS: bytesData: ${compressedBytes.lengthInBytes}');

    final PlatformFile compressedFile;

    if (PlatformInfo.isWeb) {
      compressedFile = PlatformFile(
        name: originalFile.name,
        size: compressedBytes.lengthInBytes,
        bytes: compressedBytes,
      );
    } else {
      final compressedFilePath = await _saveCompressedFileOnMobile(compressedBytes, originalFile.name);
      compressedFile = PlatformFile(
        name: originalFile.name,
        size: compressedBytes.lengthInBytes,
        path: compressedFilePath,
      );
    }

    log('IdentityCreatorController::_compressImage: compressedSize: ${compressedFile.size}');
    return compressedFile;
  }

  Future<String> _saveCompressedFileOnMobile(Uint8List compressedBytes, String originalFileName) async {
    final String compressedFileName = '${IdentityCreatorConstants.prefixCompressedInlineImageTemp}$originalFileName';

    final Directory appDir = await getApplicationDocumentsDirectory();
    final String compressedFilePath = '${appDir.path}/$compressedFileName';

    await File(compressedFilePath).writeAsBytes(compressedBytes);

    log('IdentityCreatorController::_saveCompressedFileOnMobile: compressedFilePath: $compressedFilePath');
    return compressedFilePath;
  }

  Future<void> _deleteCompressedFileOnMobile(String filePath) async {
    log('IdentityCreatorController::_deleteCompressedFileOnMobile: filePath: $filePath');
    try {
      final File file = File(filePath);
      if (await file.exists() && file.path.contains(IdentityCreatorConstants.prefixCompressedInlineImageTemp)) {
        await file.delete();
      }
    } catch (e) {
      logError('IdentityCreatorController::_deleteCompressedFileOnMobile: error: $e');
    }
  }

  bool isMobile(BuildContext context) =>
    responsiveUtils.isPortraitMobile(context) ||
    responsiveUtils.isLandscapeMobile(context);

  double _getMaxWidthInlineImage(BuildContext context) {
    if (isMobile(context)) {
      return responsiveUtils.getSizeScreenWidth(context);
    } else if (responsiveUtils.isDesktop(context)) {
      return math.max(responsiveUtils.getSizeScreenWidth(context) * 0.4, IdentityCreatorConstants.maxWidthInlineImageDesktop);
    } else {
      return math.max(responsiveUtils.getSizeScreenWidth(context) * 0.4, IdentityCreatorConstants.maxWidthInlineImageOther);
    }
  }

  void onLoadSignatureCompleted(String? content) {
    isLoadSignatureCompleted = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.fastOutSlowIn
        );
      }
    });
  }
}