import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:core/presentation/extensions/list_nullable_extensions.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/keyboard_utils.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/file_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';
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
import 'package:model/upload/file_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rich_text_composer/rich_text_composer.dart';
import 'package:rich_text_composer/views/commons/constants.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/base/before_reconnect_handler.dart';
import 'package:tmail_ui_user/features/base/before_reconnect_manager.dart';
import 'package:tmail_ui_user/features/composer/presentation/controller/rich_text_mobile_tablet_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/controller/rich_text_web_controller.dart';
import 'package:tmail_ui_user/features/identity_creator/domain/model/identity_cache.dart';
import 'package:tmail_ui_user/features/identity_creator/domain/usecase/save_identity_cache_on_web_interactor.dart';
import 'package:tmail_ui_user/features/composer/presentation/mixin/drag_drog_file_mixin.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/model/identity_creator_arguments.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/utils/identity_creator_constants.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/email_address_validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/empty_name_validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/name_with_space_only_validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/state/verify_name_view_state.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/extensions/validator_failure_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/draggable_app_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/create_new_identity_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/edit_identity_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_all_identities_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_all_identities_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/identity_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/identity_action_type.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/profiles/identities/utils/identity_utils.dart';
import 'package:tmail_ui_user/features/public_asset/domain/model/public_assets_in_identity_arguments.dart';
import 'package:tmail_ui_user/features/public_asset/presentation/model/public_asset_arguments.dart';
import 'package:tmail_ui_user/features/public_asset/presentation/public_asset_bindings.dart';
import 'package:tmail_ui_user/features/public_asset/presentation/public_asset_controller.dart';
import 'package:tmail_ui_user/features/upload/domain/extensions/file_info_extension.dart';
import 'package:tmail_ui_user/features/upload/domain/extensions/list_file_info_extension.dart';
import 'package:tmail_ui_user/features/upload/domain/extensions/list_file_upload_extension.dart';
import 'package:tmail_ui_user/features/upload/domain/extensions/list_platform_file_extensions.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/universal_import/html_stub.dart' as html hide File;

class IdentityCreatorController extends BaseController with DragDropFileMixin implements BeforeReconnectHandler {

  final VerifyNameInteractor _verifyNameInteractor;
  final GetAllIdentitiesInteractor _getAllIdentitiesInteractor;
  final SaveIdentityCacheOnWebInteractor _saveIdentityCacheOnWebInteractor;
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
  final isCompressingInlineImage = RxBool(false);
  final draggableAppState = DraggableAppState.inActive.obs;

  final TextEditingController inputNameIdentityController = TextEditingController();
  final TextEditingController inputBccIdentityController = TextEditingController();
  final FocusNode inputNameIdentityFocusNode = FocusNode();
  final FocusNode inputBccIdentityFocusNode = FocusNode();
  final ScrollController scrollController = ScrollController();

  RichTextMobileTabletController? richTextMobileTabletController;
  RichTextWebController? richTextWebController;
  StreamSubscription<html.Event>? _subscriptionOnDragEnter;
  StreamSubscription<html.Event>? _subscriptionOnDragOver;
  StreamSubscription<html.Event>? _subscriptionOnDragLeave;
  StreamSubscription<html.Event>? _subscriptionOnDrop;
  final _beforeReconnectManager = Get.find<BeforeReconnectManager>();

  String? _nameIdentity;
  String? _contentHtmlEditor;
  AccountId? accountId;
  Session? session;
  Identity? identity;
  IdentityCreatorArguments? arguments;
  PublicAssetController? publicAssetController;

  final GlobalKey htmlKey = GlobalKey();
  final htmlEditorMinHeight = 150;
  bool isLoadSignatureCompleted = false;
  bool _userScrolled = false;

  void _scrollListener() {
    if (!_userScrolled) {
      _userScrolled = true;
    }
  }

  void updateNameIdentity(BuildContext context, String? value) {
    _nameIdentity = value;
    errorNameIdentity.value = _getErrorInputNameString(context);
  }

