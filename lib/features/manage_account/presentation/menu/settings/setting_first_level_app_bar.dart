import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/account_menu_item.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class SettingFirstLevelAppBar extends StatelessWidget {
  final AccountMenuItem accountMenuItem;
  final ImagePaths imagePaths;
  final ResponsiveUtils responsiveUtils;
  final VoidCallback onBackAction;

  const SettingFirstLevelAppBar({
    super.key,
    required this.accountMenuItem,
    required this.imagePaths,
    required this.responsiveUtils,
    required this.onBackAction,
  });

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return Container(
      height: 64,
      padding: _getPadding(context),
      child: Stack(
        alignment: Alignment.center,
        children: [
          PositionedDirectional(
            start: 0,
            child: TMailButtonWidget.fromIcon(
              icon: imagePaths.icArrowBack,
              tooltipMessage: appLocalizations.back,
              backgroundColor: Colors.transparent,
              onTapActionCallback: onBackAction,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Text(
                accountMenuItem.getName(appLocalizations),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ThemeUtils.textStyleM3BodyLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }

  EdgeInsetsGeometry _getPadding(BuildContext context) {
    if (responsiveUtils.isPortraitMobile(context)) {
      return const EdgeInsetsDirectional.symmetric(horizontal: 16);
    } else if (responsiveUtils.isLandscapeMobile(context)) {
      return const EdgeInsetsDirectional.symmetric(horizontal: 24);
    } else {
      return const EdgeInsetsDirectional.symmetric(horizontal: 32);
    }
  }
}
