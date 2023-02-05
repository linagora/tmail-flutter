import 'dart:math';

import 'package:core/core.dart';
import 'package:enough_html_editor/enough_html_editor.dart' as html_editor_mobile;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart' as html_editor_browser;
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:rich_text_composer/views/keyboard_richtext.dart';
import 'package:rich_text_composer/views/widgets/rich_text_keyboard_toolbar.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/toolbar_rich_text_builder.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/identity_creator_controller.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/model/identity_creator_arguments.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/model/signature_type.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/widgets/identity_drop_list_field_builder.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/widgets/identity_field_no_editable_builder.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/widgets/identity_input_field_builder.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/widgets/identity_input_with_drop_list_field_builder.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/widgets/set_default_identity_checkbox_builder.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_all_identities_state.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/identity_action_type.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class IdentityCreatorView extends GetWidget<IdentityCreatorController> {

  final _imagePaths = Get.find<ImagePaths>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();

  @override
  final controller = Get.find<IdentityCreatorController>();

  IdentityCreatorView({Key? key}) : super(key: key) {
    controller.arguments = Get.arguments;
  }

  IdentityCreatorView.fromArguments(
      IdentityCreatorArguments arguments, {
      Key? key,
      OnCreatedIdentityCallback? onCreatedIdentityCallback,
      VoidCallback? onDismissCallback
  }) : super(key: key) {
    controller.arguments = arguments;
    controller.onCreatedIdentityCallback = onCreatedIdentityCallback;
    controller.onDismissIdentityCreator = onDismissCallback;
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
        responsiveUtils: _responsiveUtils,
        mobile: GestureDetector(
          onTap: () => controller.clearFocusEditor(context),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.95,
            child: SafeArea(
                child: BuildUtils.isWeb ? Scaffold(body: _buildBodyMobile(context)) : _buildBodyMobile(context),
              ),
            )
        ),
        landscapeMobile: Scaffold(
            backgroundColor: Colors.white,
            body: GestureDetector(
              onTap: () => controller.clearFocusEditor(context),
              child: SafeArea(
                child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.zero),
                    child: _buildBodyMobile(context)
                ),
              ),
            )
        ),
        tablet: Scaffold(
            backgroundColor: Colors.black.withAlpha(24),
            body: GestureDetector(
              onTap: () => controller.clearFocusEditor(context),
              child: Center(child: Card(
                  color: Colors.transparent,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                  child: Container(
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(16))),
                      width: _responsiveUtils.getSizeScreenWidth(context) * 0.85,
                      height: _responsiveUtils.getSizeScreenHeight(context) * 0.6,
                      child: ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(16)),
                          child: _buildBodyMobile(context)
                      )
                  )
              ))
            ),
        ),
        tabletLarge: Scaffold(
            backgroundColor: Colors.black.withAlpha(24),
            body: GestureDetector(
              onTap: () => controller.clearFocusEditor(context),
              child: Center(child: Card(
                  color: Colors.transparent,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                  child: Container(
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(16))),
                      width: _responsiveUtils.getSizeScreenWidth(context) * 0.85,
                      height: _responsiveUtils.getSizeScreenHeight(context) * 0.6,
                      child: ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(16)),
                          child: _buildBodyMobile(context)
                      )
                  )
              ))
            )
        ),
        landscapeTablet: Scaffold(
            backgroundColor: Colors.black.withAlpha(24),
            body: GestureDetector(
              onTap: () => controller.clearFocusEditor(context),
              child: Center(child: Card(
                  color: Colors.transparent,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                  child: Container(
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(16))),
                      width: _responsiveUtils.getSizeScreenWidth(context) * 0.65,
                      height: _responsiveUtils.getSizeScreenHeight(context) * 0.8,
                      child: ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(16)),
                          child: _buildBodyMobile(context)
                      )
                  )
              ))
            )
        ),
        desktop: Scaffold(
            backgroundColor: Colors.black.withAlpha(24),
            body: GestureDetector(
              onTap: () => controller.clearFocusEditor(context),
              child: Center(child: Card(
                  color: Colors.transparent,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                  child: Container(
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(16))),
                      width: max(_responsiveUtils.getSizeScreenWidth(context) * 0.4, 600),
                      height: _responsiveUtils.getSizeScreenHeight(context) * 0.75,
                      child: ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(16)),
                          child: _buildBodyMobile(context)
                      )
                  )
              )),
            )
        )
    );
  }

  Widget _buildBodyMobile(BuildContext context) {
    final bodyCreatorView = SingleChildScrollView(
      controller: controller.scrollController,
      physics: const ClampingScrollPhysics(),
      child: Padding(
      padding: const EdgeInsets.all(24.0),
        child: Column(children: [
          Obx(() => (IdentityInputFieldBuilder(
            AppLocalizations.of(context).name,
            controller.errorNameIdentity.value,
          AppLocalizations.of(context).required,
            editingController: controller.inputNameIdentityController,
            focusNode: controller.inputNameIdentityFocusNode,
            isMandatory: true)
            ..addOnChangeInputNameAction((value) => controller.updateNameIdentity(context, value)))
          .build()),
          const SizedBox(height: 24),
          Obx(() {
            if (controller.actionType.value == IdentityActionType.create) {
              return (IdentityDropListFieldBuilder(
                  _imagePaths,
                  AppLocalizations.of(context).email.inCaps,
                  controller.emailOfIdentity.value,
                  controller.listEmailAddressDefault)
                ..addOnSelectEmailAddressDropListAction((emailAddress) =>
                    controller.updateEmailOfIdentity(emailAddress))
              ).build();
            } else {
              return IdentityFieldNoEditableBuilder(
                  AppLocalizations.of(context).email.inCaps,
                  controller.emailOfIdentity.value
              ).build();
            }
          }),
          const SizedBox(height: 24),
          Obx(() => (IdentityDropListFieldBuilder(
              _imagePaths,
              AppLocalizations.of(context).reply_to,
              controller.replyToOfIdentity.value,
              controller.listEmailAddressOfReplyTo)
            ..addOnSelectEmailAddressDropListAction((newEmailAddress) =>
                controller.updaterReplyToOfIdentity(newEmailAddress)))
          .build()),
          const SizedBox(height: 24),
          Obx(() => (IdentityInputWithDropListFieldBuilder(
              AppLocalizations.of(context).bcc_to,
              controller.errorBccIdentity.value,
              controller.inputBccIdentityController)
            ..addOnSelectedSuggestionAction((newEmailAddress) {
              controller.inputBccIdentityController?.text = newEmailAddress?.email ?? '';
              controller.updateBccOfIdentity(newEmailAddress);
            })
            ..addOnChangeInputSuggestionAction((pattern) {
              controller.validateInputBccAddress(context, pattern);
              if (pattern == null || pattern.trim().isEmpty) {
                controller.updateBccOfIdentity(null);
              } else {
                controller.updateBccOfIdentity(EmailAddress(null, pattern));
              }
            })
            ..addOnSuggestionCallbackAction((pattern) =>
                controller.getSuggestionEmailAddress(pattern)))
          .build()
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Text(AppLocalizations.of(context).signature,
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                  color: AppColor.colorContentEmail,
                ),
              ),
              Expanded(
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Obx(() => _buildSignatureButton(context, SignatureType.plainText)),
                  const SizedBox(width: 10),
                  Obx(() => _buildSignatureButton(context, SignatureType.htmlTemplate)),
                ]),
              )
            ],
          ),
          const SizedBox(height: 8),
          Obx(() => PointerInterceptor(
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColor.colorInputBorderCreateMailbox),
                color: Colors.white,
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Stack(
                children: [
                  if (controller.signatureType.value == SignatureType.plainText)
                    _buildSignaturePlainTextTemplate(context)
                  else
                    _buildSignatureHtmlTemplate(context)
                ]
              ),
            ),
          )),
          if (_responsiveUtils.isTablet(context) || _responsiveUtils.isMobile(context))...[
            Obx(() => Padding(
            padding: const EdgeInsets.only(top: 27, bottom: 135),
            child: SetDefaultIdentityCheckboxBuilder(
              imagePaths: _imagePaths,
              isCheck: controller.isDefaultIdentity.value,
              onCheckboxChanged: controller.onCheckboxChanged),
            )),
            const SizedBox(height: 24),
            Container(
              alignment: Alignment.center,
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: buildTextButton(
                      AppLocalizations.of(context).cancel,
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 17,
                        color: AppColor.colorTextButton,
                      ),
                      backgroundColor: AppColor.emailAddressChipColor,
                      width: 128,
                      height: 44,
                      radius: 10,
                      onTap: () => controller.closeView(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() => controller.viewState.value.fold(
                      (failure) => buildTextButton(
                        controller.actionType.value == IdentityActionType.create
                            ? AppLocalizations.of(context).create
                            : AppLocalizations.of(context).save,
                        width: 128,
                        height: 44,
                        radius: 10,
                        onTap: () => controller.createNewIdentity(context)),
                      (success) {
                        if (success is GetAllIdentitiesLoading) {
                          return const Center(
                              key: Key('create_loading_icon'),
                              child: CircularProgressIndicator(color: AppColor.primaryColor));
                        } else {
                          return buildTextButton(
                            controller.actionType.value == IdentityActionType.create
                                ? AppLocalizations.of(context).create
                                : AppLocalizations.of(context).save,
                            width: 128,
                            height: 44,
                            radius: 10,
                            onTap: () => controller.createNewIdentity(context));
                        }
                      }
                    )),
                  ),
                ]
              ),
          )] else ...[
            _buildActionBottomDesktop(context)
          ]
        ]),
      ),
    );

    return GestureDetector(
      onTap: () => controller.clearFocusEditor(context),
      child: Stack(
          children: [
            Column(children: [
              Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Obx(() {
                    return Text(controller.actionType.value == IdentityActionType.create
                        ? AppLocalizations.of(context).createNewIdentity.inCaps
                        : AppLocalizations.of(context).edit_identity.inCaps,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black));
                  })),
              const SizedBox(height: 8),
              Expanded(
                child: BuildUtils.isWeb
                  ? PointerInterceptor(child: bodyCreatorView)
                  : KeyboardRichText(
                      keyBroadToolbar: RichTextKeyboardToolBar(
                        titleBack: AppLocalizations.of(context).titleFormat,
                        backgroundKeyboardToolBarColor: AppColor.colorBackgroundKeyboard,
                        isLandScapeMode: _responsiveUtils.isLandscapeMobile(context),
                        richTextController: controller.keyboardRichTextController,
                        titleQuickStyleBottomSheet: AppLocalizations.of(context).titleQuickStyles,
                        titleBackgroundBottomSheet: AppLocalizations.of(context).titleBackground,
                        titleForegroundBottomSheet: AppLocalizations.of(context).titleForeground,
                        titleFormatBottomSheet: AppLocalizations.of(context).titleFormat,
                      ),
                      richTextController: controller.keyboardRichTextController,
                      child: bodyCreatorView),
              ),
            ]),
            Positioned(top: 2, right: 8,
                child: buildIconWeb(
                    iconSize: 24,
                    icon: SvgPicture.asset(_imagePaths.icComposerClose, fit: BoxFit.fill, color: AppColor.colorDeleteContactIcon),
                    tooltip: AppLocalizations.of(context).close,
                    onTap: () => controller.closeView(context)))
          ]
      ),
    );
  }

  Widget _buildSignatureButton(BuildContext context, SignatureType signatureType) {
    return buildButtonWrapText(
        signatureType.getTitle(context),
        textStyle: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: controller.signatureType.value == signatureType
                ? AppColor.colorContentEmail
                : AppColor.colorHintSearchBar),
        bgColor: controller.signatureType.value == signatureType
            ? AppColor.emailAddressChipColor
            : Colors.transparent,
        height: 30,
        radius: 10,
        onTap: () => controller.selectSignatureType(context, signatureType));
  }

  Widget _buildSignaturePlainTextTemplate(BuildContext context) {
    if (BuildUtils.isWeb) {
      return SizedBox(
        height: 230,
        child: (TextFieldBuilder()
            ..key(const Key('signature_plain_text_editor'))
            ..cursorColor(Colors.black)
            ..addController(controller.signaturePlainEditorController)
            ..textStyle(const TextStyle(
                fontWeight: FontWeight.normal,
                color: Colors.black,
                fontSize: 16))
            ..maxLines(null))
          .build(),
      );
    } else {
      return(TextFieldBuilder()
          ..key(const Key('signature_plain_text_editor'))
          ..cursorColor(Colors.black)
          ..addController(controller.signaturePlainEditorController)
          ..textStyle(const TextStyle(
              fontWeight: FontWeight.normal,
              color: Colors.black,
              fontSize: 16))
          ..minLines(12)
          ..maxLines(null))
        .build();
    }
  }

  Widget _buildSignatureHtmlTemplate(BuildContext context) {
    final htmlEditor = BuildUtils.isWeb 
        ? _buildHtmlEditorWeb(context, controller.contentHtmlEditor ?? '')
        : _buildHtmlEditor(context, initialContent: controller.contentHtmlEditor ?? '');

    return SizedBox(
      height: 160,
      child: Column(
        children: [
          if(BuildUtils.isWeb)
            ToolbarRichTextWebBuilder(richTextWebController: controller.richTextWebController),
          htmlEditor,
        ],
      ),
    );
  }

  Widget _buildHtmlEditorWeb(BuildContext context, String initContent) {
    log('IdentityCreatorView::_buildHtmlEditorWeb(): initContent: $initContent');
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: _responsiveUtils.isMobile(context) ? 8 : 10),
        child: html_editor_browser.HtmlEditor(
          key: const Key('identity_create_editor_web'),
          controller: controller.richTextWebController.editorController,
          htmlEditorOptions: const HtmlEditorOptions(
            hint: '',
            darkMode: false,
            customBodyCssStyle: bodyCssStyleForEditor),
          blockQuotedContent: initContent,
          htmlToolbarOptions: const HtmlToolbarOptions(
              toolbarType: ToolbarType.hide,
              defaultToolbarButtons: []),
          otherOptions: const OtherOptions(height: 550),
          callbacks: Callbacks(onBeforeCommand: (currentHtml) {
            log('IdentityCreatorView::_buildHtmlEditorWeb(): onBeforeCommand : $currentHtml');
            controller.updateContentHtmlEditor(currentHtml);
          }, onChangeContent: (changed) {
            log('IdentityCreatorView::_buildHtmlEditorWeb(): onChangeContent : $changed');
            controller.updateContentHtmlEditor(changed);
          }, onInit: () {
            log('IdentityCreatorView::_buildHtmlEditorWeb(): onInit');
            controller.updateContentHtmlEditor(initContent);
            controller.richTextWebController.setFullScreenEditor();
            controller.richTextWebController.setEnableCodeView();
          }, onFocus: () {
            log('IdentityCreatorView::_buildHtmlEditorWeb(): onFocus');
            FocusManager.instance.primaryFocus?.unfocus();
            Future.delayed(const Duration(milliseconds: 500), () {
              controller.richTextWebController.editorController.setFocus();
            });
            controller.richTextWebController.closeAllMenuPopup();
          }, onChangeSelection: (settings) {
            controller.richTextWebController.onEditorSettingsChange(settings);
          }, onChangeCodeview: (contentChanged) {
            log('IdentityCreatorView::_buildHtmlEditorWeb(): onChangeCodeView : $contentChanged');
            controller.updateContentHtmlEditor(contentChanged);
          }),
        )
      )
    );
  }

  Widget _buildHtmlEditor(BuildContext context, {String? initialContent}) {
    final richTextMobileTabletController = controller.richTextMobileTabletController;
    return Focus(
      focusNode: controller.htmlEditorNode,
      child: html_editor_mobile.HtmlEditor(
        key: const Key('identity_create_editor'),
        minHeight: 111,
        addDefaultSelectionMenuItems: false,
        initialContent: initialContent ?? '',
        onCreated: (editorApi) {
          richTextMobileTabletController.htmlEditorApi = editorApi;
            controller.keyboardRichTextController.onCreateHTMLEditor(
              editorApi,
              onEnterKeyDown: controller.onEnterKeyDown,
              context: context,
            );
        },
      )
    );
  }

  Widget _buildActionBottomDesktop(BuildContext context) {
    return Row(
      children: [
        Obx(() {
          return SetDefaultIdentityCheckboxBuilder(
            imagePaths: _imagePaths,
            isCheck: controller.isDefaultIdentity.value,
            onCheckboxChanged: controller.onCheckboxChanged);
        }),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 24.0, bottom: 12.0, left: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: buildTextButton(
                    AppLocalizations.of(context).cancel,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 17,
                      color: AppColor.colorTextButton,
                    ),
                    backgroundColor: AppColor.emailAddressChipColor,
                    width: 156,
                    height: 44,
                    radius: 10,
                    onTap: () => controller.closeView(context),
                  ),
                ),
                buildTextButton(
                  controller.actionType.value == IdentityActionType.create
                      ? AppLocalizations.of(context).create
                      : AppLocalizations.of(context).save,
                  width: 156,
                  height: 44,
                  radius: 10,
                  onTap: () => controller.createNewIdentity(context)),
              ],
            ),
          ),
        )
      ],
    );
  }
}