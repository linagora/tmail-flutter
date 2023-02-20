import 'dart:developer';

import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/widget/drop_down_button_widget.dart';
import 'package:tmail_ui_user/features/base/widget/popup_menu_overlay_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/controller/rich_text_web_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/mixin/rich_text_button_mixin.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/dropdown_menu_font_status.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/font_name_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/header_style_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/order_list_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/paragraph_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/rich_text_style_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/drop_down_menu_header_style_widget.dart';

class ToolbarRichTextWebBuilder extends StatelessWidget with RichTextButtonMixin {

  final RichTextWebController richTextWebController;
  final ImagePaths _imagePaths = Get.find<ImagePaths>();
  final EdgeInsetsGeometry? padding;

  ToolbarRichTextWebBuilder({
    Key? key,
    required this.richTextWebController,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final codeViewEnabled = richTextWebController.codeViewEnabled;
      final opacity = codeViewEnabled ? 0.5 : 1.0;

      return Container(
        padding: padding ?? const EdgeInsets.only(left: 20, top: 8, bottom: 8),
        alignment: Alignment.centerLeft,
        child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 8,
            children: [
              AbsorbPointer(
                absorbing: codeViewEnabled,
                child: DropDownMenuHeaderStyleWidget(
                    icon: buildWrapIconStyleText(
                        isSelected: richTextWebController.isMenuHeaderStyleOpen,
                        icon: SvgPicture.asset(RichTextStyleType.headerStyle.getIcon(_imagePaths),
                            color: AppColor.colorDefaultRichTextButton.withOpacity(opacity),
                            fit: BoxFit.fill),
                        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                        tooltip: RichTextStyleType.headerStyle.getTooltipButton(context)
                    ),
                    items: HeaderStyleType.values,
                    onMenuStateChange: (isOpen) {
                      log('ComposerView::_buildToolbarRichTextWidget(): MenuHeaderStyleStatus: $isOpen');
                      final newStatus = isOpen
                          ? DropdownMenuFontStatus.open
                          : DropdownMenuFontStatus.closed;
                      richTextWebController.menuHeaderStyleStatus.value = newStatus;
                    },
                    onChanged: (newStyle) => richTextWebController.applyHeaderStyle(newStyle)),
              ),
              AbsorbPointer(
                absorbing: codeViewEnabled,
                child: Container(
                    width: 130,
                    padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                    child: DropDownButtonWidget<FontNameType>(
                        items: FontNameType.values,
                        itemSelected: richTextWebController.selectedFontName.value,
                        onChanged: (newFont) => richTextWebController.applyNewFontStyle(newFont),
                        onMenuStateChange: (isOpen) {
                          log('ComposerView::_buildToolbarRichTextWidget(): MenuFontStatus: $isOpen');
                          final newStatus = isOpen
                              ? DropdownMenuFontStatus.open
                              : DropdownMenuFontStatus.closed;
                          richTextWebController.menuFontStatus.value = newStatus;
                        },
                        heightItem: 40,
                        sizeIconChecked: 16,
                        radiusButton: 8,
                        opacity: opacity,
                        dropdownWidth: 200,
                        colorButton: richTextWebController.isMenuFontOpen
                            ? AppColor.colorBackgroundWrapIconStyleCode
                            : Colors.white,
                        iconArrowDown: SvgPicture.asset(_imagePaths.icStyleArrowDown),
                        tooltip: RichTextStyleType.fontName.getTooltipButton(context),
                        supportSelectionIcon: true)),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: AbsorbPointer(
                  absorbing: codeViewEnabled,
                  child: buildWrapIconStyleText(
                      icon: buildIconWithTooltip(
                          path: RichTextStyleType.textColor.getIcon(_imagePaths),
                          color: richTextWebController.selectedTextColor.value,
                          tooltip: RichTextStyleType.textColor.getTooltipButton(context),
                          opacity: opacity),
                      onTap: () => richTextWebController.applyRichTextStyle(context, RichTextStyleType.textColor)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: AbsorbPointer(
                  absorbing: codeViewEnabled,
                  child: buildWrapIconStyleText(
                      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 7),
                      spacing: 3,
                      icon: buildIconColorBackgroundText(
                          iconData: RichTextStyleType.textBackgroundColor.getIconData(),
                          colorSelected: richTextWebController.selectedTextBackgroundColor.value,
                          tooltip: RichTextStyleType.textBackgroundColor.getTooltipButton(context),
                          opacity: opacity),
                      onTap: () => richTextWebController.applyRichTextStyle(context, RichTextStyleType.textBackgroundColor)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: buildWrapIconStyleText(
                    hasDropdown: false,
                    padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                    icon: Wrap(children: [
                      AbsorbPointer(
                        absorbing: codeViewEnabled,
                        child: buildIconStyleText(
                            path: RichTextStyleType.bold.getIcon(_imagePaths),
                            isSelected: richTextWebController.isTextStyleTypeSelected(RichTextStyleType.bold),
                            tooltip: RichTextStyleType.bold.getTooltipButton(context),
                            opacity: opacity,
                            onTap: () => richTextWebController.applyRichTextStyle(context, RichTextStyleType.bold)),
                      ),
                      AbsorbPointer(
                        absorbing: codeViewEnabled,
                        child: buildIconStyleText(
                            path: RichTextStyleType.italic.getIcon(_imagePaths),
                            isSelected: richTextWebController.isTextStyleTypeSelected(RichTextStyleType.italic),
                            tooltip: RichTextStyleType.italic.getTooltipButton(context),
                            opacity: opacity,
                            onTap: () => richTextWebController.applyRichTextStyle(context, RichTextStyleType.italic)),
                      ),
                      AbsorbPointer(
                        absorbing: codeViewEnabled,
                        child: buildIconStyleText(
                            path: RichTextStyleType.underline.getIcon(_imagePaths),
                            isSelected: richTextWebController.isTextStyleTypeSelected(RichTextStyleType.underline),
                            tooltip: RichTextStyleType.underline.getTooltipButton(context),
                            opacity: opacity,
                            onTap: () => richTextWebController.applyRichTextStyle(context, RichTextStyleType.underline)),
                      ),
                      AbsorbPointer(
                        absorbing: codeViewEnabled,
                        child: buildIconStyleText(
                            path: RichTextStyleType.strikeThrough.getIcon(_imagePaths),
                            isSelected: richTextWebController.isTextStyleTypeSelected(
                                RichTextStyleType.strikeThrough),
                            tooltip: RichTextStyleType.strikeThrough.getTooltipButton(context),
                            opacity: opacity,
                            onTap: () => richTextWebController.applyRichTextStyle(context, RichTextStyleType.strikeThrough)),
                      )
                    ])),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: AbsorbPointer(
                  absorbing: codeViewEnabled,
                  child: PopupMenuOverlayWidget(
                    controller: richTextWebController.menuParagraphController,
                    listButtonAction: ParagraphType.values
                      .map((paragraph) => paragraph.buildButtonWidget(
                          context,
                          _imagePaths,
                          (paragraph) => richTextWebController.applyParagraphType(paragraph)))
                      .toList(),
                    iconButton: buildWrapIconStyleText(
                        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                        spacing: 3,
                        isSelected: richTextWebController.focusMenuParagraph.value,
                        icon: buildIconWithTooltip(
                          path: richTextWebController.selectedParagraph.value.getIcon(_imagePaths),
                          color: AppColor.colorDefaultRichTextButton,
                          opacity: opacity,
                          tooltip: RichTextStyleType.paragraph.getTooltipButton(context))),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: AbsorbPointer(
                  absorbing: codeViewEnabled,
                  child: PopupMenuOverlayWidget(
                    controller: richTextWebController.menuOrderListController,
                    listButtonAction: OrderListType.values
                      .map((orderType) => orderType.buildButtonWidget(
                        context,
                        _imagePaths,
                        (orderType) => richTextWebController.applyOrderListType(orderType)))
                      .toList(),
                    iconButton: buildWrapIconStyleText(
                      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                      spacing: 3,
                      isSelected: richTextWebController.focusMenuOrderList.value,
                      icon: buildIconWithTooltip(
                        path: richTextWebController.selectedOrderList.value.getIcon(_imagePaths),
                        color: AppColor.colorDefaultRichTextButton,
                        opacity: opacity,
                        tooltip: RichTextStyleType.orderList.getTooltipButton(context))),
                  ),
                ),
              )
            ]
        ),
      );
    });
  }
}