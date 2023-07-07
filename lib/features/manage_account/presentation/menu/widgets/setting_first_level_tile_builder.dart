import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/menu/settings_utils.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

typedef SettingFirstLevelTileClickAction = void Function();

class SettingFirstLevelTileBuilder extends StatelessWidget {
  SettingFirstLevelTileBuilder(
    this.title,
    this.settingIcon,
    this.clickAction,
    {
      Key? key,
      this.subtitle
    }
  ) : super(key: key);

  final _responsiveUtils = Get.find<ResponsiveUtils>();
  final _imagePath = Get.find<ImagePaths>();

  final String settingIcon;
  final String title;
  final String? subtitle;
  final SettingFirstLevelTileClickAction clickAction;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: clickAction,
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(vertical: 24),
          child: Row(
            children: [
              Expanded(flex: 9, child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          right: AppUtils.isDirectionRTL(context) ? SettingsUtils.getHorizontalPadding(context, _responsiveUtils) : 0,
                          left: AppUtils.isDirectionRTL(context) ? 0 : SettingsUtils.getHorizontalPadding(context, _responsiveUtils),
                        ),
                        child: _buildSettingIcon(context)),
                      Expanded(child: Padding(
                        padding: const EdgeInsets.only(left: 12, right: 12),
                        child: Text(
                          title,
                          maxLines: 1,
                          softWrap: CommonTextStyle.defaultSoftWrap,
                          overflow: CommonTextStyle.defaultTextOverFlow,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColor.colorNameEmail,
                            fontWeight: FontWeight.w400,
                          )
                        )
                      ))
                    ],
                  ),
                  subtitle != null
                    ? Padding(
                        padding: EdgeInsets.only(
                          left: AppUtils.isDirectionRTL(context) ? 12 : _getSubtitleLeftPadding(context),
                          right: AppUtils.isDirectionRTL(context) ? _getSubtitleLeftPadding(context) : 12,
                          top: 12
                        ),
                        child: Text(
                          subtitle!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColor.colorContentEmail,
                            fontWeight: FontWeight.w400)))
                    : const SizedBox.shrink()
                ]
              )),
              IconButton(
               padding: EdgeInsets.only(
                 right: AppUtils.isDirectionRTL(context) ? 0 : SettingsUtils.getHorizontalPadding(context, _responsiveUtils),
                 left: AppUtils.isDirectionRTL(context) ? SettingsUtils.getHorizontalPadding(context, _responsiveUtils) : 0,
               ),
               icon: SvgPicture.asset(
                 DirectionUtils.isDirectionRTLByLanguage(context) ? _imagePath.icBack : _imagePath.icCollapseFolder,
                 fit: BoxFit.fill,
                 colorFilter: AppColor.colorCollapseMailbox.asFilter()),
               onPressed: clickAction
            )
          ])),
      ),
    );
  }

  Widget _buildSettingIcon(BuildContext context) {
    return SvgPicture.asset(settingIcon, height: 24, width: 24, fit: BoxFit.fill);
  }

  double _getSubtitleLeftPadding(BuildContext context) {
    return SettingsUtils.getHorizontalPadding(context, _responsiveUtils) + 12 + 24;
  }
}
