import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class DateTimeDialogPicker {
  static final _instance = DateTimeDialogPicker._();

  factory DateTimeDialogPicker() => _instance;

  DateTimeDialogPicker._();

  final _isOpened = RxBool(false);

  RxBool get isOpened => _isOpened;

  Future<TimeOfDay?> showTwakeTimePicker({
    required BuildContext context,
    required TimeOfDay initialTime,
    bool use24HourFormat = false,
    String? cancelText,
    String? confirmText,
  }) {
    _isOpened.value = true;

    return showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColor.primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColor.primaryColor,
              ),
            ),
          ),
          child: MediaQuery(
            data: MediaQueryData(alwaysUse24HourFormat: use24HourFormat),
            child: PlatformInfo.isWeb
                ? KeyboardListener(
                    focusNode: FocusNode(),
                    autofocus: true,
                    onKeyEvent: (event) {
                      if (event.logicalKey == LogicalKeyboardKey.escape) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: child!,
                  )
                : child!,
          ),
        );
      },
      cancelText: cancelText,
      confirmText: confirmText,
    ).whenComplete(() => _isOpened.value = false);
  }

  Future<DateTime?> showTwakeDatePicker({
    required BuildContext context,
    required DateTime initialDate,
    String? cancelText,
    String? confirmText,
  }) {
    _isOpened.value = true;

    return showDatePicker(
      context: context,
      initialDate: initialDate,
      initialDatePickerMode: DatePickerMode.day,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      locale: Localizations.localeOf(context),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColor.primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColor.primaryColor,
              ),
            ),
          ),
          child: PlatformInfo.isWeb
              ? KeyboardListener(
                  focusNode: FocusNode(),
                  autofocus: true,
                  onKeyEvent: (event) {
                    if (event.logicalKey == LogicalKeyboardKey.escape) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: child!,
                )
              : child!,
        );
      },
      cancelText: cancelText,
      confirmText: confirmText,
    ).whenComplete(() => _isOpened.value = false);
  }
}