  void updateContentHtmlEditor(String? text) => _contentHtmlEditor = text;

  String get contentHtmlEditor {
    if (_contentHtmlEditor != null) {
      return _contentHtmlEditor ?? '';
    } else {
      return arguments?.identity?.signatureAsString ?? '';
    }
  }

  int get maxSizeUploadByBytes {
    if (session == null || accountId == null) return 0;

    return session!.getCapabilityProperties<CoreCapability>(
      accountId!,
      CapabilityIdentifier.jmapCore
    )?.maxSizeUpload?.value.toInt() ?? 0;
  }

  IdentityCreatorController(
      this._verifyNameInteractor,
      this._getAllIdentitiesInteractor,
      this._saveIdentityCacheOnWebInteractor,
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
    _beforeReconnectManager.addListener(onBeforeReconnect);
    _initFocusListener();
  }

  @override
  void onReady() {
    super.onReady();
    log('IdentityCreatorController::onReady():');
    scrollController.addListener(_scrollListener);
    if (arguments != null) {
      accountId = arguments!.accountId;
      session = arguments!.session;
      identity = arguments!.identity;
      actionType.value = arguments!.actionType;
      if (actionType.value == IdentityActionType.create
        && arguments!.publicAssetsInIdentityArguments == null
      ) {
        isLoadSignatureCompleted = true;
      }
      _checkDefaultIdentityIsSupported();
      _checkPublicAssetCapability();
      _setUpValueFromIdentity();
      _getAllIdentities();
      _triggerBrowserEventListener();
    }
  }

  void _initFocusListener() {
    inputNameIdentityFocusNode.addListener(_onInputNameIdentityListener);
    inputBccIdentityFocusNode.addListener(_onInputBccIdentityListener);
  }

  void _removeFocusListener() {
    inputNameIdentityFocusNode.removeListener(_onInputNameIdentityListener);
    inputBccIdentityFocusNode.removeListener(_onInputBccIdentityListener);
  }

  void _onInputNameIdentityListener() {
    if (inputNameIdentityFocusNode.hasFocus && PlatformInfo.isMobile) {
      richTextMobileTabletController?.richTextController.hideRichTextView();
    }
  }

  void _onInputBccIdentityListener() {
    if (inputBccIdentityFocusNode.hasFocus && PlatformInfo.isMobile) {
      richTextMobileTabletController?.richTextController.hideRichTextView();
    }
  }

  void _checkPublicAssetCapability() {
    if (CapabilityIdentifier.jmapPublicAsset.isSupported(session!, accountId!)) {
      PublicAssetBindings(PublicAssetArguments(session!, accountId!, identity: identity)).dependencies();
      publicAssetController = Get.find<PublicAssetController>(tag: BindingTag.publicAssetBindingsTag);
    }
  }

  void _triggerBrowserEventListener() {
    _subscriptionOnDragEnter = html.window.onDragEnter.listen((event) {
      event.preventDefault();

      if (event.dataTransfer.types.validateFilesTransfer) {
        draggableAppState.value = DraggableAppState.active;
      }
    });

    _subscriptionOnDragOver = html.window.onDragOver.listen((event) {
      event.preventDefault();

      if (event.dataTransfer.types.validateFilesTransfer) {
        draggableAppState.value = DraggableAppState.active;
      }
    });

    _subscriptionOnDragLeave = html.window.onDragLeave.listen((event) {
      event.preventDefault();

      if (event.dataTransfer.types.validateFilesTransfer) {
        draggableAppState.value = DraggableAppState.inActive;
      }
    });

    _subscriptionOnDrop = html.window.onDrop.listen((event) {
      event.preventDefault();

      if (event.dataTransfer.types.validateFilesTransfer) {
        draggableAppState.value = DraggableAppState.inActive;
      }
    });
  }

  void handleOnDragEnterSignatureEditorWeb(List<dynamic>? types) {
    if (types.validateFilesTransfer) {
      draggableAppState.value = DraggableAppState.active;
    }
  }

