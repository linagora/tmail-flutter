
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/contact/presentation/styles/app_bar_contact_widget_style.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class AppBarContactWidget extends StatelessWidget {

  final String? title;
  final ImagePaths imagePaths;
  final ResponsiveUtils responsiveUtils;
  final VoidCallback onCloseContactView;

  const AppBarContactWidget({
    Key? key,
    required this.title,
    required this.imagePaths,
    required this.responsiveUtils,
    required this.onCloseContactView,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      color: Colors.white,
      padding: AppBarContactWidgetStyle.getAppBarPadding(
        context,
        responsiveUtils
      ),
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            title ?? AppLocalizations.of(context).contact,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          PositionedDirectional(
            end: 0,
            child: TMailButtonWidget.fromIcon(
              icon: imagePaths.icClose,
              tooltipMessage: AppLocalizations.of(context).close,
              iconSize: 24,
              padding: const EdgeInsets.all(3),
              iconColor: AppColor.colorCloseButton,
              backgroundColor: AppColor.colorCloseButton.withValues(alpha: 0.12),
              onTapActionCallback: onCloseContactView,
            )
          ),
        ]
      ),
    );
  }
}