import 'dart:math' as math;

import 'package:core/presentation/constants/constants_ui.dart';
import 'package:core/presentation/extensions/capitalize_extension.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:core/presentation/views/responsive/responsive_widget.dart';
import 'package:core/utils/html/html_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart' as html_editor_browser;
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:rich_text_composer/rich_text_composer.dart';
import 'package:rich_text_composer/views/widgets/rich_text_keyboard_toolbar.dart';
import 'package:tmail_ui_user/features/composer/presentation/mixin/rich_text_button_mixin.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/local_file_drop_zone_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/toolbar_rich_text_builder.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/identity_creator_controller.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/widgets/identity_drop_list_field_builder.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/widgets/identity_field_no_editable_builder.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/widgets/identity_input_field_builder.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/widgets/identity_input_with_drop_list_field_builder.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/widgets/insert_image_loading_indicator.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/widgets/set_default_identity_checkbox_builder.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/draggable_app_state.dart';
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
    Widget bodyCreatorView = SingleChildScrollView(
      controller: controller.scrollController,
      physics: const ClampingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(vertical: 12, horizontal: 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Obx(() => IdentityInputFieldBuilder(
            AppLocalizations.of(context).nameToBeDisplayed,
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
                onSelectItemDropList: (emailAddress) => controller.updateEmailOfIdentity(context, emailAddress)
              );
            } else {
              return IdentityFieldNoEditableBuilder(
                AppLocalizations.of(context).email.inCaps,
                controller.emailOfIdentity.value
              );
            }
          }),
          const SizedBox(height: 24),
          Obx(() => IdentityDropListFieldBuilder(
            controller.imagePaths,
            AppLocalizations.of(context).reply_to,
            controller.replyToOfIdentity.value,
            controller.listEmailAddressOfReplyTo,
            onSelectItemDropList: (emailAddress) => controller.updaterReplyToOfIdentity(context, emailAddress)
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
          LayoutBuilder(
            builder: (context, constraintsEditor) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColor.colorInputBorderCreateMailbox),
                    ),
                    padding: const EdgeInsetsDirectional.all(16),
                    child: _buildSignatureHtmlTemplate(context, constraintsEditor.maxWidth),
                  ),
                  Obx(() {
                    if (controller.draggableAppState.value == DraggableAppState.inActive) {
                      return const SizedBox.shrink();
                    }

                    return Positioned.fill(
                      child: PointerInterceptor(
                        child: LocalFileDropZoneWidget(
                          imagePaths: controller.imagePaths,
                          width: constraintsEditor.maxWidth,
                          height: constraintsEditor.maxHeight,
                          margin: EdgeInsets.zero,
                          onLocalFileDropZoneListener: (details) =>
                            controller.onLocalFileDropZoneListener(
                              context: context,
                              details: details,
                              maxWidth: constraintsEditor.maxWidth,
                            ),
                        )
                      ),
                    );
                  }),
                  Obx(() {
                    bool isInserting = controller.publicAssetController?.isUploading.isTrue == true
                      || controller.isCompressingInlineImage.isTrue;
                    return InsertImageLoadingIndicator(isInserting: isInserting);
                  })
                ],
              );
            }
          ),
          const SizedBox(height: 12),
          if (controller.isMobile(context))
            _buildActionButtonMobile(context)
        ]),
      ),
    );

    if (PlatformInfo.isWeb) {
      bodyCreatorView = NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          if (scrollInfo is ScrollEndNotification &&
              scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            controller.clearFocusEditor(context);
          }
          return false;
        },
        child: bodyCreatorView,
      );

      return PointerInterceptor(
        child: GestureDetector(
          onTap: () => controller.clearFocusEditor(context),
          child: ResponsiveWidget(
            responsiveUtils: controller.responsiveUtils,
            mobile: Scaffold(
              backgroundColor: Colors.black38,
              body: Card(
                margin: EdgeInsets.zero,
                borderOnForeground: false,
                color: Colors.transparent,
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
                    child: Column(children: [
                      _buildHeaderView(context),
                      Expanded(child: bodyCreatorView)
                    ]),
                  ),
                ),
              ),
            ),
            landscapeMobile: Scaffold(
              backgroundColor: Colors.white,
              body: Column(children: [
                _buildHeaderView(context),
                Expanded(child: bodyCreatorView)
              ])
            ),
            tablet: Scaffold(
              backgroundColor: Colors.black38,
              body: Center(
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
                        child: Column(children: [
                          _buildHeaderView(context),
                          Expanded(child: bodyCreatorView),
                          const SizedBox(height: 12),
                          _buildActionButtonDesktop(context)
                        ])
                      )
                    )
                  ),
                )
              ),
            ),
            desktop: Scaffold(
              backgroundColor: Colors.black38,
              body: Center(
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
                    width: math.max(controller.responsiveUtils.getSizeScreenWidth(context) * 0.4, 800),
                    height: controller.responsiveUtils.getSizeScreenHeight(context) * 0.8,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(16)),
                      child: Column(children: [
                        _buildHeaderView(context),
                        Expanded(child: bodyCreatorView),
                        const SizedBox(height: 12),
                        _buildActionButtonDesktop(context)
                      ])
                    )
                  )
                )
              )
            )
          ),
        ),
      );
    } else {
      return ResponsiveWidget(
        responsiveUtils: controller.responsiveUtils,
        mobile: GestureDetector(
          onTap: () => controller.clearFocusEditor(context),
          child: Scaffold(
            backgroundColor: Colors.black38,
            body: SafeArea(
              bottom: false,
              child: KeyboardRichText(
                keyBroadToolbar: RichTextKeyboardToolBar(
                  rootContext: context,
                  titleBack: AppLocalizations.of(context).titleFormat,
                  backgroundKeyboardToolBarColor: PlatformInfo.isIOS
                    ? AppColor.colorBackgroundKeyboard
                    : AppColor.colorBackgroundKeyboardAndroid,
                  richTextController: controller.richTextMobileTabletController!.richTextController,
                  quickStyleLabel: AppLocalizations.of(context).titleQuickStyles,
                  backgroundLabel: AppLocalizations.of(context).titleBackground,
                  foregroundLabel: AppLocalizations.of(context).titleForeground,
                  formatLabel: AppLocalizations.of(context).titleFormat,
                  insertImage: () => controller.pickImage(context),
                ),
                richTextController: controller.richTextMobileTabletController!.richTextController,
                child: Card(
                  margin: EdgeInsets.zero,
                  elevation: 16,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(16),
                        topLeft: Radius.circular(16)
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(16),
                        topLeft: Radius.circular(16)
                      ),
                    ),
                    child: Column(children: [
                      _buildHeaderView(context),
                      Expanded(child: bodyCreatorView)
                    ]),
                  ),
                ),
              ),
            ),
          ),
        ),
        landscapeMobile: GestureDetector(
          onTap: () => controller.clearFocusEditor(context),
          child: Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              left: false,
              right: false,
              child: KeyboardRichText(
                keyBroadToolbar: RichTextKeyboardToolBar(
                  rootContext: context,
                  titleBack: AppLocalizations.of(context).titleFormat,
                  backgroundKeyboardToolBarColor: PlatformInfo.isIOS
                    ? AppColor.colorBackgroundKeyboard
                    : AppColor.colorBackgroundKeyboardAndroid,
                  richTextController: controller.richTextMobileTabletController!.richTextController,
                  quickStyleLabel: AppLocalizations.of(context).titleQuickStyles,
                  backgroundLabel: AppLocalizations.of(context).titleBackground,
                  foregroundLabel: AppLocalizations.of(context).titleForeground,
                  formatLabel: AppLocalizations.of(context).titleFormat,
                  insertImage: () => controller.pickImage(context),
                ),
                richTextController: controller.richTextMobileTabletController!.richTextController,
                child: SafeArea(
                  child: Column(children: [
                    _buildHeaderView(context),
                    Expanded(child: bodyCreatorView)
                  ]),
                ),
              ),
            )
          ),
        ),
        tablet: Portal(
          child: GestureDetector(
            onTap: () => controller.clearFocusEditor(context),
            child: Scaffold(
              backgroundColor: Colors.black38,
              body: SafeArea(
                child: KeyboardRichText(
                  keyBroadToolbar: RichTextKeyboardToolBar(
                    rootContext: context,
                    titleBack: AppLocalizations.of(context).titleFormat,
                    backgroundKeyboardToolBarColor: PlatformInfo.isIOS
                      ? AppColor.colorBackgroundKeyboard
                      : AppColor.colorBackgroundKeyboardAndroid,
                    richTextController: controller.richTextMobileTabletController!.richTextController,
                    quickStyleLabel: AppLocalizations.of(context).titleQuickStyles,
                    backgroundLabel: AppLocalizations.of(context).titleBackground,
                    foregroundLabel: AppLocalizations.of(context).titleForeground,
                    formatLabel: AppLocalizations.of(context).titleFormat,
                    insertImage: () => controller.pickImage(context),
                  ),
                  richTextController: controller.richTextMobileTabletController!.richTextController,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.symmetric(horizontal: 24),
                      child: Card(
                        color: Colors.transparent,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16))
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(16))
                          ),
                          width: math.max(controller.responsiveUtils.getSizeScreenWidth(context) * 0.4, 700),
                          height: controller.responsiveUtils.getSizeScreenHeight(context) * 0.8,
                          child: Column(children: [
                            _buildHeaderView(context),
                            Expanded(child: bodyCreatorView),
                            const SizedBox(height: 12),
                            _buildActionButtonDesktop(context)
                          ])
                        )
                      ),
                    )
                  ),
                ),
              ),
            ),
          ),
        )
      );
    }
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

  Widget _buildSignatureHtmlTemplate(
    BuildContext context,
    double maxWidth
  ) {
    if (PlatformInfo.isWeb) {
      return Column(
        children: [
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
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
              maxHeight: 300,
            ),
            child: _buildHtmlEditorWeb(
              context,
              controller.contentHtmlEditor,
              maxWidth),
          ),
        ],
      );
    } else {
      return _buildHtmlEditor(
        context,
        initialContent: controller.contentHtmlEditor);
    }
  }

  Widget _buildHtmlEditorWeb(
    BuildContext context,
    String initContent,
    double maxWidth
  ) {
    return html_editor_browser.HtmlEditor(
      key: const Key('identity_create_editor_web'),
      controller: controller.richTextWebController!.editorController,
      htmlEditorOptions: html_editor_browser.HtmlEditorOptions(
        shouldEnsureVisible: true,
        hint: '',
        darkMode: false,
        cacheHTMLAssetOffline: true,
        initialText: initContent.isEmpty ? null : initContent,
        disableDragAndDrop: true,
        spellCheck: true,
        customBodyCssStyle: HtmlUtils.customCssStyleHtmlEditor(direction: AppUtils().getCurrentDirection(context)),
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
          controller.richTextWebController?.editorController.setOnDragDropEvent();
          controller.richTextWebController?.editorController.setFullScreen();
          controller.updateContentHtmlEditor(initContent);
        },
        onFocus: () {
          FocusManager.instance.primaryFocus?.unfocus();
          Future.delayed(const Duration(milliseconds: 500), () {
            controller.richTextWebController?.editorController.setFocus();
          });
          controller.richTextWebController?.closeAllMenuPopup();
        },
        onChangeSelection: controller.richTextWebController?.onEditorSettingsChange,
        onChangeCodeview: controller.updateContentHtmlEditor,
        onDragEnter: controller.handleOnDragEnterSignatureEditorWeb,
        onDragLeave: (_) {},
        onImageUpload: (listFileUpload) => controller.onPasteImageSuccess(
          context,
          listFileUpload,
          maxWidth: maxWidth),
        onImageUploadError: (listFileUpload, base64, uploadError) =>
          controller.onPasteImageFailure(
            context,
            listFileUpload,
            base64: base64,
            uploadError: uploadError
          ),
      ),
    );
  }

  Widget _buildHtmlEditor(BuildContext context, {String? initialContent}) {
    return HtmlEditor(
      key: controller.htmlKey,
      minHeight: ConstantsUI.htmlContentMinHeight.toInt(),
      maxHeight: PlatformInfo.isIOS ? ConstantsUI.composerHtmlContentMaxHeight : null,
      addDefaultSelectionMenuItems: false,
      initialContent: initialContent ?? '',
      customStyleCss: HtmlUtils.customCssStyleHtmlEditor(direction: AppUtils().getCurrentDirection(context)),
      onCreated: (editorApi) => controller.initRichTextForMobile(context, editorApi),
    );
  }

  Widget _buildActionButtonDesktop(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(vertical: 12, horizontal: 24),
      child: Row(
        children: [
          Expanded(child: _buildCheckboxIdentityDefault(context)),
          const SizedBox(width: 12),
          _buildCancelButton(context, width: 156),
          const SizedBox(width: 12),
          _buildSaveButton(context, width: 156)
        ],
      ),
    );
  }

  Widget _buildActionButtonMobile(BuildContext context) {
    return Column(children: [
      _buildCheckboxIdentityDefault(context),
      const SizedBox(height: 24),
      SafeArea(
        child: Row(children: [
          Expanded(child: _buildCancelButton(context)),
          const SizedBox(width: 12),
          Expanded(child: _buildSaveButton(context))
        ]),
      ),
      if (controller.richTextMobileTabletController != null)
        ValueListenableBuilder(
          valueListenable: controller.richTextMobileTabletController!.richTextController.richTextToolbarNotifier,
          builder: (_, isShowing, __) {
            if (isShowing) {
              return const SizedBox(height: 48);
            } else {
              return const SizedBox.shrink();
            }
          })
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