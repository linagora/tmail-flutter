
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class DefaultAppBarWidget extends StatelessWidget {
  final String title;
  final ImagePaths imagePaths;
  final ResponsiveUtils responsiveUtils;
  final VoidCallback onBackAction;

  const DefaultAppBarWidget({
    Key? key,
    required this.title,
    required this.imagePaths,
    required this.responsiveUtils,
    required this.onBackAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: _getPadding(context),
      color: Colors.white,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ThemeUtils.textStyleM3BodyLarge,
              ),
            ),
          ),
          PositionedDirectional(
            start: 0,
            child: TMailButtonWidget.fromIcon(
              icon: imagePaths.icArrowBack,
              tooltipMessage: AppLocalizations.of(context).back,
              backgroundColor: Colors.transparent,
              onTapActionCallback: onBackAction,
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
