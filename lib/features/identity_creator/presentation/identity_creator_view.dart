import 'dart:math' as math;

import 'package:core/presentation/extensions/capitalize_extension.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/html_transformer/html_utils.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:core/presentation/views/responsive/responsive_widget.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart' as html_editor_browser;
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:rich_text_composer/rich_text_composer.dart';
import 'package:rich_text_composer/views/widgets/rich_text_keyboard_toolbar.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/toolbar_rich_text_builder.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/identity_creator_controller.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/model/identity_creator_arguments.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/widgets/identity_drop_list_field_builder.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/widgets/identity_field_no_editable_builder.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/widgets/identity_input_field_builder.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/widgets/identity_input_with_drop_list_field_builder.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/widgets/set_default_identity_checkbox_builder.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_all_identities_state.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/identity_action_type.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

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
        mobile: Card(
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
              child: GestureDetector(
                onTap: () => controller.clearFocusEditor(context),
                child: Scaffold(
                  backgroundColor: Colors.white,
                  body: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(16),
                        topLeft: Radius.circular(16)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.colorShadowLayerBottom,
                          blurRadius: 96,
                          spreadRadius: 96,
                          offset: Offset.zero),
                        BoxShadow(
                          color: AppColor.colorShadowLayerTop,
                          blurRadius: 2,
                          spreadRadius: 2,
                          offset: Offset.zero),
                      ]),
                    child: _buildBodyMobile(context),
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
            backgroundColor: Colors.black38,
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
            backgroundColor: Colors.black38,
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
            backgroundColor: Colors.black38,
            body: GestureDetector(
              onTap: () => controller.clearFocusEditor(context),
              child: Center(child: Card(
                  color: Colors.transparent,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                  child: Container(
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(16))),
                      width: math.max(_responsiveUtils.getSizeScreenWidth(context) * 0.4, 650),
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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Obx(() => IdentityInputFieldBuilder(
            AppLocalizations.of(context).name,
            controller.errorNameIdentity.value,
            AppLocalizations.of(context).required,
            editingController: controller.inputNameIdentityController,
            focusNode: PlatformInfo.isWeb ? null : controller.inputNameIdentityFocusNode,
            isMandatory: true,
            onChangeInputNameAction: (value) => controller.updateNameIdentity(context, value)
          )),
          const SizedBox(height: 24),
          Obx(() {
            if (controller.actionType.value == IdentityActionType.create) {
              return IdentityDropListFieldBuilder(
                _imagePaths,
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
            _imagePaths,
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
            focusNode: PlatformInfo.isWeb ? null : controller.inputBccIdentityFocusNode,
            onSelectedSuggestionAction: (newEmailAddress) {
              controller.inputBccIdentityController?.text = newEmailAddress?.email ?? '';
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
            child: _buildSignatureHtmlTemplate(context),
          ),
          if (_isMobile(context))
            _buildActionButtonMobile(context)
          else
            _buildActionButtonDesktop(context)
        ]),
      ),
    );

    return GestureDetector(
      onTap: () => controller.clearFocusEditor(context),
      child: Column(children: [
        _buildHeaderView(context),
        Expanded(
          child: PlatformInfo.isWeb
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
                paddingChild: EdgeInsets.zero,
                child: bodyCreatorView),
        ),
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
            _imagePaths.icComposerClose,
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
        if(PlatformInfo.isWeb)
          ToolbarRichTextWebBuilder(
            richTextWebController: controller.richTextWebController,
            padding: const EdgeInsets.only(top: 22, bottom: 8.0, left: 24, right: 12)),
        htmlEditor,
      ],
    );
  }

  Widget _buildHtmlEditorWeb(BuildContext context, String initContent) {
    log('IdentityCreatorView::_buildHtmlEditorWeb(): initContent: $initContent');
    return Padding(
      padding: const EdgeInsets.only(left: 14.0, right: 2.0),
      child: html_editor_browser.HtmlEditor(
        key: const Key('identity_create_editor_web'),
        controller: controller.richTextWebController.editorController,
        htmlEditorOptions: html_editor_browser.HtmlEditorOptions(
          hint: '',
          darkMode: false,
          customBodyCssStyle: HtmlUtils.customCssStyleHtmlEditor(direction: AppUtils.getCurrentDirection(context)),
        ),
        blockQuotedContent: initContent,
        htmlToolbarOptions: const html_editor_browser.HtmlToolbarOptions(
            toolbarType: html_editor_browser.ToolbarType.hide,
            defaultToolbarButtons: []),
        otherOptions: const html_editor_browser.OtherOptions(height: 150),
        callbacks: html_editor_browser.Callbacks(onBeforeCommand: (currentHtml) {
          log('IdentityCreatorView::_buildHtmlEditorWeb(): onBeforeCommand : $currentHtml');
          controller.updateContentHtmlEditor(currentHtml);
        }, onChangeContent: (changed) {
          log('IdentityCreatorView::_buildHtmlEditorWeb(): onChangeContent : $changed');
          controller.updateContentHtmlEditor(changed);
        }, onInit: () {
          log('IdentityCreatorView::_buildHtmlEditorWeb(): onInit');
          controller.updateContentHtmlEditor(initContent);
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
      ),
    );
  }

  Widget _buildHtmlEditor(BuildContext context, {String? initialContent}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: HtmlEditor(
        key: controller.htmlKey,
        minHeight: controller.htmlEditorMinHeight,
        addDefaultSelectionMenuItems: false,
        initialContent: initialContent ?? '',
        customStyleCss: HtmlUtils.customCssStyleHtmlEditor(direction: AppUtils.getCurrentDirection(context)),
        onCreated: (editorApi) => controller.initRichTextForMobile(context, editorApi),
      ),
    );
  }

  Widget _buildActionButtonDesktop(BuildContext context) {
    return Row(
      children: [
        _buildCheckboxIdentityDefault(context),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              top: 24.0,
              bottom: 40.0,
              left: AppUtils.isDirectionRTL(context) ? 0 : 12,
              right: AppUtils.isDirectionRTL(context) ? 12 : 0
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    right: AppUtils.isDirectionRTL(context) ? 0 : 12,
                    left: AppUtils.isDirectionRTL(context) ? 12 : 0
                  ),
                  child: _buildCancelButton(context, width: 156),
                ),
                _buildSaveButton(context, width: 156),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildActionButtonMobile(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.only(top: 24),
        child: _buildCheckboxIdentityDefault(context)),
      Container(
        alignment: Alignment.center,
        color: Colors.white,
        padding: const EdgeInsets.only(top: 24, bottom: 64),
        child: Row(children: [
          Expanded(child: _buildCancelButton(context)),
          const SizedBox(width: 12),
          Expanded(child: _buildSaveButton(context))
        ]),
      )
    ]);
  }

  Widget _buildCheckboxIdentityDefault(BuildContext context) {
    return Obx(() {
      if (controller.isDefaultIdentitySupported.isTrue) {
        return SetDefaultIdentityCheckboxBuilder(
          imagePaths: _imagePaths,
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

  bool _isMobile(BuildContext context) => _responsiveUtils.isPortraitMobile(context) || _responsiveUtils.isLandscapeMobile(context);
}