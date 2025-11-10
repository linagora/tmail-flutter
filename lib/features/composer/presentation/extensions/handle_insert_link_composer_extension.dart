import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

extension HandleInsertLinkComposerExtension on ComposerController {
  void openInsertLink() {
    richTextWebController?.openInsertLink();
  }

  LinkOverlayOptions createLinkOverlayOptions(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    return LinkOverlayOptions(
      tooltipOptions: LinkTooltipOverlayOptions(
        linkPrefixLabel: '${appLocalizations.goTo}:',
        editLinkLabel: appLocalizations.change,
        removeLinkTooltipMessage: appLocalizations.removeLink,
        linkPrefixLabelStyle: ThemeUtils.textStyleBodyBody3(
          color: AppColor.gray900,
        ),
        linkLabelStyle: ThemeUtils.textStyleBodyBody3(
          color: AppColor.blue700,
        ),
        editLinkLabelStyle: ThemeUtils.textStyleBodyBody3(
          color: AppColor.primaryMain,
        ),
        removeLinkButtonBuilder: (_, onTap) => TMailButtonWidget.fromIcon(
          icon: imagePaths.icRemoveLink,
          iconSize: 20,
          iconColor: AppColor.primaryLinShare,
          backgroundColor: Colors.transparent,
          onTapActionCallback: onTap,
        ),
      ),
      editDialogOptions: LinkEditDialogOverlayOptions(
        hintText: appLocalizations.text,
        hintUrl: appLocalizations.typeOrPasteLink,
        applyButtonLabel: appLocalizations.apply,
        hintTextStyle: ThemeUtils.textStyleBodyBody3(
          color: AppColor.steelGray400,
        ),
        inputTextStyle: ThemeUtils.textStyleBodyBody3(
          color: AppColor.gray900,
        ),
        applyButtonTextStyle: (isEnabled) => ThemeUtils.textStyleM3LabelLarge(
          color: isEnabled ? AppColor.primaryMain : AppColor.gray400,
        ),
        textPrefixIcon: SvgPicture.asset(
          imagePaths.icText,
          width: 24,
          height: 24,
          fit: BoxFit.fill,
        ),
        urlPrefixIcon: SvgPicture.asset(
          imagePaths.icInsertLink,
          width: 24,
          height: 24,
          fit: BoxFit.fill,
        ),
        backgroundColor: Colors.white,
        inputBackgroundColor: Colors.white,
        dialogPadding: const EdgeInsetsDirectional.only(
          start: 16,
          end: 12,
          top: 16,
          bottom: 16,
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(
            width: 1,
            color: AppColor.m3Neutral90,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(
            width: 1,
            color: AppColor.primaryMain,
          ),
        ),
      ),
    );
  }
}
