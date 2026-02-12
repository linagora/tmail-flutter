import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Shows a platform specific time picker with the given [initialTime].
///
/// On iOS and macOS a CupertinoDatePicker is used. The [builder], [initialEntryMode], [helpText], [useRootNavigator] and [rootSettings] parameters are ignored there.
/// On other platforms the Material [showTimePicker] method is called with the given parameters.
Future<TimeOfDay?> showPlatformTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
  Widget Function(BuildContext, Widget?)? builder,
  bool useRootNavigator = true,
  TimePickerEntryMode initialEntryMode = TimePickerEntryMode.dial,
  String? cancelText,
  String? confirmText,
  String? helpText,
  RouteSettings? routeSettings,
}) async {
  if (PlatformInfo.isCupertino) {
    final initialDateTime =
        DateTime(1, 1, 1, initialTime.hour, initialTime.minute);
    DateTime? pickedTime;
    final result = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (context) => SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.4,
        child: Container(
          color: CupertinoTheme.of(context).barBackgroundColor,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                      child: (cancelText != null)
                          ? Text(cancelText)
                          : Icon(CupertinoIcons.clear_circled),
                      onPressed: () => Navigator.of(context).pop(false)),
                  CupertinoButton(
                      child: (confirmText != null)
                          ? Text(confirmText)
                          : Icon(CupertinoIcons.check_mark_circled),
                      onPressed: () => Navigator.of(context).pop(true)),
                ],
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  onDateTimeChanged: (value) => pickedTime = value,
                  use24hFormat: MediaQuery.of(context).alwaysUse24HourFormat,
                  initialDateTime: initialDateTime,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (result == true && pickedTime != null) {
      return TimeOfDay.fromDateTime(pickedTime!);
    }
    return null;
  } else {
    return showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: builder,
      useRootNavigator: useRootNavigator,
      initialEntryMode: initialEntryMode,
      cancelText: cancelText,
      confirmText: confirmText,
      helpText: helpText,
      routeSettings: routeSettings,
    );
  }
}

/// Shows a platform specific date picker with the given [initialDateTime] with a possible range starting with [firstDate] and ending with [lastDate].
///
/// On iOS and macOS a CupertinoDatePicker is used. The [builder], [initialEntryMode], [helpText], [useRootNavigator] and [rootSettings] parameters are ignored there.
/// On other platforms the Material [showTimePicker] method is called with the given parameters.
Future<DateTime?> showPlatformSpecificDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  DateTime? currentDate,
  DatePickerEntryMode initialEntryMode = DatePickerEntryMode.calendar,
  SelectableDayPredicate? selectableDayPredicate,
  String? helpText,
  String? cancelText,
  String? confirmText,
  Locale? locale,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  TextDirection? textDirection,
  TransitionBuilder? builder,
  DatePickerMode initialDatePickerMode = DatePickerMode.day,
  String? errorFormatText,
  String? errorInvalidText,
  String? fieldHintText,
  String? fieldLabelText,
}) async {
  if (PlatformInfo.isCupertino) {
    DateTime? pickedTime;
    final result = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (context) => SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.4,
        child: Container(
          color: CupertinoTheme.of(context).barBackgroundColor,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                      child: (cancelText != null)
                          ? Text(cancelText)
                          : Icon(CupertinoIcons.clear_circled),
                      onPressed: () => Navigator.of(context).pop(false)),
                  CupertinoButton(
                      child: (confirmText != null)
                          ? Text(confirmText)
                          : Icon(CupertinoIcons.check_mark_circled),
                      onPressed: () => Navigator.of(context).pop(true)),
                ],
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  onDateTimeChanged: (value) => pickedTime = value,
                  use24hFormat: MediaQuery.of(context).alwaysUse24HourFormat,
                  initialDateTime: initialDate,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (result == true && pickedTime != null) {
      return pickedTime;
    }
    return null;
  } else {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      currentDate: currentDate,
      initialEntryMode: initialEntryMode,
      selectableDayPredicate: selectableDayPredicate,
      helpText: helpText,
      cancelText: cancelText,
      confirmText: confirmText,
      locale: locale,
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
      textDirection: textDirection,
      builder: builder,
      initialDatePickerMode: initialDatePickerMode,
      errorFormatText: errorFormatText,
      errorInvalidText: errorInvalidText,
      fieldHintText: fieldHintText,
      fieldLabelText: fieldLabelText,
    );
  }
}
