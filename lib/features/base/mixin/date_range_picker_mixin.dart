
import 'package:core/presentation/utils/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/multiple_view_date_range_picker.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

mixin DateRangePickerMixin {

  void showMultipleViewDateRangePicker(
    BuildContext context,
    DateTime? initStartDate,
    DateTime? initEndDate,
    {Function(DateTime? startDate, DateTime? endDate)? onCallbackAction}
  ) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54,
      pageBuilder: (context, _, __) {
        return Dialog(
          elevation: 0,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
          child: PointerInterceptor(child: MultipleViewDateRangePicker(
              confirmText: AppLocalizations.of(context).setDate,
              cancelText: AppLocalizations.of(context).cancel,
              last7daysTitle: AppLocalizations.of(context).last7Days,
              last30daysTitle: AppLocalizations.of(context).last30Days,
              last6monthsTitle: AppLocalizations.of(context).last6Months,
              lastYearTitle: AppLocalizations.of(context).lastYears,
              startDate: initStartDate,
              endDate: initEndDate,
              setDateActionCallback: ({startDate, endDate}) =>
                _handleSelectDateRangeResult(
                  context,
                  startDate,
                  endDate,
                  onCallbackAction: onCallbackAction
                )
          ))
        );
      }
    );
  }

  void _handleSelectDateRangeResult(
    BuildContext context,
    DateTime? startDate,
    DateTime? endDate,
    {Function(DateTime? startDate, DateTime? endDate)? onCallbackAction}
  ) {
    final appToast = Get.find<AppToast>();

    if (startDate == null) {
      appToast.showToastErrorMessage(
        context,
        AppLocalizations.of(context).toastMessageErrorWhenSelectStartDateIsEmpty);
      return;
    }

    if (endDate == null) {
      appToast.showToastErrorMessage(
        context,
        AppLocalizations.of(context).toastMessageErrorWhenSelectEndDateIsEmpty);
      return;
    }

    if (endDate.isBefore(startDate)) {
      appToast.showToastErrorMessage(
        context,
        AppLocalizations.of(context).toastMessageErrorWhenSelectDateIsInValid);
      return;
    }

    popBack();
    onCallbackAction?.call(startDate, endDate);
  }
}