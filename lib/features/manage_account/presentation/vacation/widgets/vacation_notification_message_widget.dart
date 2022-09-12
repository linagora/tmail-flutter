
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
  final EdgeInsets? margin;
  final EdgeInsets? padding;
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
      padding: padding ?? const EdgeInsets.only(left: 12),
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
          child: Text(
              vacationResponse.getNotificationMessage(context),
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: fontWeight ?? FontWeight.normal,
              ))),
      if (actionEndNow != null)
        buildTextButton(
            AppLocalizations.of(context).endNow,
            textStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: AppColor.colorTextButton),
            backgroundColor: Colors.transparent,
            width: 90,
            height: 44,
            radius: 10,
            onTap: () => actionEndNow!.call()),
      if (actionGotoVacationSetting != null)
        buildTextButton(
            AppLocalizations.of(context).vacationSetting,
            textStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: AppColor.colorTextButton),
            backgroundColor: Colors.transparent,
            width: 150,
            height: 44,
            radius: 10,
            onTap: () => actionGotoVacationSetting!.call())
    ]);
  }

  Widget _buildBodyForMobile(BuildContext context) {
    return Column(children: [
      Row(children: [
        if (leadingIcon != null) leadingIcon!,
        Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8, right: 12),
              child: Center(
                child: Text(
                    vacationResponse.getNotificationMessage(context),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: fontWeight ?? FontWeight.normal,
                    )),
              ),
            )),
      ]),
      Row(children: [
        const Spacer(),
        if (actionEndNow != null)
          buildTextButton(
              AppLocalizations.of(context).endNow,
              textStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: AppColor.colorTextButton),
              backgroundColor: Colors.transparent,
              width: 90,
              height: 36,
              radius: 10,
              onTap: () => actionEndNow!.call()),
        if (actionGotoVacationSetting != null)
          buildTextButton(
              AppLocalizations.of(context).vacationSetting,
              textStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: AppColor.colorTextButton),
              backgroundColor: Colors.transparent,
              width: 150,
              height: 36,
              radius: 10,
              onTap: () => actionGotoVacationSetting!.call()),
        const Spacer(),
      ])
    ]);
  }
}