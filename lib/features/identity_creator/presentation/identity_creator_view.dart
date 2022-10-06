import 'package:core/core.dart';
import 'package:enough_html_editor/enough_html_editor.dart' as html_editor_mobile;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart' as html_editor_browser;
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:rich_text_composer/views/keyboard_richtext.dart';
import 'package:rich_text_composer/views/widgets/rich_text_keyboard_toolbar.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/identity_creator_controller.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/model/signature_type.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/widgets/identity_drop_list_field_builder.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/widgets/identity_field_no_editable_builder.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/widgets/identity_input_field_builder.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/widgets/identity_input_with_drop_list_field_builder.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/identity_action_type.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class IdentityCreatorView extends GetWidget<IdentityCreatorController> {

  final _imagePaths = Get.find<ImagePaths>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();

  IdentityCreatorView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
        responsiveUtils: _responsiveUtils,
        mobile: Scaffold(
            backgroundColor: Colors.white,
            body: GestureDetector(
              onTap: () => controller.clearFocusEditor(context),
              child: SafeArea(
                child: ClipRRect(
                    borderRadius: const BorderRadius.only(topRight: Radius.circular(14), topLeft: Radius.circular(14)),
                    child: _buildBodyMobile(context)
                ),
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
            backgroundColor: Colors.black38,
            body: GestureDetector(
              onTap: () => controller.clearFocusEditor(context),
              child: Align(alignment: Alignment.center, child: Card(
                  color: Colors.transparent,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                  child: Container(
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(16))),
                      width: _responsiveUtils.getSizeScreenWidth(context) * 0.9,
                      height: _responsiveUtils.getSizeScreenHeight(context) * 0.9,
                      child: ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(16)),
                          child: _buildBodyDesktop(context)
                      )
                  )
              )
              ),
            )
        ),
        tabletLarge: Scaffold(
            backgroundColor: Colors.black38,
            body: GestureDetector(
              onTap: () => controller.clearFocusEditor(context),
              child: Align(alignment: Alignment.center, child: Card(
                  color: Colors.transparent,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                  child: Container(
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(16))),
                      width: _responsiveUtils.getSizeScreenWidth(context) * 0.6,
                      height: _responsiveUtils.getSizeScreenHeight(context) * 0.9,
                      child: ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(16)),
                          child: _buildBodyDesktop(context)
                      )
                  )
              )
              ),
            )
        ),
        desktop: Scaffold(
            backgroundColor: Colors.black38,
            body: GestureDetector(
              onTap: () => controller.clearFocusEditor(context),
              child: Align(alignment: Alignment.center, child: Card(
                  color: Colors.transparent,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                  child: Container(
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(16))),
                      width: _responsiveUtils.getSizeScreenWidth(context) * 0.4,
                      height: _responsiveUtils.getSizeScreenHeight(context) * 0.9,
                      child: ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(16)),
                          child: _buildBodyDesktop(context)
                      )
                  )
              )
              ),
            )
        )
    );
  }

  Widget _buildBodyDesktop(BuildContext context) {
    return Stack(
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(left: 24, top: 24),
            child: Obx(() => Text(controller.actionType == IdentityActionType.create
                    ? AppLocalizations.of(context).new_identity.inCaps
                    : AppLocalizations.of(context).edit_identity.inCaps,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.black)))),
          const SizedBox(height: 8),
          Expanded(child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: Obx(() => (IdentityInputFieldBuilder(
                          AppLocalizations.of(context).name,
                          controller.errorNameIdentity.value,
                          editingController: controller.inputNameIdentityController,
                          focusNode: controller.inputNameIdentityFocusNode,
                          isMandatory: true)
                      ..addOnChangeInputNameAction((value) => controller.updateNameIdentity(context, value)))
                    .build())),
                  const SizedBox(width: 24),
                  Expanded(child: Obx(() {
                    if (controller.actionType == IdentityActionType.create) {
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
                  })),
                ]),
                const SizedBox(height: 24),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: Obx(() => (IdentityDropListFieldBuilder(
                          _imagePaths,
                          AppLocalizations.of(context).reply_to_address,
                          controller.replyToOfIdentity.value,
                          controller.listEmailAddressOfReplyTo)
                      ..addOnSelectEmailAddressDropListAction((emailAddress) =>
                          controller.updaterReplyToOfIdentity(emailAddress)))
                    .build())),
                  const SizedBox(width: 24),
                  Expanded(child: Obx(() => (IdentityInputWithDropListFieldBuilder(
                          AppLocalizations.of(context).bcc_to_address,
                          controller.errorBccIdentity.value,
                          controller.inputBccIdentityController)
                      ..addOnSelectedSuggestionAction((newEmailAddress) {
                        controller.inputBccIdentityController.text = newEmailAddress?.email ?? '';
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
                  )),
                ]),
                const SizedBox(height: 32),
                Row(children: [
                  Text(AppLocalizations.of(context).signature,
                      style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                          color: AppColor.colorContentEmail)),
                  const Spacer(),
                  Obx(() => _buildSignatureButton(context, SignatureType.plainText)),
                  const SizedBox(width: 10),
                  Obx(() => _buildSignatureButton(context, SignatureType.htmlTemplate)),
                ]),
                const SizedBox(height: 8),
                Obx(() => Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColor.colorInputBorderCreateMailbox),
                      color: Colors.white),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  child: Stack(
                      children: [
                        if (controller.signatureType.value == SignatureType.plainText)
                          _buildSignaturePlainTextTemplate(context)
                        else
                          _buildSignatureHtmlTemplate(context)
                      ]
                  ),
                ))
              ]),
            ),
          )),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            alignment: Alignment.centerRight,
            color: Colors.white,
            child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildTextButton(
                      AppLocalizations.of(context).cancel,
                      textStyle: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 17,
                          color: AppColor.colorTextButton),
                      backgroundColor: AppColor.emailAddressChipColor,
                      width: 128,
                      height: 44,
                      radius: 10,
                      onTap: () => controller.closeView(context)),
                  const SizedBox(width: 12),
                  Obx(() => buildTextButton(
                      controller.actionType == IdentityActionType.create
                          ? AppLocalizations.of(context).create
                          : AppLocalizations.of(context).save,
                      width: 128,
                      height: 44,
                      radius: 10,
                      onTap: () => controller.createNewIdentity(context))),
                ]
            ),
          )
        ]),
        Positioned(top: 8, right: 8,
            child: buildIconWeb(
              icon: SvgPicture.asset(_imagePaths.icCloseMailbox, fit: BoxFit.fill),
              tooltip: AppLocalizations.of(context).close,
              onTap: () => controller.closeView(context)))
      ]
    );
  }

  Widget _buildBodyMobile(BuildContext context) {
    return Stack(
        children: [
          Column(children: [
            Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(controller.actionType == IdentityActionType.create
                      ? AppLocalizations.of(context).new_identity.inCaps
                      : AppLocalizations.of(context).edit_identity.inCaps,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 21, color: Colors.black))),
            const SizedBox(height: 8),
            Expanded(child: KeyboardRichText(
              child: SingleChildScrollView(
                controller: controller.scrollController,
                physics: const ClampingScrollPhysics(),
                child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(children: [
                  Obx(() => (IdentityInputFieldBuilder(
                    AppLocalizations.of(context).name,
                    controller.errorNameIdentity.value,
                    editingController: controller.inputNameIdentityController,
                    focusNode: controller.inputNameIdentityFocusNode,
                    isMandatory: true)
                    ..addOnChangeInputNameAction((value) => controller.updateNameIdentity(context, value)))
                  .build()),
                  const SizedBox(height: 24),
                  Obx(() {
                    if (controller.actionType == IdentityActionType.create) {
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
                      AppLocalizations.of(context).reply_to_address,
                      controller.replyToOfIdentity.value,
                      controller.listEmailAddressOfReplyTo)
                    ..addOnSelectEmailAddressDropListAction((newEmailAddress) =>
                        controller.updaterReplyToOfIdentity(newEmailAddress)))
                  .build()),
                  const SizedBox(height: 24),
                  Obx(() => (IdentityInputWithDropListFieldBuilder(
                      AppLocalizations.of(context).bcc_to_address,
                      controller.errorBccIdentity.value,
                      controller.inputBccIdentityController)
                    ..addOnSelectedSuggestionAction((newEmailAddress) {
                      controller.inputBccIdentityController.text = newEmailAddress?.email ?? '';
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
                  Text(AppLocalizations.of(context).signature,
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                      color: AppColor.colorContentEmail,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Obx(() => _buildSignatureButton(context, SignatureType.plainText)),
                    const SizedBox(width: 10),
                    Obx(() => _buildSignatureButton(context, SignatureType.htmlTemplate)),
                  ]),
                  const SizedBox(height: 8),
                  Obx(() => Container(
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
                          child: Obx(() => buildTextButton(
                              controller.actionType == IdentityActionType.create
                                  ? AppLocalizations.of(context).create
                                  : AppLocalizations.of(context).save,
                              width: 128,
                              height: 44,
                              radius: 10,
                              onTap: () => controller.createNewIdentity(context))),
                        ),
                      ]
                    ),
                  )
        ]),
      ),
    ),
              richTextController: controller.keyboardRichTextController,
              backgroundKeyboardToolBarColor: AppColor.colorBackgroundKeyboard,
              keyBroadToolbar: RichTextKeyboardToolBar(
                isLandScapeMode: _responsiveUtils.isLandscapeMobile(context),
                richTextController: controller.keyboardRichTextController,
                titleQuickStyleBottomSheet: AppLocalizations.of(context).titleQuickStyles,
                titleBackgroundBottomSheet: AppLocalizations.of(context).titleBackground,
                titleForegroundBottomSheet: AppLocalizations.of(context).titleForeground,
                titleFormatBottomSheet: AppLocalizations.of(context).titleFormat,
              ),
            )),
          ]),
          Positioned(top: 8, right: 8,
              child: buildIconWeb(
                  icon: SvgPicture.asset(_imagePaths.icCloseMailbox, fit: BoxFit.fill),
                  tooltip: AppLocalizations.of(context).close,
                  onTap: () => controller.closeView(context)))
        ]
    );
  }

  Widget _buildSignatureButton(BuildContext context, SignatureType signatureType) {
    return buildTextButton(
        signatureType.getTitle(context),
        textStyle: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: controller.signatureType.value == signatureType
                ? AppColor.colorContentEmail
                : AppColor.colorHintSearchBar),
        backgroundColor: controller.signatureType.value == signatureType
            ? AppColor.emailAddressChipColor
            : Colors.transparent,
        width: signatureType == SignatureType.plainText ? 85 : 110,
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
    if (BuildUtils.isWeb) {
      return html_editor_browser.HtmlEditor(
        key: const Key('signature_html_editor_web'),
        controller: controller.signatureHtmlEditorController,
        htmlEditorOptions: const html_editor_browser.HtmlEditorOptions(
          hint: '',
          darkMode: false,
        ),
        blockQuotedContent: controller.contentHtmlEditor ?? '<p></p>',
        htmlToolbarOptions: const html_editor_browser.HtmlToolbarOptions(
          toolbarPosition: html_editor_browser.ToolbarPosition.custom,
        ),
        otherOptions: const html_editor_browser.OtherOptions(height: 230),
        callbacks: html_editor_browser.Callbacks(onInit: () {
          controller.signatureHtmlEditorController.setFullScreen();
        }, onChangeContent: (String? changed) {
          controller.updateContentHtmlEditor(changed);
        }, onFocus: () {
          FocusManager.instance.primaryFocus?.unfocus();
          Future.delayed(const Duration(milliseconds: 500), () {
            controller.signatureHtmlEditorController.setFocus();
          });
        }),
      );
    } else {
      return html_editor_mobile.HtmlEditor(
        key: controller.htmlKey,
        minHeight: 230,
        onCreated: (htmlEditorController) {
          controller.keyboardRichTextController.onCreateHTMLEditor(
            htmlEditorController,
            onFocus: controller.onFocusHTMLEditor,
            onEnterKeyDown: controller.onEnterKeyDown,
          );
          controller.signatureHtmlEditorMobileController = htmlEditorController;
        },
        initialContent: controller.contentHtmlEditor ?? '',
      );
    }
  }
}