  @override
  void onClose() {
    log('IdentityCreatorController::onClose():');
    isLoadSignatureCompleted = false;
    _removeFocusListener();
    inputNameIdentityFocusNode.dispose();
    inputBccIdentityFocusNode.dispose();
    inputNameIdentityController.dispose();
    inputBccIdentityController.dispose();
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    if (PlatformInfo.isWeb) {
      richTextWebController?.onClose();
      richTextWebController = null;
    } else {
      richTextMobileTabletController?.onClose();
      richTextMobileTabletController = null;
    }
    Get.delete<PublicAssetController>(tag: BindingTag.publicAssetBindingsTag);
    publicAssetController = null;
    _subscriptionOnDragEnter?.cancel();
    _subscriptionOnDragOver?.cancel();
    _subscriptionOnDragLeave?.cancel();
    _subscriptionOnDrop?.cancel();
    _beforeReconnectManager.removeListener(onBeforeReconnect);
    super.onClose();
  }

  @override
  void handleSuccessViewState(Success success) {
    super.handleSuccessViewState(success);
    if (success is GetAllIdentitiesSuccess) {
      _getAllIdentitiesSuccess(success);
    }
  }

  @override
  void handleFailureViewState(Failure failure) {
    super.handleFailureViewState(failure);
    if (failure is GetAllIdentitiesFailure) {
      _getAllIdentitiesFailure(failure);
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
    _initPublicAssetController();
  }

  void _initPublicAssetController() {
    final publicAssetsInIdentityArguments = arguments?.publicAssetsInIdentityArguments;
    final htmlSignature = arguments?.identity?.signatureAsString;

    if (publicAssetsInIdentityArguments != null) {
      publicAssetController?.restorePreExistingPublicAssetsFromCache(
        publicAssetsInIdentityArguments.preExistingPublicAssetIds);
      publicAssetController?.restoreNewlyPickedPublicAssetsFromCache(
        publicAssetsInIdentityArguments.newlyPickedPublicAssetIds);
    } else if (htmlSignature != null && htmlSignature.isNotEmpty) {
      publicAssetController?.getOldPublicAssetFromHtmlContent(htmlSignature);
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

  void _getAllIdentitiesSuccess(GetAllIdentitiesSuccess success) {
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

  void _getAllIdentitiesFailure(GetAllIdentitiesFailure failure) {
    _setDefaultEmailAddressList();
  }

  void _setDefaultEmailAddressList() {
    listEmailAddressOfReplyTo.add(noneEmailAddress);

    if (session?.getOwnEmailAddress() != null) {
      final userEmailAddress = EmailAddress(null, session?.getOwnEmailAddress());
      listEmailAddressDefault.add(userEmailAddress);
      listEmailAddressOfReplyTo.addAll(listEmailAddressDefault);
    }

    _setUpAllFieldEmailAddress();
  }

  void _setUpAllFieldEmailAddress() {
    listEmailAddressOfReplyTo.value = listEmailAddressOfReplyTo.toSet().toList();
    listEmailAddressDefault.value = listEmailAddressDefault.toSet().toList();

    if (identity?.replyTo?.isNotEmpty == true) {
      replyToOfIdentity.value = listEmailAddressOfReplyTo
        .firstWhereOrNull((emailAddress) => emailAddress ==  identity!.replyTo!.first);

      if (replyToOfIdentity.value == null && identity!.replyTo!.first == noneEmailAddress) {
        replyToOfIdentity.value = noneEmailAddress;
      }
    } else if (actionType.value == IdentityActionType.edit) {
      replyToOfIdentity.value = noneEmailAddress;
    } else {
      replyToOfIdentity.value = null;
    }

    if (identity?.bcc?.isNotEmpty == true) {
      bccOfIdentity.value = identity!.bcc!.first;
      inputBccIdentityController.text = identity!.bcc!.first.emailAddress;
    } else {
      bccOfIdentity.value = null;
    }

    if (identity?.email?.isNotEmpty == true) {
      emailOfIdentity.value = listEmailAddressDefault
        .firstWhereOrNull((emailAddress) => emailAddress.email ==  identity!.email);
    } else {
      emailOfIdentity.value = listEmailAddressDefault.firstOrNull;
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
    } else if (arguments?.isDefault == true) {
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

  void updateEmailOfIdentity(BuildContext context, EmailAddress? newEmailAddress) {
    if (PlatformInfo.isMobile) {
      richTextMobileTabletController?.richTextController.htmlEditorApi?.unfocus();
    }
    FocusScope.of(context).unfocus();

    emailOfIdentity.value = newEmailAddress;
  }

  void updaterReplyToOfIdentity(BuildContext context, EmailAddress? newEmailAddress) {
    if (PlatformInfo.isMobile) {
      richTextMobileTabletController?.richTextController.htmlEditorApi?.unfocus();
    }
    FocusScope.of(context).unfocus();

    replyToOfIdentity.value = newEmailAddress;
  }

  void updateBccOfIdentity(EmailAddress? newEmailAddress) {
    bccOfIdentity.value = newEmailAddress;
  }

  Future<String> _getSignatureHtmlText() async {
    if (PlatformInfo.isWeb) {
      return (await richTextWebController?.editorController.getText()) ?? '';
    } else {
      return (await richTextMobileTabletController?.richTextController.htmlEditorApi?.getText()) ?? '';
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

    final identityAndPublicAssetArguments = await _generateIdentityAndPublicAssetArguments();

    if (actionType.value == IdentityActionType.create) {
      final generateCreateId = Id(uuid.v1());
      final identityRequest = CreateNewIdentityRequest(
        generateCreateId,
        identityAndPublicAssetArguments.identity,
        publicAssetsInIdentityArguments: identityAndPublicAssetArguments.publicAssetsInIdentityArguments,
        isDefaultIdentity: isDefaultIdentity.value);
      popBack(result: identityRequest);
    } else {
      final identityRequest = EditIdentityRequest(
        identityId: identity!.id!,
        identityRequest: identityAndPublicAssetArguments.identity.toIdentityRequest(),
        publicAssetsInIdentityArguments: identityAndPublicAssetArguments.publicAssetsInIdentityArguments,
        isDefaultIdentity: isDefaultIdentity.value);
      popBack(result: identityRequest);
    }
  }

  Future<({
    Identity identity,
    PublicAssetsInIdentityArguments publicAssetsInIdentityArguments
  })> _generateIdentityAndPublicAssetArguments({bool forCache = false}) async {
    final signatureHtmlText = PlatformInfo.isWeb
        ? contentHtmlEditor
        : await _getSignatureHtmlText();
    final bccAddress = bccOfIdentity.value != null && bccOfIdentity.value != noneEmailAddress
        ? {bccOfIdentity.value!}
        : <EmailAddress>{};
    Set<EmailAddress> replyToAddress;
    if (replyToOfIdentity.value != null && (replyToOfIdentity.value != noneEmailAddress || forCache)) {
      replyToAddress = {replyToOfIdentity.value!};
    } else {
      replyToAddress = {};
    }

    final sortOrder = isDefaultIdentitySupported.isTrue
      ? UnsignedInt(isDefaultIdentity.value ? 0 : 100)
      : null;

    final publicAssetsInIdentityArguments = PublicAssetsInIdentityArguments(
      htmlSignature: signatureHtmlText,
      preExistingPublicAssetIds: List.from(publicAssetController?.preExistingPublicAssetIds ?? []),
      newlyPickedPublicAssetIds: List.from(publicAssetController?.newlyPickedPublicAssetIds ?? []),
    );
    
    final newIdentity = Identity(
      name: _nameIdentity,
      email: emailOfIdentity.value?.email,
      replyTo: replyToAddress,
      bcc: bccAddress,
      htmlSignature: Signature(signatureHtmlText),
      sortOrder: sortOrder);

    return (
      identity: newIdentity,
      publicAssetsInIdentityArguments: publicAssetsInIdentityArguments
    );
  }

  void onCheckboxChanged() {
    isDefaultIdentity.value = !isDefaultIdentity.value;
  }

  String? _getErrorInputNameString(BuildContext context) {
    return _verifyNameInteractor.execute(
        _nameIdentity,
        [
          EmptyNameValidator(),
          NameWithSpaceOnlyValidator(),
        ],
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
      [
        EmailAddressValidator(),
        NameWithSpaceOnlyValidator(),
      ],
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
    inputNameIdentityFocusNode.unfocus();
    inputBccIdentityFocusNode.unfocus();
    if (PlatformInfo.isMobile) {
      richTextMobileTabletController?.richTextController.htmlEditorApi?.unfocus();
    }
    KeyboardUtils.hideKeyboard(context);
  }

  void closeView(BuildContext context) {
    isCompressingInlineImage.value = false;
    clearFocusEditor(context);
    publicAssetController?.discardChanges();
    popBack();
  }

  void initRichTextForMobile(BuildContext context, HtmlEditorApi editorApi) {
    richTextMobileTabletController?.htmlEditorApi = editorApi;
    richTextMobileTabletController?.richTextController.onCreateHTMLEditor(
      editorApi,
      onEnterKeyDown: _onEnterKeyDownOnMobile,
      onFocus: () => _onFocusHTMLEditorOnMobile(context)
    );
  }

  void _onFocusHTMLEditorOnMobile(BuildContext context) async {
    if (PlatformInfo.isAndroid) {
      FocusScope.of(context).unfocus();
      await Future.delayed(
        const Duration(milliseconds: 300),
        richTextMobileTabletController?.richTextController.showDeviceKeyboard);
    }

    inputBccIdentityFocusNode.unfocus();
    inputNameIdentityFocusNode.unfocus();
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
  
  bool _isExceedMaxUploadSize(int fileSize) {
    return fileSize > maxSizeUploadByBytes;
  }

  Future<void> _insertInlineImage(
    BuildContext context,
    PlatformFile platformFile,
    int maxWidth,
    {PlatformFile? compressedFile}
  ) async {
    final PlatformFile? file;
    if (compressedFile != null) {
      file = compressedFile;
    } else {
      file = await _compressFileAction(context, originalFile: platformFile, maxWidth: maxWidth);
    }
    if (file == null) return;

    if (_isExceedMaxUploadSize(file.size)) {
      if (context.mounted) {
        appToast.showToastErrorMessage(
          context,
          AppLocalizations.of(context).pleaseChooseAnImageSizeCorrectly(
            maxSizeUploadByBytes
          )
        );
      } else {
        logError("IdentityCreatorController::_insertInlineImage: context is unmounted");
      }
    } else if (publicAssetController != null) {
      publicAssetController!.uploadFileToBlob(file);
    } else {
      if (PlatformInfo.isWeb) {
        richTextWebController?.insertImageAsBase64(platformFile: file, maxWidth: maxWidth);
      } else if (PlatformInfo.isMobile) {
        richTextMobileTabletController?.insertImageData(platformFile: file, maxWidth: maxWidth);
        if (file.path != null) {
          getBinding<FileUtils>()?.deleteCompressedFileOnMobile(
            file.path!,
            pathContains: IdentityCreatorConstants.prefixCompressedInlineImageTemp);
        }
      } else {
        logError("IdentityCreatorController::_insertInlineImage: Platform not supported");
      }
    }
  }

  Future<PlatformFile?> _compressFileAction(
    BuildContext context,
    {
      required PlatformFile originalFile,
      required int maxWidth
    }
  ) async {
    try {
      isCompressingInlineImage.value = true;
      final compressedFile = await _compressImage(originalFile, maxWidth);
      isCompressingInlineImage.value = false;
      return compressedFile;
    } catch (e) {
      logError("$runtimeType::_compressFileAction: compress image error: $e");
      isCompressingInlineImage.value = false;
      if (context.mounted) {
        appToast.showToastErrorMessage(
          context,
          AppLocalizations.of(context).cannotCompressInlineImage);
      }
      return null;
    }
  }

  Future<PlatformFile> _compressImage(PlatformFile originalFile, int maxWidthCompressedImage) async {
    if (originalFile.size <= maxSizeUploadByBytes) {
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
    if (_userScrolled) return;
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

  Future<void> onPasteImageSuccess(
    BuildContext context,
    List<FileUpload> listFileUpload,
    {required double maxWidth}
  ) async {
    await _uploadMultipleFilesToPublicAsset(
      context,
      listFileUpload.toListFileInfo(),
      maxWidth: maxWidth);
  }

  void onPasteImageFailure(
    BuildContext context,
    List<FileUpload>? listFileUpload,
    {String? base64,
    required UploadError uploadError}
  ) {
    logError('$runtimeType::onPasteImageFailure: $uploadError');
    appToast.showToastErrorMessage(
      context,
      AppLocalizations.of(context).thisImageCannotBePastedIntoTheEditor);
  }

  void onLocalFileDropZoneListener({
    required BuildContext context,
    required DropDoneDetails details,
    required double maxWidth
  }) async {
    clearFocusEditor(context);

    final listFileInfo = await onDragDone(context: context, details: details);
    if (!context.mounted) return;
    await _uploadMultipleFilesToPublicAsset(
      context,
      listFileInfo,
      maxWidth: maxWidth);
  }

  Future<void> _uploadMultipleFilesToPublicAsset(
    BuildContext context,
    List<FileInfo> listFileInfo,
    {required double maxWidth}
  ) async {
    try {
      final listImages = listFileInfo.listInlineFiles;

      if (listImages.isEmpty && listFileInfo.isNotEmpty && context.mounted) {
        appToast.showToastErrorMessage(
          context,
          AppLocalizations.of(context).canNotUploadFileToSignature
        );
        return;
      }

      final listCompressedImages = await Future.wait(
        listImages.map((fileInfo) => _compressFileAction(
          context,
          originalFile: fileInfo.toPlatformFile(),
          maxWidth: maxWidth.toInt()))
      ).then((listPlatformFiles) => listPlatformFiles.whereNotNull().toList());

      if (_isExceedMaxUploadSize(listCompressedImages.totalFilesSize)) {
        if (context.mounted) {
          appToast.showToastErrorMessage(
            context,
            AppLocalizations.of(context).pleaseChooseAnImageSizeCorrectly(
              maxSizeUploadByBytes
            )
          );
        } else {
          logError("IdentityCreatorController::_uploadMultipleFilesToPublicAsset: context is unmounted");
        }
        return;
      }

      await Future.forEach(
        listCompressedImages,
        (platformFile) {
          if (!context.mounted) return null;
          return _insertInlineImage(
            context,
            platformFile,
            maxWidth.toInt(),
            compressedFile: platformFile
          );
        }
      );
    } catch (e) {
      logError("IdentityCreatorController::_uploadMultipleFilesToPublicAsset: error: $e");
    }
  }

  @override
  Future<void> onBeforeUnloadBrowserListener(html.Event event) async {
    if (event is html.BeforeUnloadEvent) {
      event.preventDefault();
    }
  }

  @override
  Future<void> onUnloadBrowserListener(html.Event event) => _saveIdentityCacheOnWebAction();

  @override
  Future<void> onBeforeReconnect() => _saveIdentityCacheOnWebAction();

  Future<void> _saveIdentityCacheOnWebAction() async {
    if (accountId != null && session?.username != null) {
      final cacheArguments = await _generateIdentityAndPublicAssetArguments(
        forCache: true);
      final identityCache = IdentityCache(
        identity: cacheArguments.identity,
        identityActionType: actionType.value,
        isDefault: isDefaultIdentity.value,
        publicAssetsInIdentityArguments: cacheArguments.publicAssetsInIdentityArguments);

      consumeState(_saveIdentityCacheOnWebInteractor.execute(
        accountId!,
        session!.username,
        identityCache: identityCache
      ));
    }
  }
}