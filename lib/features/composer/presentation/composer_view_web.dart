import 'package:core/presentation/extensions/capitalize_extension.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/extensions/html_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/html_transformer/html_template.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:core/presentation/views/image/avatar_builder.dart';
import 'package:core/presentation/views/responsive/responsive_widget.dart';
import 'package:core/presentation/views/text/text_field_builder.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:model/extensions/list_email_content_extension.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/base/widget/custom_scroll_behavior.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/mixin/composer_loading_mixin.dart';
import 'package:tmail_ui_user/features/composer/presentation/mixin/rich_text_button_mixin.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/screen_display_mode.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/attachment_file_composer_builder.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/email_address_input_builder.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/toolbar_rich_text_builder.dart';
import 'package:tmail_ui_user/features/upload/presentation/extensions/list_upload_file_state_extension.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/upload_file_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_email_content_state.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

class ComposerView extends GetWidget<ComposerController>
    with AppLoaderMixin, RichTextButtonMixin, ComposerLoadingMixin {

  final responsiveUtils = Get.find<ResponsiveUtils>();
  final imagePaths = Get.find<ImagePaths>();
  final appToast = Get.find<AppToast>();

  ComposerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      responsiveUtils: responsiveUtils,
      mobile: Scaffold(
          backgroundColor: Colors.white,
          body: Container(
              color: Colors.white,
              child: LayoutBuilder(builder: (context, constraints) => PointerInterceptor(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => _buildAppBarForMobile(context, controller.isEnableEmailSendButton.value)),
                    const Divider(color: AppColor.colorDividerComposer, height: 1),
                    Obx(() => controller.identitySelected.value != null
                      ? _buildFromEmailAddress(context)
                      : const SizedBox.shrink()),
                    Obx(() => controller.identitySelected.value != null
                        ? const Divider(color: AppColor.colorDividerComposer, height: 1)
                        : const SizedBox.shrink()),
                    _buildEmailAddress(context, constraints),
                    const Divider(color: AppColor.colorDividerComposer, height: 1),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildSubjectEmail(context)),
                    const Divider(color: AppColor.colorDividerComposer, height: 1),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildListButton(context, constraints)),
                    const Divider(color: AppColor.colorDividerComposer, height: 1),
                    Expanded(child: Column(
                        children: [
                          _buildAttachmentsWidget(context),
                          ToolbarRichTextWebBuilder(richTextWebController: controller.richTextWebController),
                          buildInlineLoadingView(controller),
                          _buildEditorForm(context)
                        ]
                    )),
                  ]
              )))
          )
      ),
      desktop: Obx(() {
        return Stack(children: [
          if (controller.screenDisplayMode.value == ScreenDisplayMode.normal)
            if (AppUtils.isDirectionRTL(context))
              Positioned(left: 5, bottom: 5, child: Card(
                elevation: 20,
                color: Colors.transparent,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
                child: Container(
                  decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(24))),
                  width: responsiveUtils.getSizeScreenWidth(context) * 0.5,
                  height: responsiveUtils.getSizeScreenHeight(context) * 0.75,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(24)),
                    child: LayoutBuilder(builder: (context, constraints) =>
                      PointerInterceptor(child: _buildBodyForDesktop(context, constraints))
                    )
                  )
                )
              ))
            else
              Positioned(right: 5, bottom: 5, child: Card(
                elevation: 20,
                color: Colors.transparent,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
                child: Container(
                  decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(24))),
                  width: responsiveUtils.getSizeScreenWidth(context) * 0.5,
                  height: responsiveUtils.getSizeScreenHeight(context) * 0.75,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(24)),
                    child: LayoutBuilder(builder: (context, constraints) =>
                      PointerInterceptor(child: _buildBodyForDesktop(context, constraints))
                    )
                  )
                )
              )),
          if (controller.screenDisplayMode.value == ScreenDisplayMode.minimize)
            if (AppUtils.isDirectionRTL(context))
              Positioned(left: 5, bottom: 5, child: Card(
                elevation: 20,
                color: Colors.transparent,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                child: Container(
                  decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(16))),
                  width: 500,
                  height: 50,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    child: PointerInterceptor(child: Row(children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: buildIconWeb(
                          icon: SvgPicture.asset(imagePaths.icCloseMailbox, fit: BoxFit.fill),
                          tooltip: AppLocalizations.of(context).saveAndClose,
                          onTap: () => controller.saveEmailAsDrafts(context)
                        )),
                      buildIconWeb(
                        icon: SvgPicture.asset(imagePaths.icFullScreenComposer, fit: BoxFit.fill),
                        tooltip: AppLocalizations.of(context).fullscreen,
                        onTap: () => controller.displayScreenTypeComposerAction(ScreenDisplayMode.fullScreen)),
                      buildIconWeb(
                        icon: SvgPicture.asset(imagePaths.icChevronUp, fit: BoxFit.fill),
                        tooltip: AppLocalizations.of(context).show,
                        onTap: () => controller.displayScreenTypeComposerAction(ScreenDisplayMode.normal)),
                      Expanded(child: Padding(
                        padding: const EdgeInsets.only(left: 16, right: 80),
                        child: _buildTitleComposer(context),
                      )),
                    ]))
                  )
                )
              ))
            else
              Positioned(right: 5, bottom: 5, child: Card(
                elevation: 20,
                color: Colors.transparent,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                child: Container(
                  decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(16))),
                  width: 500,
                  height: 50,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    child: PointerInterceptor(child: Row(children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: buildIconWeb(
                          icon: SvgPicture.asset(imagePaths.icCloseMailbox, fit: BoxFit.fill),
                          tooltip: AppLocalizations.of(context).saveAndClose,
                          onTap: () => controller.saveEmailAsDrafts(context)
                        )),
                      buildIconWeb(
                        icon: SvgPicture.asset(imagePaths.icFullScreenComposer, fit: BoxFit.fill),
                        tooltip: AppLocalizations.of(context).fullscreen,
                        onTap: () => controller.displayScreenTypeComposerAction(ScreenDisplayMode.fullScreen)),
                      buildIconWeb(
                        icon: SvgPicture.asset(imagePaths.icChevronUp, fit: BoxFit.fill),
                        tooltip: AppLocalizations.of(context).show,
                        onTap: () => controller.displayScreenTypeComposerAction(ScreenDisplayMode.normal)),
                      Expanded(child: Padding(
                        padding: const EdgeInsets.only(left: 16, right: 80),
                        child: _buildTitleComposer(context),
                      )),
                    ]))
                  )
                )
              )),
          if (controller.screenDisplayMode.value == ScreenDisplayMode.fullScreen)
            Scaffold(
                backgroundColor: Colors.black38,
                body: Align(alignment: Alignment.center, child: Card(
                    color: Colors.transparent,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
                    child: Container(
                        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(24))),
                        width: responsiveUtils.getSizeScreenWidth(context) * 0.85,
                        height: responsiveUtils.getSizeScreenHeight(context) * 0.9,
                        child: ClipRRect(
                            borderRadius: const BorderRadius.all(Radius.circular(24)),
                            child: LayoutBuilder(builder: (context, constraints) =>
                                PointerInterceptor(child: _buildBodyForDesktop(context, constraints)))
                        )
                    )
                )
                )
            )
        ]);
      }),
      tablet: Scaffold(
          backgroundColor: Colors.black38,
          body: Align(alignment: Alignment.center, child: Card(
              color: Colors.transparent,
              shadowColor: Colors.transparent,
              child: Container(
                  decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(24))),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(24)),
                      child: LayoutBuilder(builder: (context, constraints) =>
                          PointerInterceptor(child: _buildBodyForDesktop(context, constraints)))
                  )
              )
          ))
      )
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Row(
      children: [
        buildIconWeb(
            minSize: 40,
            iconPadding: EdgeInsets.zero,
            icon: SvgPicture.asset(imagePaths.icCloseMailbox, fit: BoxFit.fill),
            tooltip: AppLocalizations.of(context).saveAndClose,
            onTap: () => controller.saveEmailAsDrafts(context)),
        if (responsiveUtils.isDesktop(context))
          Obx(() => buildIconWeb(
              minSize: 40,
              iconPadding: EdgeInsets.zero,
              icon: SvgPicture.asset(
                  controller.screenDisplayMode.value == ScreenDisplayMode.fullScreen
                      ? imagePaths.icFullScreenExit
                      : imagePaths.icFullScreenComposer,
                  fit: BoxFit.fill),
              tooltip: AppLocalizations.of(context).fullscreen,
              onTap: () => controller.displayScreenTypeComposerAction(controller.screenDisplayMode.value == ScreenDisplayMode.fullScreen
                  ? ScreenDisplayMode.normal
                  : ScreenDisplayMode.fullScreen))),
        if (responsiveUtils.isDesktop(context))
          buildIconWeb(
              minSize: 40,
              iconPadding: EdgeInsets.zero,
            icon: SvgPicture.asset(imagePaths.icMinimize, fit: BoxFit.fill),
            tooltip: AppLocalizations.of(context).minimize,
            onTap: () => controller.displayScreenTypeComposerAction(ScreenDisplayMode.minimize)),
        Expanded(child: _buildTitleComposer(context)),
        const SizedBox(width: 100),
      ]
    );
  }

  Widget _buildAppBarForMobile(BuildContext context, bool isEnableSendButton) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
      color: Colors.white,
      child: Row(
          children: [
            buildIconWeb(
                icon: SvgPicture.asset(imagePaths.icClose, width: 30, height: 30, fit: BoxFit.fill),
                tooltip: AppLocalizations.of(context).saveAndClose,
                iconPadding: EdgeInsets.zero,
                onTap: () => controller.saveEmailAsDrafts(context)),
            Expanded(child: _buildTitleComposer(context)),
            buildIconWeb(
                icon: SvgPicture.asset(
                    isEnableSendButton ? imagePaths.icSendMobile : imagePaths.icSendDisable,
                    fit: BoxFit.fill),
                tooltip: AppLocalizations.of(context).send,
                onTap: () => controller.sendEmailAction(context)),
            buildIconWithLowerMenu(
              SvgPicture.asset(imagePaths.icRequestReadReceipt), 
              context, 
              _popUpMoreActionMenu(context), 
              controller.openPopupMenuAction),
          ]
      ),
    );
  }

  List<PopupMenuEntry> _popUpMoreActionMenu(BuildContext context) {
    return [
      PopupMenuItem(
        padding: const EdgeInsets.symmetric(horizontal: 8), 
        child: PointerInterceptor(
          child: IntrinsicHeight(
            child: Row(
              children: [
                Obx(() => buildIconWeb(
                  icon: Icon(controller.hasRequestReadReceipt.value ? Icons.done : null, color: Colors.black))), 
                Expanded(
                  child: InkResponse(
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context).requestReadReceipt,
                          style: const TextStyle(color: Colors.black, fontSize: 15),
                          )
                      ),
                    ),
                  ),
                ),
              ]),
          ),
        ),
        onTap: () {
          controller.toggleRequestReadReceipt();
        },
      )
    ];
  }

  Widget _buildBottomBar(BuildContext context, bool isEnableSendButton, BoxConstraints constraints) {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        color: Colors.white,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: constraints.widthConstraints(),
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 24),
                      buildButtonWrapText(
                        AppLocalizations.of(context).cancel,
                        textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 17, color: AppColor.lineItemListColor),
                        bgColor: AppColor.emailAddressChipColor,
                        minWidth: 150,
                        height: 44,
                        radius: 10,
                        onTap: () => controller.closeComposerWeb()),
                      const SizedBox(width: 12),
                      buildButtonWrapText(
                          AppLocalizations.of(context).save_to_drafts,
                          textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 17, color: AppColor.colorTextButton),
                          bgColor: AppColor.emailAddressChipColor,
                          minWidth: 150,
                          height: 44,
                          radius: 10,
                          onTap: () => controller.saveEmailAsDrafts(context)),
                      const SizedBox(width: 12),
                      buildButtonWrapText(
                          AppLocalizations.of(context).send,
                          minWidth: 150,
                          height: 44,
                          radius: 10,
                          onTap: () => controller.sendEmailAction(context)),
                      const SizedBox(width: 24),
                    ]
                ),
                if(!responsiveUtils.isMobile(context))
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      buildIconWithUpperMenu(
                        SvgPicture.asset(imagePaths.icRequestReadReceipt), 
                        context, 
                        _popUpMoreActionMenu(context), 
                        controller.openPopupMenuAction)
                    ]),
              ],
            ),
          ),
        ),
      );
  }

  Widget _buildBodyForDesktop(BuildContext context, BoxConstraints constraints) {
    return Column(children: [
        Padding(padding: const EdgeInsets.only(left: 20, right: 20, top: 8), child: _buildAppBar(context)),
        const Padding(padding: EdgeInsets.only(top: 8), child: Divider(color: AppColor.colorDividerComposer, height: 1)),
        Padding(
            padding: EdgeInsets.only(
              left: AppUtils.isDirectionRTL(context) ? 0 : 16,
              right: AppUtils.isDirectionRTL(context) ? 16 : 0,
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(padding: const EdgeInsets.only(top: 20),
                  child: (AvatarBuilder()
                      ..text(controller.mailboxDashBoardController.userProfile.value?.getAvatarText() ?? '')
                      ..size(56)
                      ..addTextStyle(const TextStyle(fontWeight: FontWeight.w600, fontSize: 28, color: Colors.white))
                      ..backgroundColor(AppColor.colorAvatar))
                    .build()),
              Expanded(child: Padding(
                padding: EdgeInsets.only(
                  left: AppUtils.isDirectionRTL(context) ? 0 : 12,
                  right: AppUtils.isDirectionRTL(context) ? 12 : 0,
                ),
                child: Column(children: [
                  Obx(() => controller.identitySelected.value != null
                      ? _buildFromEmailAddress(context)
                      : const SizedBox.shrink()),
                  Obx(() => controller.identitySelected.value != null
                      ? const Divider(color: AppColor.colorDividerComposer, height: 1)
                      : const SizedBox.shrink()),
                  _buildEmailAddress(context, constraints),
                  const Divider(color: AppColor.colorDividerComposer, height: 1),
                  Padding(
                    padding: EdgeInsets.only(
                      left: AppUtils.isDirectionRTL(context) ? 16 : 0,
                      right: AppUtils.isDirectionRTL(context) ? 0 : 16,
                    ),
                    child: _buildSubjectEmail(context)
                  ),
                  const Divider(color: AppColor.colorDividerComposer, height: 1),
                  _buildListButton(context, constraints),
                ]),
              ))
            ])),
        const Divider(color: AppColor.colorDividerComposer, height: 1),
        Expanded(child: Padding(
            padding: EdgeInsets.only(
              left: AppUtils.isDirectionRTL(context) ? responsiveUtils.isMobile(context) ? 16 : 25 : responsiveUtils.isMobile(context) ? 16 : 60,
              right: AppUtils.isDirectionRTL(context) ? responsiveUtils.isMobile(context) ? 16 : 60 : responsiveUtils.isMobile(context) ? 16 : 25,
            ),
            child: Column(
                children: [
                  _buildAttachmentsWidget(context),
                  ToolbarRichTextWebBuilder(richTextWebController: controller.richTextWebController),
                  buildInlineLoadingView(controller),
                  _buildEditorForm(context)
                ]
            ))),
        const Divider(color: AppColor.colorDividerComposer, height: 1),
        Obx(() => _buildBottomBar(context, controller.isEnableEmailSendButton.value, constraints)),
    ]);
  }

  Widget _buildTitleComposer(BuildContext context) {
    return Obx(() => Text(
      controller.subjectEmail.isNotEmpty == true
          ? controller.subjectEmail.value ?? ''
          : AppLocalizations.of(context).new_message.capitalizeFirstEach,
      maxLines: 1,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
    ));
  }

  Widget _buildFromEmailAddress(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: AppUtils.isDirectionRTL(context) ? 0 : responsiveUtils.isMobile(context) ? 16 : 0,
          right: AppUtils.isDirectionRTL(context) ? responsiveUtils.isMobile(context) ? 16 : 0 : 0,
          top: 12,
          bottom: 12),
      child: Row(children: [
        Text('${AppLocalizations.of(context).from_email_address_prefix}:',
            style: const TextStyle(fontSize: 15, color: AppColor.colorHintEmailAddressInput)),
        const SizedBox(width: 12),
        DropdownButtonHideUnderline(
          child: DropdownButton2<Identity>(
            isExpanded: true,
            customButton: SvgPicture.asset(imagePaths.icEditIdentity),
            items: controller.listIdentities.map((item) => DropdownMenuItem<Identity>(
              value: item,
              child: PointerInterceptor(
                child: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: item == controller.identitySelected.value ? AppColor.colorBgMenuItemDropDownSelected : Colors.transparent),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.name ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: Colors.black),
                          maxLines: 1,
                          overflow: CommonTextStyle.defaultTextOverFlow,
                          softWrap: CommonTextStyle.defaultSoftWrap
                        ),
                        Text(
                          item.email ?? '',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.normal,
                            color: AppColor.colorHintSearchBar),
                          maxLines: 1,
                          overflow: CommonTextStyle.defaultTextOverFlow,
                          softWrap: CommonTextStyle.defaultSoftWrap
                        )
                      ]
                  ),
                ),
              ),
            )).toList(),
            onChanged: (newIdentity) => controller.selectIdentity(newIdentity),
            dropdownStyleData: DropdownStyleData(
              maxHeight: 240,
              width: 370,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white),
              elevation: 4,
              scrollbarTheme: ScrollbarThemeData(
                radius: const Radius.circular(40),
                thickness: MaterialStateProperty.all<double>(6),
                thumbVisibility: MaterialStateProperty.all<bool>(true),
              ),
            ),
            menuItemStyleData: const MenuItemStyleData(
              height: 55,
              padding: EdgeInsets.symmetric(horizontal: 8),
            )
          ),
        ),
        Expanded(child: Padding(
          padding: EdgeInsets.only(
            right: AppUtils.isDirectionRTL(context) ? 12 : 8,
            left: AppUtils.isDirectionRTL(context) ? 8 : 12,
          ),
          child: Text(
            controller.identitySelected.value?.email ?? '',
            maxLines: 1,
            overflow: CommonTextStyle.defaultTextOverFlow,
            softWrap: CommonTextStyle.defaultSoftWrap,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.normal,
              color: AppColor.colorEmailAddressPrefix),
          )
        )),
      ]),
    );
  }

  Widget _buildEmailAddress(BuildContext context, BoxConstraints constraints) {
    log('ComposerView::_buildEmailAddress(): height: ${constraints.maxHeight}');
    return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: _getMaxHeightEmailAddressWidget(context, constraints)),
        child: SingleChildScrollView(
          controller: controller.scrollControllerEmailAddress,
          child: Column(
            children: [
              Obx(() => Padding(
                  padding: EdgeInsets.only(
                    left: AppUtils.isDirectionRTL(context) ? 0 : responsiveUtils.isMobile(context) ? 16 : 0,
                    right: AppUtils.isDirectionRTL(context) ? responsiveUtils.isMobile(context) ? 16 : 0 : 0
                  ),
                  child: (EmailAddressInputBuilder(context, imagePaths,
                          PrefixEmailAddress.to,
                          controller.listToEmailAddress,
                          controller.listEmailAddressType,
                          expandMode: controller.toAddressExpandMode.value,
                          controller: controller.toEmailAddressController,
                          focusNode: controller.toAddressFocusNode,
                          autoDisposeFocusNode: false,
                          isInitial: controller.isInitialRecipient.value,
                          keyTagEditor: controller.keyToEmailTagEditor,
                          nextFocusNode: controller.getNextFocusOfToEmailAddress()
                      )
                      ..addOnFocusEmailAddressChangeAction((prefixEmailAddress, focus) => controller.onEmailAddressFocusChange(prefixEmailAddress, focus))
                      ..addOnShowFullListEmailAddressAction((prefixEmailAddress) => controller.showFullEmailAddress(prefixEmailAddress))
                      ..addOnAddEmailAddressTypeAction((prefixEmailAddress) => controller.addEmailAddressType(prefixEmailAddress))
                      ..addOnUpdateListEmailAddressAction((prefixEmailAddress, listEmailAddress) => controller.updateListEmailAddress(prefixEmailAddress, listEmailAddress))
                      ..addOnSuggestionEmailAddress(controller.getAutoCompleteSuggestion)
                      ..addOnFocusNextAddressAction(controller.handleFocusNextAddressAction))
                    .build()
              )),
              Obx(() => controller.listEmailAddressType.contains(PrefixEmailAddress.cc) == true
                  ? const Divider(color: AppColor.colorDividerComposer, height: 1)
                  : const SizedBox.shrink()),
              Obx(() => controller.listEmailAddressType.contains(PrefixEmailAddress.cc) == true
                  ? Padding(
                      padding: EdgeInsets.only(
                        left: AppUtils.isDirectionRTL(context) ? 0 : responsiveUtils.isMobile(context) ? 16 : 0,
                        right: AppUtils.isDirectionRTL(context) ? responsiveUtils.isMobile(context) ? 16 : 0 : 0
                      ),
                      child: (EmailAddressInputBuilder(context, imagePaths,
                            PrefixEmailAddress.cc,
                            controller.listCcEmailAddress,
                            controller.listEmailAddressType,
                            expandMode: controller.ccAddressExpandMode.value,
                            controller: controller.ccEmailAddressController,
                            isInitial: controller.isInitialRecipient.value,
                            keyTagEditor: controller.keyCcEmailTagEditor,
                            focusNode: controller.ccAddressFocusNode,
                            nextFocusNode: controller.getNextFocusOfCcEmailAddress()
                        )
                        ..addOnFocusEmailAddressChangeAction((prefixEmailAddress, focus) => controller.onEmailAddressFocusChange(prefixEmailAddress, focus))
                        ..addOnShowFullListEmailAddressAction((prefixEmailAddress) => controller.showFullEmailAddress(prefixEmailAddress))
                        ..addOnDeleteEmailAddressTypeAction((prefixEmailAddress) => controller.deleteEmailAddressType(prefixEmailAddress))
                        ..addOnUpdateListEmailAddressAction((prefixEmailAddress, listEmailAddress) => controller.updateListEmailAddress(prefixEmailAddress, listEmailAddress))
                        ..addOnSuggestionEmailAddress(controller.getAutoCompleteSuggestion)
                        ..addOnFocusNextAddressAction(controller.handleFocusNextAddressAction))
                      .build())
                  : const SizedBox.shrink()
              ),
              Obx(() => controller.listEmailAddressType.contains(PrefixEmailAddress.bcc) == true
                  ? const Divider(color: AppColor.colorDividerComposer, height: 1)
                  : const SizedBox.shrink()),
              Obx(() => controller.listEmailAddressType.contains(PrefixEmailAddress.bcc) == true
                  ? Padding(
                      padding: EdgeInsets.only(
                        left: AppUtils.isDirectionRTL(context) ? 0 : responsiveUtils.isMobile(context) ? 16 : 0,
                        right: AppUtils.isDirectionRTL(context) ? responsiveUtils.isMobile(context) ? 16 : 0 : 0
                      ),
                      child: (EmailAddressInputBuilder(context, imagePaths,
                            PrefixEmailAddress.bcc,
                            controller.listBccEmailAddress,
                            controller.listEmailAddressType,
                            expandMode: controller.bccAddressExpandMode.value,
                            controller: controller.bccEmailAddressController,
                            isInitial: controller.isInitialRecipient.value,
                            keyTagEditor: controller.keyBccEmailTagEditor,
                            focusNode: controller.bccAddressFocusNode,
                            nextFocusNode: controller.subjectEmailInputFocusNode
                        )
                        ..addOnFocusEmailAddressChangeAction((prefixEmailAddress, focus) => controller.onEmailAddressFocusChange(prefixEmailAddress, focus))
                        ..addOnShowFullListEmailAddressAction((prefixEmailAddress) => controller.showFullEmailAddress(prefixEmailAddress))
                        ..addOnDeleteEmailAddressTypeAction((prefixEmailAddress) => controller.deleteEmailAddressType(prefixEmailAddress))
                        ..addOnUpdateListEmailAddressAction((prefixEmailAddress, listEmailAddress) => controller.updateListEmailAddress(prefixEmailAddress, listEmailAddress))
                        ..addOnSuggestionEmailAddress(controller.getAutoCompleteSuggestion)
                        ..addOnFocusNextAddressAction(controller.handleFocusNextAddressAction))
                      .build())
                  : const SizedBox.shrink()
              ),
            ],
          ),
        )
    );
  }

  Widget _buildSubjectEmail(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            right: AppUtils.isDirectionRTL(context) ? 0 : 8,
            left: AppUtils.isDirectionRTL(context) ? 8 : 0,
            top: 16
          ),
          child: Text(
            '${AppLocalizations.of(context).subject_email}:',
            style: const TextStyle(
              fontSize: 15,
              color: AppColor.colorHintEmailAddressInput
            )
          )
        ),
        Expanded(child: (TextFieldBuilder()
          ..key(const Key('subject_email_input'))
          ..cursorColor(AppColor.colorTextButton)
          ..addFocusNode(controller.subjectEmailInputFocusNode)
          ..onChange((value) => controller.setSubjectEmail(value))
          ..textStyle(const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.normal))
          ..textDecoration(const InputDecoration(contentPadding: EdgeInsets.zero, border: InputBorder.none))
          ..addController(controller.subjectEmailInputController))
        .build()
        )
      ]
    );
  }

  Widget _buildListButton(BuildContext context, BoxConstraints constraints) {
    return  Transform(
        transform: Matrix4.translationValues(
          AppUtils.isDirectionRTL(context) ? 0.0 : -5.0,
          0.0,
          0.0
        ),
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(children: [
              buildIconWeb(
                  minSize: 40,
                  iconPadding: EdgeInsets.zero,
                  icon: SvgPicture.asset(imagePaths.icAttachmentsComposer,
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(AppColor.colorTextButton, BlendMode.srcIn),
                      fit: BoxFit.fill),
                  tooltip: AppLocalizations.of(context).attach_file,
                  onTap: () => controller.openFilePickerByType(context, FileType.any)),
              const SizedBox(width: 4),
              Obx(() {
                final opacity = controller.richTextWebController.codeViewEnabled ? 0.5 : 1.0;
                return AbsorbPointer(
                  absorbing: controller.richTextWebController.codeViewEnabled,
                  child: buildIconWeb(
                      minSize: 40,
                      iconPadding: EdgeInsets.zero,
                      icon: SvgPicture.asset(
                          imagePaths.icInsertImage,
                          colorFilter: ColorFilter.mode(
                            AppColor.colorTextButton.withOpacity(opacity),
                            BlendMode.srcIn),
                          fit: BoxFit.fill),
                      tooltip: AppLocalizations.of(context).insertImage,
                      onTap: () => controller.insertImage(context, constraints.maxWidth)),
                );
              }),
              const SizedBox(width: 4),
              Obx(() {
                return buildIconWeb(
                    minSize: 40,
                    colorSelected: controller.richTextWebController.codeViewEnabled
                      ? AppColor.colorSelectedRichTextButton
                      : Colors.transparent,
                    iconPadding: EdgeInsets.zero,
                    icon: SvgPicture.asset(
                      imagePaths.icStyleCodeView,
                      colorFilter: const ColorFilter.mode(AppColor.colorTextButton, BlendMode.srcIn),
                      fit: BoxFit.fill),
                    tooltip: AppLocalizations.of(context).codeView,
                    onTap: () => controller.richTextWebController.toggleCodeView());
              }),
            ])
        )
    );
  }

  Widget _buildEditorForm(BuildContext context) {
    return Obx(() {
      final argsComposer = controller.composerArguments.value;

      if (argsComposer == null) {
        return const SizedBox.shrink();
      }

      final currentTextEditor = controller.textEditorWeb;

      switch(argsComposer.emailActionType) {
        case EmailActionType.compose:
        case EmailActionType.composeFromEmailAddress:
          return _buildHtmlEditor(
              context,
              currentTextEditor ?? HtmlExtension.editorStartTags);
        case EmailActionType.edit:
          return controller.emailContentsViewState.value.fold(
            (failure) => _buildHtmlEditor(
                context,
                currentTextEditor ?? HtmlExtension.editorStartTags),
            (success) {
              if (success is GetEmailContentLoading) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: loadingWidget,
                );
              } else if (success is GetEmailContentSuccess) {
                var contentHtml = success.emailContents.asHtmlString;
                if (contentHtml.isEmpty == true) {
                  contentHtml = HtmlExtension.editorStartTags;
                }
                return _buildHtmlEditor(context, currentTextEditor ?? contentHtml);
              } else {
                return _buildHtmlEditor(
                  context,
                  currentTextEditor ?? HtmlExtension.editorStartTags);
              }
            });
        case EmailActionType.reply:
        case EmailActionType.replyAll:
        case EmailActionType.forward:
          var contentHtml = controller.getEmailContentQuotedAsHtml(
              context,
              argsComposer);
          if (contentHtml.isEmpty == true) {
            contentHtml = HtmlExtension.editorStartTags;
          }
          return _buildHtmlEditor(context, currentTextEditor ?? contentHtml);
        default:
          return _buildHtmlEditor(
              context,
              currentTextEditor ?? HtmlExtension.editorStartTags);
      }
    });
  }

  Widget _buildHtmlEditor(BuildContext context, String initContent) {
    log('ComposerView::_buildHtmlEditor(): initContent: $initContent');
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: HtmlEditor(
          key: const Key('composer_editor_web'),
          controller: controller.richTextWebController.editorController,
          htmlEditorOptions: const HtmlEditorOptions(
            shouldEnsureVisible: true,
            hint: '',
            darkMode: false,
            customBodyCssStyle: bodyCssStyleForEditor
          ),
          blockQuotedContent: initContent,
          htmlToolbarOptions: const HtmlToolbarOptions(
            toolbarType: ToolbarType.hide,
            defaultToolbarButtons: []
          ),
          otherOptions: const OtherOptions(height: 550),
          callbacks: Callbacks(
            onBeforeCommand: controller.onChangeTextEditorWeb,
            onChangeContent: controller.onChangeTextEditorWeb,
            onInit: () => controller.handleInitHtmlEditorWeb(initContent),
            onFocus: controller.handleOnFocusHtmlEditorWeb,
            onBlur: controller.handleOnUnFocusHtmlEditorWeb,
            onMouseDown: () => controller.handleOnMouseDownHtmlEditorWeb(context),
            onChangeSelection: controller.richTextWebController.onEditorSettingsChange,
            onChangeCodeview: controller.onChangeTextEditorWeb
          ),
        )
      )
    );
  }

  Widget _buildAttachmentsWidget(BuildContext context) {
    return Obx(() {
      final attachments = controller.uploadController.listUploadAttachments;
      if (attachments.isNotEmpty) { 
        return Column(children: [
          Padding(
              padding: EdgeInsets.only(
                top: 4,
                bottom: 4,
                left: AppUtils.isDirectionRTL(context) ? responsiveUtils.isMobile(context) ? 16: 0 : responsiveUtils.isMobile(context) ? 16 : 20,
                right: AppUtils.isDirectionRTL(context) ? responsiveUtils.isMobile(context) ? 16 : 20 : responsiveUtils.isMobile(context) ? 16: 0),
              child: _buildAttachmentsTitle(
                  context,
                  attachments,
                  controller.expandModeAttachments.value)),
          Padding(
              padding: EdgeInsets.only(
                  left: responsiveUtils.isMobile(context) ? 16 : 10,
                  right: responsiveUtils.isMobile(context) ? 16 : 10),
              child: _buildAttachmentsList(
                  context,
                  attachments,
                  controller.expandModeAttachments.value))
        ]);
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  Widget _buildAttachmentsTitle(
      BuildContext context,
      List<UploadFileState> uploadFilesState,
      ExpandMode expandModeAttachment) {
    return Row(
      children: [
        Text(
          '${AppLocalizations.of(context).attachments} (${filesize(uploadFilesState.totalSize, 0)}):',
          style: const TextStyle(fontSize: 12, color: AppColor.colorHintEmailAddressInput, fontWeight: FontWeight.normal)),
        const Spacer(),
        TextButton(
          onPressed: () => controller.toggleDisplayAttachments(),
          child: Material(
            type: MaterialType.circle,
            color: Colors.transparent,
            child: Text(
              expandModeAttachment == ExpandMode.EXPAND
                ? AppLocalizations.of(context).hide
                : '${AppLocalizations.of(context).showAll} (${uploadFilesState.length})',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: AppColor.colorTextButton))
          ),
        )
      ],
    );
  }

  Widget _buildAttachmentsList(
      BuildContext context,
      List<UploadFileState> uploadFilesState,
      ExpandMode expandMode) {
    if (expandMode == ExpandMode.COLLAPSE) {
      return const SizedBox.shrink();
    } else {
      return LayoutBuilder(builder: (context, constraints) {
        return Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            height: 60,
            child: ScrollConfiguration(
              behavior: CustomScrollBehavior(),
              child: ListView.builder(
                key: const Key('list_attachment_minimize'),
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                controller: controller.scrollControllerAttachment,
                itemCount: uploadFilesState.length,
                itemBuilder: (context, index) => AttachmentFileComposerBuilder(
                  uploadFilesState[index],
                  itemMargin: EdgeInsets.only(
                    right: AppUtils.isDirectionRTL(context) ? 0 : 8,
                    left: AppUtils.isDirectionRTL(context) ? 8 : 0
                  ),
                  maxWidth: _getMaxWidthItemListAttachment(context, constraints),
                  onDeleteAttachmentAction: (attachment) => controller.deleteAttachmentUploaded(attachment.uploadTaskId))
              ),
            )
          )
        );
      });
    }
  }

  int _getMaxItemRowListAttachment(BuildContext context, BoxConstraints constraints) {
    if (constraints.maxWidth < responsiveUtils.minTabletWidth) {
      return 2;
    } else if (constraints.maxWidth < responsiveUtils.minTabletLargeWidth) {
      return 3;
    } else {
      return 4;
    }
  }

  double _getMaxWidthItemListAttachment(BuildContext context, BoxConstraints constraints) {
    final currentWidth = constraints.maxWidth - 40;
    return currentWidth / _getMaxItemRowListAttachment(context, constraints);
  }

  double _getMaxHeightEmailAddressWidget(BuildContext context, BoxConstraints constraints) {
    if (responsiveUtils.isDesktop(context)) {
      return constraints.maxHeight > 0 ? constraints.maxHeight * 0.3 : 150.0;
    } else {
      return constraints.maxHeight > 0 ? constraints.maxHeight * 0.4 : 150.0;
    }
  }
}