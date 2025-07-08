
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/vacation/vacation_response.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/vacation_response_extension.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef EndNowVacationSettingAction = Function();
typedef GoToVacationSettingAction = Function();

class VacationNotificationMessageWidget extends StatelessWidget {

  final VacationResponse vacationResponse;
  final EndNowVacationSettingAction? actionEndNow;
  final GoToVacationSettingAction? actionGotoVacationSetting;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double? radius;
  final Widget? leadingIcon;
  final Color? backgroundColor;
  final FontWeight? fontWeight;
  final bool fromAccountDashBoard;

  const VacationNotificationMessageWidget({
    super.key,
    required this.vacationResponse,
    this.actionEndNow,
    this.actionGotoVacationSetting,
    this.radius,
    this.margin,
    this.padding,
    this.leadingIcon,
    this.backgroundColor,
    this.fontWeight,
    this.fromAccountDashBoard = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 12),
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius ?? 8),
        color: backgroundColor ?? AppColor.colorBackgroundNotificationVacationSetting,
      ),
      child: ResponsiveWidget(
        responsiveUtils: Get.find<ResponsiveUtils>(),
        mobile: _buildBodyForMobile(context),
        tabletLarge: fromAccountDashBoard
            ? _buildBodyForDesktop(context)
            : _buildBodyForMobile(context),
        landscapeTablet: fromAccountDashBoard
            ? _buildBodyForDesktop(context)
            : _buildBodyForMobile(context),
        desktop: _buildBodyForDesktop(context),
        tablet: _buildBodyForDesktop(context),
        landscapeMobile: _buildBodyForDesktop(context),
      ),
    );
  }

  Widget _buildBodyForDesktop(BuildContext context) {
    return Row(children: [
      if (leadingIcon != null) leadingIcon!,
      Expanded(
        child: Tooltip(
          message: vacationResponse.getNotificationMessage(context),
          child: Text(
            vacationResponse.getNotificationMessage(context),
            style: ThemeUtils.defaultTextStyleInterFont.copyWith(
              color: Colors.black,
              fontSize: 16,
              fontWeight: fontWeight ?? FontWeight.normal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        )
      ),
      if (actionEndNow != null)
        TMailButtonWidget.fromText(
          text: AppLocalizations.of(context).endNow,
          textStyle: ThemeUtils.defaultTextStyleInterFont.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: AppColor.colorTextButton),
          backgroundColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          borderRadius: 10,
          maxWidth: 180,
          maxLines: 1,
          tooltipMessage: AppLocalizations.of(context).endNow,
          onTapActionCallback: actionEndNow),
      if (actionGotoVacationSetting != null)
        TMailButtonWidget.fromText(
          text: AppLocalizations.of(context).vacationSetting,
          textStyle: ThemeUtils.defaultTextStyleInterFont.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: AppColor.colorTextButton),
          backgroundColor: Colors.transparent,
          borderRadius: 10,
          maxWidth: 310,
          maxLines: 1,
          tooltipMessage: AppLocalizations.of(context).vacationSetting,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          onTapActionCallback: actionGotoVacationSetting)
    ]);
  }

  Widget _buildBodyForMobile(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leadingIcon != null) leadingIcon!,
        Tooltip(
          message: vacationResponse.getNotificationMessage(context),
          child: Text(
            vacationResponse.getNotificationMessage(context),
            style: ThemeUtils.defaultTextStyleInterFont.copyWith(
              color: Colors.black,
              fontSize: 16,
              fontWeight: fontWeight ?? FontWeight.normal,
            ),
            maxLines: 1,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (actionEndNow != null)
              Flexible(
                child: TMailButtonWidget.fromText(
                  text: AppLocalizations.of(context).endNow,
                  textStyle: ThemeUtils.defaultTextStyleInterFont.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: AppColor.colorTextButton),
                  backgroundColor: Colors.transparent,
                  borderRadius: 10,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  maxWidth: 180,
                  maxLines: 1,
                  tooltipMessage: AppLocalizations.of(context).endNow,
                  onTapActionCallback: actionEndNow
                ),
              ),
            if (actionGotoVacationSetting != null)
              Flexible(
                child: TMailButtonWidget.fromText(
                  text: AppLocalizations.of(context).vacationSetting,
                  textStyle: ThemeUtils.defaultTextStyleInterFont.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: AppColor.colorTextButton),
                  backgroundColor: Colors.transparent,
                  borderRadius: 10,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  maxWidth: 180,
                  maxLines: 1,
                  tooltipMessage: AppLocalizations.of(context).vacationSetting,
                  onTapActionCallback: actionGotoVacationSetting
                ),
              ),
          ]
        )
      ]
    );
  }
}