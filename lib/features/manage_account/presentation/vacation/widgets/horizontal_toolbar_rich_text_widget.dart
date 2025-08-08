import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/widget/arrow_down_icon_border_button_widget.dart';
import 'package:tmail_ui_user/features/base/widget/drop_down_button_widget.dart';
import 'package:tmail_ui_user/features/base/widget/popup_menu_overlay_widget.dart';
import 'package:tmail_ui_user/features/base/widget/scrollbar_list_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/controller/rich_text_web_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/dropdown_menu_font_status.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/font_name_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/header_style_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/order_list_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/paragraph_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/rich_text_style_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/drop_down_menu_header_style_widget.dart';

class HorizontalToolbarRichTextWidget extends StatelessWidget {
  final RichTextWebController richTextController;
  final ScrollController scrollController;
  final ImagePaths imagePaths;

  const HorizontalToolbarRichTextWidget({
    super.key,
    required this.richTextController,
    required this.scrollController,
    required this.imagePaths,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: AlignmentDirectional.bottomCenter,
      height: 50,
      child: ScrollbarListView(
        scrollBehavior: ScrollConfiguration.of(context).copyWith(
          physics: const BouncingScrollPhysics(),
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.trackpad,
          },
          scrollbars: false,
        ),
        scrollController: scrollController,
        child: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          controller: scrollController,
          padding: const EdgeInsets.only(bottom: 8),
          children: [
            DropDownMenuHeaderStyleWidget(
              icon: Obx(
                () {
                  return ArrowDownIconBorderButtonWidget(
                    imagePaths: imagePaths,
                    icon: RichTextStyleType.headerStyle.getIcon(imagePaths),
                    iconColor: AppColor.colorDefaultRichTextButton,
                    backgroundColor: richTextController.isMenuHeaderStyleOpen
                        ? AppColor.colorBackgroundWrapIconStyleCode
                        : null,
                    tooltipMessage:
                        RichTextStyleType.headerStyle.getTooltipButton(context),
                  );
                },
              ),
              items: HeaderStyleType.values,
              onMenuStateChange: (isOpen) {
                final newStatus = isOpen
                    ? DropdownMenuFontStatus.open
                    : DropdownMenuFontStatus.closed;
                richTextController.menuHeaderStyleStatus.value = newStatus;
              },
              onChanged: richTextController.applyHeaderStyle,
            ),
            Container(
              width: 130,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Obx(
                () {
                  return DropDownButtonWidget<FontNameType>(
                    items: FontNameType.values,
                    itemSelected: richTextController.selectedFontName.value,
                    onChanged: richTextController.applyNewFontStyle,
                    onMenuStateChange: (isOpen) {
                      final newStatus = isOpen
                          ? DropdownMenuFontStatus.open
                          : DropdownMenuFontStatus.closed;
                      richTextController.menuFontStatus.value = newStatus;
                    },
                    heightItem: 40,
                    sizeIconChecked: 16,
                    radiusButton: 8,
                    dropdownWidth: 200,
                    colorButton: richTextController.isMenuFontOpen
                        ? AppColor.colorBackgroundWrapIconStyleCode
                        : Colors.white,
                    iconArrowDown: SvgPicture.asset(imagePaths.icStyleArrowDown),
                    tooltip: RichTextStyleType.fontName.getTooltipButton(context),
                    supportSelectionIcon: true,
                  );
                },
              ),
            ),
            Center(
              child: Obx(
                () {
                  final textColor = richTextController
                      .selectedTextColor
                      .value;

                  return ArrowDownIconBorderButtonWidget(
                    imagePaths: imagePaths,
                    icon: RichTextStyleType.textColor.getIcon(imagePaths),
                    iconColor: textColor.toInt() == Colors.white.toInt() ||
                          textColor.toInt() == 0
                        ? AppColor.colorDefaultRichTextButton
                        : textColor,
                    tooltipMessage: RichTextStyleType.textColor.getTooltipButton(
                      context,
                    ),
                    height: 40,
                    padding: const EdgeInsetsDirectional.only(end: 4.0),
                    onTap: () => richTextController.applyRichTextStyle(
                      context,
                      RichTextStyleType.textColor,
                    ),
                  );
                },
              ),
            ),
            Center(
              child: Obx(
                () {
                  final backgroundColor = richTextController
                      .selectedTextBackgroundColor
                      .value;

                  return ArrowDownIconBorderButtonWidget(
                    imagePaths: imagePaths,
                    iconData: RichTextStyleType.textBackgroundColor.getIconData(),
                    iconColor: backgroundColor.toInt() == Colors.white.toInt()
                          || backgroundColor.toInt() == 0
                        ? AppColor.colorDefaultRichTextButton
                        : backgroundColor,
                    tooltipMessage: RichTextStyleType.textBackgroundColor.getTooltipButton(
                      context,
                    ),
                    height: 40,
                    padding: const EdgeInsetsDirectional.only(end: 4.0),
                    onTap: () => richTextController.applyRichTextStyle(
                      context,
                      RichTextStyleType.textBackgroundColor,
                    ),
                  );
                },
              ),
            ),
            Center(
              child: Container(
                margin: const EdgeInsetsDirectional.only(end: 4.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColor.m3Neutral90,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                ),
                height: 40,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <RichTextStyleType>[
                    RichTextStyleType.bold,
                    RichTextStyleType.italic,
                    RichTextStyleType.underline,
                    RichTextStyleType.strikeThrough,
                  ].map((style) {
                    return Obx(
                      () {
                        final isSelected = richTextController
                            .isTextStyleTypeSelected(style);

                        return TMailButtonWidget.fromIcon(
                          icon: style.getIcon(imagePaths),
                          iconColor: isSelected
                              ? Colors.black
                              : AppColor.gray99A2AD,
                          backgroundColor: Colors.transparent,
                          padding: const EdgeInsets.all(5),
                          tooltipMessage: style.getTooltipButton(context),
                          onTapActionCallback: () =>
                              richTextController.applyRichTextStyle(context, style),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsetsDirectional.only(end: 4.0),
                child: PopupMenuOverlayWidget(
                  controller: richTextController.menuParagraphController,
                  listButtonAction: ParagraphType.values.map((paragraph) {
                    return paragraph.buildButtonWidget(
                      context,
                      imagePaths,
                      richTextController.applyParagraphType,
                    );
                  }).toList(),
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  iconButton: Obx(
                    () {
                      return ArrowDownIconBorderButtonWidget(
                        imagePaths: imagePaths,
                        icon: richTextController.selectedParagraph.value
                            .getIcon(imagePaths),
                        backgroundColor: richTextController.focusMenuParagraph.isTrue
                            ? AppColor.colorBackgroundWrapIconStyleCode
                            : null,
                        iconColor: AppColor.colorDefaultRichTextButton,
                        tooltipMessage:
                            RichTextStyleType.paragraph.getTooltipButton(context),
                      );
                    },
                  ),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsetsDirectional.only(end: 4.0),
                child: PopupMenuOverlayWidget(
                  controller: richTextController.menuOrderListController,
                  listButtonAction: OrderListType.values.map((orderType) {
                    return orderType.buildButtonWidget(
                      context,
                      imagePaths,
                      richTextController.applyOrderListType,
                    );
                  }).toList(),
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  iconButton: Obx(
                    () {
                      return ArrowDownIconBorderButtonWidget(
                        imagePaths: imagePaths,
                        icon: richTextController.selectedOrderList.value
                            .getIcon(imagePaths),
                        backgroundColor: richTextController.focusMenuOrderList.isTrue
                            ? AppColor.colorBackgroundWrapIconStyleCode
                            : null,
                        iconColor: AppColor.colorDefaultRichTextButton,
                        tooltipMessage:
                            RichTextStyleType.orderList.getTooltipButton(context),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
