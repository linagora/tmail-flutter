
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/widget/drop_down_button_widget.dart';
import 'package:tmail_ui_user/features/base/widget/popup_menu_overlay_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/controller/rich_text_web_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/button_layout_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/dropdown_menu_font_status.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/font_name_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/header_style_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/order_list_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/paragraph_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/rich_text_style_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/drop_down_menu_header_style_widget.dart';

mixin RichTextButtonMixin {

  final _imagePaths = Get.find<ImagePaths>();

  Widget buildWrapIconStyleText({
    required Widget icon,
    VoidCallback? onTap,
    bool isSelected = false,
    bool hasDropdown = true,
    EdgeInsets? padding,
    double? spacing,
    String tooltip = '',
  }){
    late Widget buttonIcon;
    if (tooltip.isNotEmpty) {
      buttonIcon = Tooltip(
        message: tooltip,
        child: Container(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          decoration: BoxDecoration(
              color: isSelected == true
                  ? AppColor.colorBackgroundWrapIconStyleCode
                  : Colors.white,
              border: Border.all(
                  color: AppColor.colorBorderWrapIconStyleCode,
                  width: 0.5),
              borderRadius: BorderRadius.circular(8)),
          child: hasDropdown
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    icon,
                    if (spacing != null) SizedBox(width: spacing),
                    SvgPicture.asset(_imagePaths.icStyleArrowDown)
                  ])
              : icon,
        ),
      );
    } else {
      buttonIcon = Container(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        decoration: BoxDecoration(
            color: isSelected == true
                ? AppColor.colorBackgroundWrapIconStyleCode
                : Colors.white,
            border: Border.all(
                color: AppColor.colorBorderWrapIconStyleCode,
                width: 0.5),
            borderRadius: BorderRadius.circular(8)),
        child: hasDropdown
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  icon,
                  if (spacing != null) SizedBox(width: spacing),
                  SvgPicture.asset(_imagePaths.icStyleArrowDown)
                ])
            : icon,
      );
    }

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        child: buttonIcon,
      );
    } else {
      return buttonIcon;
    }
  }

  Widget buildIconStyleText({
    required String path,
    required bool? isSelected,
    required VoidCallback onTap,
    String? tooltip,
    double opacity = 1.0,
  }){
    return buildIconWeb(
      icon: SvgPicture.asset(
          path,
          colorFilter: isSelected == true
            ? Colors.black.withOpacity(opacity).asFilter()
            : AppColor.colorDefaultRichTextButton.withOpacity(opacity).asFilter(),
          fit: BoxFit.fill),
      iconPadding: const EdgeInsets.all(4),
      colorFocus: Colors.white,
      minSize: 26,
      tooltip: tooltip,
      onTap: onTap,
    );
  }

  Widget buildIconWithTooltip({
    required String path,
    Color? color,
    String? tooltip,
    double opacity = 1.0,
    bool excludeFromSemantics = false,
  }){
    final newColor = color == Colors.white
        ? AppColor.colorDefaultRichTextButton
        : color;

    return tooltip?.isNotEmpty == true
      ? Tooltip(
          message: tooltip,
          child: SvgPicture.asset(
            path,
            excludeFromSemantics: excludeFromSemantics,
            colorFilter: newColor?.withOpacity(opacity).asFilter(),
            fit: BoxFit.fill))
      : SvgPicture.asset(
          path,
          colorFilter: newColor?.withOpacity(opacity).asFilter(),
          fit: BoxFit.fill);
  }

  Widget buildIcon({
    required String path,
    Color? color,
    double opacity = 1.0,
  }){
    final newColor = color == Colors.white
        ? AppColor.colorDefaultRichTextButton
        : color;

    return SvgPicture.asset(
      path,
      colorFilter: newColor?.withOpacity(opacity).asFilter(),
      fit: BoxFit.fill);
  }

  Widget buildIconColorBackgroundTextWithoutTooltip({
    required IconData? iconData,
    required Color? colorSelected,
    double opacity = 1.0,
  }){
    final newColor = colorSelected == Colors.white
        ? AppColor.colorDefaultRichTextButton
        : colorSelected;
    return Icon(iconData,
        color: (newColor ?? AppColor.colorDefaultRichTextButton).withOpacity(opacity),
        size: 20);
  }

  Widget buildIconColorBackgroundText({
    required IconData? iconData,
    required Color? colorSelected,
    String? tooltip,
    double opacity = 1.0,
  }){
    final newColor = colorSelected == Colors.white
        ? AppColor.colorDefaultRichTextButton
        : colorSelected;
    return Tooltip(
      message: tooltip,
      child: Icon(iconData,
          color: (newColor ?? AppColor.colorDefaultRichTextButton).withOpacity(opacity),
          size: 20),
    );
  }

  Widget buildToolbarRichTextForWeb(
      BuildContext context,
      RichTextWebController richTextController,
      {ButtonLayoutType layoutType = ButtonLayoutType.wrapParent}
  ) {
    late Widget parentRichTextButton;

    switch(layoutType) {
      case ButtonLayoutType.scrollHorizontal:
        parentRichTextButton = Container(
          alignment: Alignment.center,
          color: Colors.transparent,
          height: 38,
          child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              children: listButtonActionForRichText(context, richTextController)),
        );
        break;
      case ButtonLayoutType.scrollVertical:
        parentRichTextButton = ListView(
            scrollDirection: Axis.horizontal,
            children: listButtonActionForRichText(context, richTextController));
        break;
      case ButtonLayoutType.wrapParent:
        parentRichTextButton = Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 8,
            children: listButtonActionForRichText(context, richTextController)
        );
        break;
    }

    return Container(
      alignment: Alignment.center,
      color: Colors.transparent,
      height: 50,
      child: parentRichTextButton,
    );
  }

  List<Widget> listButtonActionForRichText(
      BuildContext context,
      RichTextWebController richTextController
  ) {
    return [
      DropDownMenuHeaderStyleWidget(
          icon: buildWrapIconStyleText(
              isSelected: richTextController.isMenuHeaderStyleOpen,
              icon: SvgPicture.asset(
                RichTextStyleType.headerStyle.getIcon(_imagePaths),
                colorFilter: AppColor.colorDefaultRichTextButton.asFilter(),
                fit: BoxFit.fill),
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              tooltip: RichTextStyleType.headerStyle.getTooltipButton(context)
          ),
          items: HeaderStyleType.values,
          onMenuStateChange: (isOpen) {
            final newStatus = isOpen
                ? DropdownMenuFontStatus.open
                : DropdownMenuFontStatus.closed;
            richTextController.menuHeaderStyleStatus.value = newStatus;
          },
          onChanged: (newStyle) => richTextController.applyHeaderStyle(newStyle)),
      Container(
          width: 130,
          padding: const EdgeInsets.only(left: 4.0, right: 4.0),
          child: DropDownButtonWidget<FontNameType>(
              items: FontNameType.values,
              itemSelected: richTextController.selectedFontName.value,
              onChanged: (newFont) => richTextController.applyNewFontStyle(newFont),
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
              iconArrowDown: SvgPicture.asset(_imagePaths.icStyleArrowDown),
              tooltip: RichTextStyleType.fontName.getTooltipButton(context),
              supportSelectionIcon: true)),
      Padding(
        padding: const EdgeInsets.only(right: 4.0),
        child: buildWrapIconStyleText(
            icon: buildIconWithTooltip(
              path: RichTextStyleType.textColor.getIcon(_imagePaths),
              color: richTextController.selectedTextColor.value,
              tooltip: RichTextStyleType.textColor.getTooltipButton(context),
              excludeFromSemantics: true
            ),
            onTap: () => richTextController.applyRichTextStyle(context, RichTextStyleType.textColor)),
      ),
      Padding(
        padding: const EdgeInsets.only(right: 4.0),
        child: buildWrapIconStyleText(
            padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 7),
            spacing: 3,
            icon: buildIconColorBackgroundText(
              iconData: RichTextStyleType.textBackgroundColor.getIconData(),
              colorSelected: richTextController.selectedTextBackgroundColor.value,
              tooltip: RichTextStyleType.textBackgroundColor.getTooltipButton(context),
            ),
            onTap: () => richTextController.applyRichTextStyle(context, RichTextStyleType.textBackgroundColor)),
      ),
      Padding(
        padding: const EdgeInsets.only(right: 4.0),
        child: buildWrapIconStyleText(
            hasDropdown: false,
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
            icon: Wrap(children: [
              buildIconStyleText(
                  path: RichTextStyleType.bold.getIcon(_imagePaths),
                  isSelected: richTextController.isTextStyleTypeSelected(RichTextStyleType.bold),
                  tooltip: RichTextStyleType.bold.getTooltipButton(context),
                  onTap: () => richTextController.applyRichTextStyle(context, RichTextStyleType.bold)),
              buildIconStyleText(
                  path: RichTextStyleType.italic.getIcon(_imagePaths),
                  isSelected: richTextController.isTextStyleTypeSelected(RichTextStyleType.italic),
                  tooltip: RichTextStyleType.italic.getTooltipButton(context),
                  onTap: () => richTextController.applyRichTextStyle(context, RichTextStyleType.italic)),
              buildIconStyleText(
                  path: RichTextStyleType.underline.getIcon(_imagePaths),
                  isSelected: richTextController.isTextStyleTypeSelected(RichTextStyleType.underline),
                  tooltip: RichTextStyleType.underline.getTooltipButton(context),
                  onTap: () => richTextController.applyRichTextStyle(context, RichTextStyleType.underline)),
              buildIconStyleText(
                  path: RichTextStyleType.strikeThrough.getIcon(_imagePaths),
                  isSelected: richTextController.isTextStyleTypeSelected(RichTextStyleType.strikeThrough),
                  tooltip: RichTextStyleType.strikeThrough.getTooltipButton(context),
                  onTap: () => richTextController.applyRichTextStyle(context, RichTextStyleType.strikeThrough))
            ])),
      ),
      Padding(
        padding: const EdgeInsets.only(right: 4.0),
        child: PopupMenuOverlayWidget(
          controller: richTextController.menuParagraphController,
          listButtonAction: ParagraphType.values
              .map((paragraph) => paragraph.buildButtonWidget(
                  context,
                  _imagePaths,
                  (paragraph) => richTextController.applyParagraphType(paragraph)))
              .toList(),
          iconButton: buildWrapIconStyleText(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              spacing: 3,
              isSelected: richTextController.focusMenuParagraph.value,
              icon: buildIconWithTooltip(
                  path: richTextController.selectedParagraph.value.getIcon(_imagePaths),
                  color: AppColor.colorDefaultRichTextButton,
                  tooltip: RichTextStyleType.paragraph.getTooltipButton(context),
                  excludeFromSemantics: true)),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(right: 4.0),
        child: PopupMenuOverlayWidget(
          controller: richTextController.menuOrderListController,
          listButtonAction: OrderListType.values
              .map((orderType) => orderType.buildButtonWidget(
                  context,
                  _imagePaths,
                  (orderType) => richTextController.applyOrderListType(orderType)))
              .toList(),
          iconButton: buildWrapIconStyleText(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              spacing: 3,
              isSelected: richTextController.focusMenuOrderList.value,
              icon: buildIconWithTooltip(
                  path: richTextController.selectedOrderList.value.getIcon(_imagePaths),
                  color: AppColor.colorDefaultRichTextButton,
                  tooltip: RichTextStyleType.orderList.getTooltipButton(context),
                  excludeFromSemantics: true)),
        ),
      )
    ];
  }
}