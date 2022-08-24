import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/views/button/button_builder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/forward_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class ForwardHeaderWidget extends GetWidget<ForwardController> {
  const ForwardHeaderWidget({
    Key? key,
    required this.imagePaths,
    required this.responsiveUtils,
  }) : super(key: key);

  final ImagePaths imagePaths;
  final ResponsiveUtils responsiveUtils;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColor.colorBackgroundWrapIconStyleCode,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(AppLocalizations.of(context).forwarding,
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
        const SizedBox(height: 24),
        _buildButtonAddNewEmailsForward(context),
        const SizedBox(height: 24),
        Obx(() => _buildButtonSwitchKeepLocalCopy(context)),
      ]),
    );
  }

  Widget _buildButtonAddNewEmailsForward(BuildContext context) {
    if (!responsiveUtils.isMobile(context)) {
      return (ButtonBuilder(imagePaths.icAddEmailForward)
          ..key(const Key('button_add_emails_forward'))
          ..decoration(BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColor.colorTextButton))
          ..paddingIcon(const EdgeInsets.only(right: 8))
          ..iconColor(Colors.white)
          ..maxWidth(170)
          ..size(20)
          ..radiusSplash(10)
          ..padding(const EdgeInsets.symmetric(vertical: 12))
          ..textStyle(const TextStyle(
            fontSize: 17,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ))
          ..onPressActionClick(() => controller.goToAddEmailsForward())
          ..text(
            AppLocalizations.of(context).addRecipients,
            isVertical: false,
          ))
        .build();
    } else {
      return (ButtonBuilder(imagePaths.icAddEmailForward)
          ..key(const Key('button_add_emails_forward'))
          ..decoration(BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColor.colorTextButton))
          ..paddingIcon(const EdgeInsets.only(right: 8))
          ..iconColor(Colors.white)
          ..size(20)
          ..radiusSplash(10)
          ..padding(const EdgeInsets.symmetric(vertical: 12))
          ..textStyle(const TextStyle(
            fontSize: 17,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ))
          ..onPressActionClick(() => controller.goToAddEmailsForward())
          ..text(
            AppLocalizations.of(context).addRecipients,
            isVertical: false,
          ))
        .build();
    }
  }

  Widget _buildButtonSwitchKeepLocalCopy(BuildContext context) {
    if(controller.currentForward.value != null) {
      return SizedBox(
        width: 250,
        child: SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 0),
          title: Text(AppLocalizations.of(context).keepLocalCopyForwardLabel,
              overflow: CommonTextStyle.defaultTextOverFlow,
              softWrap: CommonTextStyle.defaultSoftWrap,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.black)),
          value: controller.currentForwardLocalCopyState,
          onChanged: (_) {
            controller.handleEditLocalCopy();
          },
          controlAffinity: ListTileControlAffinity.trailing,
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
