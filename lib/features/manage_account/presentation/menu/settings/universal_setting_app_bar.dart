import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/multi_click_widget.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/logger/log_tracking.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class UniversalSettingAppBar extends StatelessWidget {
  final ImagePaths imagePaths;
  final ResponsiveUtils responsiveUtils;
  final VoidCallback onBackAction;
  final VoidCallback? onExportTraceLogAction;

  const UniversalSettingAppBar({
    super.key,
    required this.imagePaths,
    required this.responsiveUtils,
    required this.onBackAction,
    this.onExportTraceLogAction,
  });

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    Widget appBarWidget = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 52,
          padding: _getPadding(context),
          child: Stack(
            alignment: Alignment.center,
            children: [
              PositionedDirectional(
                start: 24,
                child: TMailButtonWidget.fromIcon(
                  icon: imagePaths.icClose,
                  iconSize: 28,
                  padding: const EdgeInsets.all(5),
                  tooltipMessage: appLocalizations.close,
                  backgroundColor: Colors.transparent,
                  onTapActionCallback: onBackAction,
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60),
                  child: Text(
                    appLocalizations.settings,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ThemeUtils.textStyleInter700().copyWith(
                      fontSize: 20,
                      height: 24 / 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(color: Colors.black12),
      ],
    );

    if (onExportTraceLogAction != null && LogTracking().isEnabled) {
      return MultiClickWidget(
        onMultiTap: onExportTraceLogAction!,
        child: appBarWidget,
      );
    } else {
      return appBarWidget;
    }
  }

  EdgeInsetsGeometry _getPadding(BuildContext context) {
    if (responsiveUtils.isPortraitMobile(context)) {
      return EdgeInsetsDirectional.zero;
    } else {
      return const EdgeInsetsDirectional.symmetric(horizontal: 16);
    }
  }
}
