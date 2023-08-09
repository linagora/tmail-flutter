
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/thread/presentation/styles/empty_emails_widget_styles.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnCreateFiltersActionCallback = Function();

class EmptyEmailsWidget extends StatelessWidget {

  final String title;
  final String? iconSVG;
  final String? subTitle;
  final OnCreateFiltersActionCallback? onCreateFiltersActionCallback;
  final Color? titleColor;

  const EmptyEmailsWidget({
    Key? key,
    required this.title,
    this.iconSVG,
    this.subTitle,
    this.onCreateFiltersActionCallback,
    this.titleColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsiveUtils = Get.find<ResponsiveUtils>();
    final childWidget = Padding(
      padding: EmptyEmailsWidgetStyles.padding,
      child: Column(
        mainAxisAlignment: responsiveUtils.isScreenWithShortestSide(context)
          ? MainAxisAlignment.start
          : MainAxisAlignment.center,
        children: [
          if (iconSVG != null)
            SvgPicture.asset(
              iconSVG!,
              width: _getIconSize(context, responsiveUtils),
              height: _getIconSize(context, responsiveUtils),
              fit: BoxFit.fill
            ),
          Padding(
            padding: EmptyEmailsWidgetStyles.labelPadding,
            child: Text(
              title,
              style: TextStyle(
                color: EmptyEmailsWidgetStyles.labelTextColor,
                fontSize: onCreateFiltersActionCallback != null
                  ? EmptyEmailsWidgetStyles.createFilterLabelTextSize
                  : EmptyEmailsWidgetStyles.labelTextSize,
                fontWeight: onCreateFiltersActionCallback != null
                  ? EmptyEmailsWidgetStyles.createFilterLabelFontWeight
                  : EmptyEmailsWidgetStyles.labelFontWeight
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (subTitle != null)
            Text(
              subTitle!,
              style: const TextStyle(
                color: EmptyEmailsWidgetStyles.messageTextColor,
                fontSize: EmptyEmailsWidgetStyles.messageTextSize,
                fontWeight: EmptyEmailsWidgetStyles.messageFontWeight
              ),
              textAlign: TextAlign.center,
            ),
          if (onCreateFiltersActionCallback != null)
            TMailButtonWidget.fromText(
              text: AppLocalizations.of(context).createFilters,
              padding: EmptyEmailsWidgetStyles.createFilterButtonPadding,
              margin: EmptyEmailsWidgetStyles.createFilterButtonMargin,
              backgroundColor: EmptyEmailsWidgetStyles.createFilterButtonBackgroundColor,
              borderRadius: EmptyEmailsWidgetStyles.createFilterButtonBorderRadius,
              width: responsiveUtils.isPortraitMobile(context) ? double.infinity : null,
              textAlign: TextAlign.center,
              textStyle: const TextStyle(
                fontSize: EmptyEmailsWidgetStyles.createFilterButtonTextSize,
                fontWeight: EmptyEmailsWidgetStyles.createFilterButtonFontWeight,
                color: EmptyEmailsWidgetStyles.createFilterButtonTextColor
              ),
              onTapActionCallback: onCreateFiltersActionCallback,
            )
        ],
      ),
    );
    return Container(
      constraints: const BoxConstraints(maxWidth: EmptyEmailsWidgetStyles.maxWidth),
      alignment: AlignmentDirectional.center,
      child: responsiveUtils.isScreenWithShortestSide(context)
        ? SingleChildScrollView(child: childWidget)
        : CustomScrollView(
            slivers: [
              SliverFillRemaining(child: childWidget)
            ]
          )
    );
  }

  double _getIconSize(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (responsiveUtils.isMobile(context)) {
      return EmptyEmailsWidgetStyles.mobileIconSize;
    } else if (responsiveUtils.isDesktop(context)) {
      return EmptyEmailsWidgetStyles.desktopIconSize;
    } else {
      return EmptyEmailsWidgetStyles.tabletIconSize;
    }
  }
}