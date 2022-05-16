import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/identity_creator_controller.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/model/signature_type.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/widgets/identity_drop_list_field_builder.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/widgets/identity_field_no_editable_builder.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/widgets/identity_input_field_builder.dart';
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
            body: SafeArea(
              child: ClipRRect(
                  borderRadius: const BorderRadius.only(topRight: Radius.circular(14), topLeft: Radius.circular(14)),
                  child: _buildBodyMobile(context)
              ),
            )
        ),
        landscapeMobile: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.zero),
                  child: _buildBodyMobile(context)
              ),
            )
        ),
        tablet: Scaffold(
            backgroundColor: Colors.black38,
            body: Align(alignment: Alignment.center, child: Card(
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
            )
        ),
        tabletLarge: Scaffold(
            backgroundColor: Colors.black38,
            body: Align(alignment: Alignment.center, child: Card(
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
            )
        ),
        desktop: Scaffold(
            backgroundColor: Colors.black38,
            body: Align(alignment: Alignment.center, child: Card(
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
            child: Obx(() => Text(controller.actionType.value == IdentityActionType.create
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
                  Expanded(child: Obx(() => (IdentityDropListFieldBuilder(
                          _imagePaths,
                          AppLocalizations.of(context).bcc_to_address,
                          controller.bccOfIdentity.value,
                          controller.listEmailAddressOfReplyTo)
                      ..addOnSelectEmailAddressDropListAction((emailAddress) =>
                          controller.updateBccOfIdentity(emailAddress)))
                    .build())),
                ]),
                const SizedBox(height: 32),
                Row(children: [
                  Text(AppLocalizations.of(context).signature,
                      style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                          color: AppColor.colorContentEmail)),
                  const Spacer(),
                  Obx(() => buildTextButton(
                      AppLocalizations.of(context).plain_text,
                      textStyle: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: controller.signatureType.value == SignatureType.plainText
                              ? AppColor.colorContentEmail
                              : AppColor.colorHintSearchBar),
                      backgroundColor: controller.signatureType.value == SignatureType.plainText
                          ? AppColor.emailAddressChipColor
                          : Colors.transparent,
                      width: 85,
                      height: 30,
                      radius: 10,
                      onTap: () => controller.selectSignatureType(SignatureType.plainText))),
                  const SizedBox(width: 10),
                  Obx(() => buildTextButton(
                      AppLocalizations.of(context).html_template,
                      textStyle: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: controller.signatureType.value == SignatureType.htmlTemplate
                              ? AppColor.colorContentEmail
                              : AppColor.colorHintSearchBar),
                      backgroundColor: controller.signatureType.value == SignatureType.htmlTemplate
                          ? AppColor.emailAddressChipColor
                          : Colors.transparent,
                      width: 110,
                      height: 30,
                      radius: 10,
                      onTap: () => controller.selectSignatureType(SignatureType.htmlTemplate))),
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
                          SizedBox(
                            height: 230,
                            child: (TextFieldBuilder()
                                ..key(const Key('signature_plain_text_editor'),)
                                ..cursorColor(Colors.black)
                                ..addController(controller.signaturePlainEditorController)
                                ..textStyle(const TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black,
                                    fontSize: 16))
                                ..maxLines(null))
                              .build())
                        else
                          HtmlEditor(
                            key: const Key('signature_html_editor'),
                            controller: controller.signatureHtmlEditorController,
                            htmlEditorOptions: const HtmlEditorOptions(
                              hint: '',
                              darkMode: false,
                            ),
                            blockQuotedContent: controller.contentHtmlEditor ?? '<p></p>',
                            htmlToolbarOptions: const HtmlToolbarOptions(
                              toolbarPosition: ToolbarPosition.custom,
                            ),
                            otherOptions: const OtherOptions(height: 230),
                            callbacks: Callbacks(onInit: () {
                              controller.signatureHtmlEditorController.setFullScreen();
                            }, onChangeContent: (String? changed) {
                              controller.updateContentHtmlEditor(changed);
                            }, onFocus: () {
                              FocusManager.instance.primaryFocus?.unfocus();
                              Future.delayed(const Duration(milliseconds: 500), () {
                                controller.signatureHtmlEditorController.setFocus();
                              });
                            }),
                          )
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
                      controller.actionType.value == IdentityActionType.create
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
                child: Text(AppLocalizations.of(context).new_identity.inCaps,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 21, color: Colors.black))),
            const SizedBox(height: 8),
            Expanded(child: SingleChildScrollView(
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
                          AppLocalizations.of(context).reply_to_address,
                          controller.replyToOfIdentity.value,
                          controller.listEmailAddressOfReplyTo)
                      ..addOnSelectEmailAddressDropListAction((newEmailAddress) =>
                          controller.updaterReplyToOfIdentity(newEmailAddress)))
                    .build()),
                  const SizedBox(height: 24),
                  Obx(() => (IdentityDropListFieldBuilder(
                          _imagePaths,
                          AppLocalizations.of(context).bcc_to_address,
                          controller.bccOfIdentity.value,
                          controller.listEmailAddressOfReplyTo)
                      ..addOnSelectEmailAddressDropListAction((newEmailAddress) =>
                          controller.updateBccOfIdentity(newEmailAddress)))
                    .build()),
                  const SizedBox(height: 32),
                  Text(AppLocalizations.of(context).signature,
                      style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                          color: AppColor.colorContentEmail)),
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Obx(() => buildTextButton(
                        AppLocalizations.of(context).plain_text,
                        textStyle: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: controller.signatureType.value == SignatureType.plainText
                                ? AppColor.colorContentEmail
                                : AppColor.colorHintSearchBar),
                        backgroundColor: controller.signatureType.value == SignatureType.plainText
                            ? AppColor.emailAddressChipColor
                            : Colors.transparent,
                        width: 85,
                        height: 30,
                        radius: 10,
                        onTap: () => controller.selectSignatureType(SignatureType.plainText))),
                    const SizedBox(width: 10),
                    Obx(() => buildTextButton(
                        AppLocalizations.of(context).html_template,
                        textStyle: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: controller.signatureType.value == SignatureType.htmlTemplate
                                ? AppColor.colorContentEmail
                                : AppColor.colorHintSearchBar),
                        backgroundColor: controller.signatureType.value == SignatureType.htmlTemplate
                            ? AppColor.emailAddressChipColor
                            : Colors.transparent,
                        width: 110,
                        height: 30,
                        radius: 10,
                        onTap: () => controller.selectSignatureType(SignatureType.htmlTemplate))),
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
                            SizedBox(
                                height: 230,
                                child: (TextFieldBuilder()
                                  ..key(const Key('signature_plain_text_editor'),)
                                  ..cursorColor(Colors.black)
                                  ..addController(controller.signaturePlainEditorController)
                                  ..textStyle(const TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black,
                                      fontSize: 16))
                                  ..maxLines(null))
                                .build())
                          else
                            HtmlEditor(
                              key: const Key('signature_html_editor'),
                              controller: controller.signatureHtmlEditorController,
                              htmlEditorOptions: const HtmlEditorOptions(
                                  hint: '',
                                  darkMode: false,
                              ),
                              blockQuotedContent: controller.contentHtmlEditor ?? '<p></p>',
                              htmlToolbarOptions: const HtmlToolbarOptions(
                                toolbarPosition: ToolbarPosition.custom,
                              ),
                              otherOptions: const OtherOptions(height: 230),
                              callbacks: Callbacks(onInit: () {
                                controller.signatureHtmlEditorController.setFullScreen();
                              }, onChangeContent: (String? changed) {
                                controller.updateContentHtmlEditor(changed);
                              }, onFocus: () {
                                FocusManager.instance.primaryFocus?.unfocus();
                                Future.delayed(const Duration(milliseconds: 500), () {
                                  controller.signatureHtmlEditorController.setFocus();
                                });
                              }),
                            )
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
                                    color: AppColor.colorTextButton),
                                backgroundColor: AppColor.emailAddressChipColor,
                                width: 128,
                                height: 44,
                                radius: 10,
                                onTap: () => controller.closeView(context)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Obx(() => buildTextButton(
                                controller.actionType.value == IdentityActionType.create
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
}