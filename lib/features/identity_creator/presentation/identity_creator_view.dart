import 'dart:math' as math;

import 'package:core/presentation/extensions/capitalize_extension.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:core/presentation/views/responsive/responsive_widget.dart';
import 'package:core/utils/html/html_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart' as html_editor_browser;
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:rich_text_composer/rich_text_composer.dart';
import 'package:rich_text_composer/views/widgets/rich_text_keyboard_toolbar.dart';
import 'package:tmail_ui_user/features/composer/presentation/mixin/rich_text_button_mixin.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/toolbar_rich_text_builder.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/identity_creator_controller.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/widgets/compress_image_loading_bar_widget.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/widgets/identity_drop_list_field_builder.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/widgets/identity_field_no_editable_builder.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/widgets/identity_input_field_builder.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/widgets/identity_input_with_drop_list_field_builder.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/widgets/set_default_identity_checkbox_builder.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_all_identities_state.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/identity_action_type.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

class IdentityCreatorView extends GetWidget<IdentityCreatorController>
    with RichTextButtonMixin {

  @override
  final controller = Get.find<IdentityCreatorController>();

  IdentityCreatorView({super.key});

  @override
  Widget build(BuildContext context) {
    final responsiveWidget = ResponsiveWidget(
      responsiveUtils: controller.responsiveUtils,
      mobile: Scaffold(
        backgroundColor: Colors.black38,
        body: GestureDetector(
          onTap: () => controller.clearFocusEditor(context),
          child: Card(
            margin: EdgeInsets.zero,
            borderOnForeground: false,
            color: Colors.transparent,
            child: SafeArea(
              top: PlatformInfo.isMobile,
              bottom: false,
              left: false,
              right: false,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  topLeft: Radius.circular(16)),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(16),
                      topLeft: Radius.circular(16)
                    ),
                  ),
                  child: _buildBodyView(context),
                ),
              ),
            ),
          ),
        ),
      ),
      landscapeMobile: Scaffold(
        backgroundColor: Colors.white,
        body: GestureDetector(
          onTap: () => controller.clearFocusEditor(context),
          child: SafeArea(
            child: _buildBodyView(context),
          ),
        )
      ),
      tablet: Scaffold(
        backgroundColor: Colors.black38,
        body: GestureDetector(
          onTap: () => controller.clearFocusEditor(context),
          child: Center(
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 24),
              child: Card(
                color: Colors.transparent,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16))
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(16))
                  ),
                  width: math.max(controller.responsiveUtils.getSizeScreenWidth(context) * 0.4, 700),
                  height: controller.responsiveUtils.getSizeScreenHeight(context) * 0.8,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    child: _buildBodyView(context)
                  )
                )
              ),
            )
          )
        ),
      ),
      desktop: Scaffold(
        backgroundColor: Colors.black38,
        body: GestureDetector(
          onTap: () => controller.clearFocusEditor(context),
          child: Center(child: Card(
            color: Colors.transparent,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16))
            ),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(16))
              ),
              width: math.max(controller.responsiveUtils.getSizeScreenWidth(context) * 0.4, 800),
              height: controller.responsiveUtils.getSizeScreenHeight(context) * 0.8,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                child: _buildBodyView(context)
              )
            )
          )),
        )
      )
    );

    if (PlatformInfo.isWeb) {
      return responsiveWidget;
    } else {
      return KeyboardRichText(
        keyBroadToolbar: RichTextKeyboardToolBar(
          titleBack: AppLocalizations.of(context).titleFormat,
          backgroundKeyboardToolBarColor: PlatformInfo.isIOS
            ? AppColor.colorBackgroundKeyboard
            : AppColor.colorBackgroundKeyboardAndroid,
          isLandScapeMode: controller.responsiveUtils.isLandscapeMobile(context),
          richTextController: controller.richTextMobileTabletController!.richTextController,
          titleQuickStyleBottomSheet: AppLocalizations.of(context).titleQuickStyles,
          titleBackgroundBottomSheet: AppLocalizations.of(context).titleBackground,
          titleForegroundBottomSheet: AppLocalizations.of(context).titleForeground,
          titleFormatBottomSheet: AppLocalizations.of(context).titleFormat,
          insertImage: () => controller.pickImage(context),
        ),
        richTextController: controller.richTextMobileTabletController!.richTextController,
        paddingChild: EdgeInsets.zero,
        child: responsiveWidget
      );
    }
  }

  Widget _buildBodyView(BuildContext context) {
    final bodyCreatorView = SingleChildScrollView(
      controller: controller.scrollController,
      physics: const ClampingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(vertical: 12, horizontal: 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Obx(() => IdentityInputFieldBuilder(
            AppLocalizations.of(context).name,
            controller.errorNameIdentity.value,
            AppLocalizations.of(context).required,
            editingController: controller.inputNameIdentityController,
            focusNode: controller.inputNameIdentityFocusNode,
            isMandatory: true,
            onChangeInputNameAction: (value) => controller.updateNameIdentity(context, value)
          )),
          const SizedBox(height: 24),
          Obx(() {
            if (controller.actionType.value == IdentityActionType.create) {
              return IdentityDropListFieldBuilder(
                controller.imagePaths,
                AppLocalizations.of(context).email.inCaps,
                controller.emailOfIdentity.value,
                controller.listEmailAddressDefault,
                onSelectItemDropList: controller.updateEmailOfIdentity);
            } else {
              return IdentityFieldNoEditableBuilder(
                AppLocalizations.of(context).email.inCaps,
                controller.emailOfIdentity.value);
            }
          }),
          const SizedBox(height: 24),
          Obx(() => IdentityDropListFieldBuilder(
            controller.imagePaths,
            AppLocalizations.of(context).reply_to,
            controller.replyToOfIdentity.value,
            controller.listEmailAddressOfReplyTo,
            onSelectItemDropList: controller.updaterReplyToOfIdentity
          )),
          const SizedBox(height: 24),
          Obx(() => IdentityInputWithDropListFieldBuilder(
            AppLocalizations.of(context).bcc_to,
            controller.errorBccIdentity.value,
            controller.inputBccIdentityController,
            focusNode: controller.inputBccIdentityFocusNode,
            onSelectedSuggestionAction: (newEmailAddress) {
              controller.inputBccIdentityController.text = newEmailAddress?.email ?? '';
              controller.updateBccOfIdentity(newEmailAddress);
            },
            onChangeInputSuggestionAction: (pattern) {
              controller.validateInputBccAddress(context, pattern);
              if (pattern == null || pattern.trim().isEmpty) {
                controller.updateBccOfIdentity(null);
              } else {
                controller.updateBccOfIdentity(EmailAddress(null, pattern));
              }
            },
            onSuggestionCallbackAction: controller.getSuggestionEmailAddress
          )),
          const SizedBox(height: 32),
          Text(AppLocalizations.of(context).signature,
            style: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 14,
              color: AppColor.colorContentEmail,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColor.colorInputBorderCreateMailbox),
            ),
            padding: const EdgeInsetsDirectional.all(16),
            child: _buildSignatureHtmlTemplate(context),
          ),
          const SizedBox(height: 12),
          if (controller.isMobile(context))
            _buildActionButtonMobile(context),
          if (PlatformInfo.isMobile)
            Obx(() {
              if (controller.isMobileEditorFocus.isTrue) {
                return const SizedBox(height: 48);
              } else {
                return const SizedBox.shrink();
              }
            })
        ]),
      ),
    );

    return GestureDetector(
      onTap: () => controller.clearFocusEditor(context),
      child: Column(children: [
        _buildHeaderView(context),
        Expanded(child: PointerInterceptor(child: bodyCreatorView)),
        if (!controller.isMobile(context)) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _buildActionButtonDesktop(context),
          ),
          const SizedBox(height: 12),
        ],
      ]),
    );
  }

  Widget _buildHeaderView(BuildContext context) {
    return Container(
      color: Colors.white,
      height: 52,
      child: Row(children: [
        const SizedBox(width: 40),
        Expanded(child: Obx(() {
          return Text(
            controller.actionType.value == IdentityActionType.create
              ? AppLocalizations.of(context).createNewIdentity.inCaps
              : AppLocalizations.of(context).edit_identity.inCaps,
            maxLines: 1,
            textAlign: TextAlign.center,
            overflow: CommonTextStyle.defaultTextOverFlow,
            softWrap: CommonTextStyle.defaultSoftWrap,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black
            ));
        })),
        buildIconWeb(
          iconSize: 24,
          icon: SvgPicture.asset(
            controller.imagePaths.icComposerClose,
            fit: BoxFit.fill,
            colorFilter: AppColor.colorDeleteContactIcon.asFilter()
          ),
          tooltip: AppLocalizations.of(context).close,
          onTap: () => controller.closeView(context)),
      ]),
    );
  }

  Widget _buildSignatureHtmlTemplate(BuildContext context) {
    final htmlEditor = PlatformInfo.isWeb 
      ? _buildHtmlEditorWeb(context, controller.contentHtmlEditor ?? '')
      : _buildHtmlEditor(context, initialContent: controller.contentHtmlEditor ?? '');

    return Column(
      children: [
        if (PlatformInfo.isWeb)
          ToolbarRichTextWebBuilder(
            richTextWebController: controller.richTextWebController!,
            padding: const EdgeInsets.only(bottom: 12),
            extendedOption: [
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 4.0),
                child: buildWrapIconStyleText(
                  icon: buildIconWithTooltip(
                    path: controller.imagePaths.icAddPicture,
                    tooltip: AppLocalizations.of(context).insertImage
                  ),
                  hasDropdown: false,
                  onTap: () => controller.pickImage(context)
                ),
              ),
            ]
          ),
        Stack(
          children: [
            htmlEditor,
            Obx(() => Center(
              child: CompressImageLoadingBarWidget(
                isCompressing: controller.isCompressingInlineImage.value,
              ),
            ))
          ]
        ),
      ],
    );
  }

  Widget _buildHtmlEditorWeb(BuildContext context, String initContent) {
    return html_editor_browser.HtmlEditor(
      key: const Key('identity_create_editor_web'),
      controller: controller.richTextWebController!.editorController,
      htmlEditorOptions: html_editor_browser.HtmlEditorOptions(
        shouldEnsureVisible: true,
        hint: '',
        darkMode: false,
        initialText: initContent.isEmpty ? null : initContent,
        customBodyCssStyle: HtmlUtils.customCssStyleHtmlEditor(direction: AppUtils.getCurrentDirection(context)),
      ),
      htmlToolbarOptions: const html_editor_browser.HtmlToolbarOptions(
        toolbarType: html_editor_browser.ToolbarType.hide,
        defaultToolbarButtons: []
      ),
      otherOptions: const html_editor_browser.OtherOptions(height: 200),
      callbacks: html_editor_browser.Callbacks(
        onBeforeCommand: controller.updateContentHtmlEditor,
        onChangeContent: (content) {
          controller.updateContentHtmlEditor(content);
          if (!controller.isLoadSignatureCompleted) {
            controller.onLoadSignatureCompleted(content);
          }
        },
        onInit: () {
          controller.richTextWebController?.editorController.setFullScreen();
          controller.updateContentHtmlEditor(initContent);
        }, onFocus: () {
          FocusManager.instance.primaryFocus?.unfocus();
          Future.delayed(const Duration(milliseconds: 500), () {
            controller.richTextWebController?.editorController.setFocus();
          });
          controller.richTextWebController?.closeAllMenuPopup();
        },
        onChangeSelection: controller.richTextWebController?.onEditorSettingsChange,
        onChangeCodeview: controller.updateContentHtmlEditor
      ),
    );
  }

  Widget _buildHtmlEditor(BuildContext context, {String? initialContent}) {
    return HtmlEditor(
      key: controller.htmlKey,
      minHeight: controller.htmlEditorMinHeight,
      addDefaultSelectionMenuItems: false,
      initialContent: initialContent ?? '',
      customStyleCss: HtmlUtils.customCssStyleHtmlEditor(direction: AppUtils.getCurrentDirection(context)),
      onCreated: (editorApi) => controller.initRichTextForMobile(context, editorApi),
    );
  }

  Widget _buildActionButtonDesktop(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildCheckboxIdentityDefault(context)),
        const SizedBox(width: 12),
        _buildCancelButton(context, width: 156),
        const SizedBox(width: 12),
        _buildSaveButton(context, width: 156)
      ],
    );
  }

  Widget _buildActionButtonMobile(BuildContext context) {
    return Column(children: [
      _buildCheckboxIdentityDefault(context),
      const SizedBox(height: 24),
      Row(children: [
        Expanded(child: _buildCancelButton(context)),
        const SizedBox(width: 12),
        Expanded(child: _buildSaveButton(context))
      ])
    ]);
  }

  Widget _buildCheckboxIdentityDefault(BuildContext context) {
    return Obx(() {
      if (controller.isDefaultIdentitySupported.isTrue) {
        return SetDefaultIdentityCheckboxBuilder(
          imagePaths: controller.imagePaths,
          isCheck: controller.isDefaultIdentity.value,
          onCheckboxChanged: controller.onCheckboxChanged);
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  Widget _buildCancelButton(BuildContext context, {double? width}) {
    return buildTextButton(
      AppLocalizations.of(context).cancel,
      textStyle: const TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 17,
        color: AppColor.colorTextButton,
      ),
      backgroundColor: AppColor.emailAddressChipColor,
      width: width ?? 128,
      height: 44,
      radius: 10,
      onTap: () => controller.closeView(context),
    );
  }

  Widget _buildSaveButton(BuildContext context, {double? width}) {
    return Obx(() => controller.viewState.value.fold(
      (failure) => buildTextButton(
        controller.actionType.value == IdentityActionType.create
          ? AppLocalizations.of(context).create
          : AppLocalizations.of(context).save,
        width: width ?? 128,
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
            width: width ?? 128,
            height: 44,
            radius: 10,
            onTap: () => controller.createNewIdentity(context));
        }
      }
    ));
  }
}