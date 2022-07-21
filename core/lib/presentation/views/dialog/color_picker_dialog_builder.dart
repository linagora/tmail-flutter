
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

typedef SelectColorActionCallback = Function(Color? colorSelected);

class ColorPickerDialogBuilder {

  final SelectColorActionCallback? setColorActionCallback;
  final VoidCallback? cancelActionCallback;
  final VoidCallback? resetToDefaultActionCallback;
  final BuildContext _context;
  final Color defaultColor;
  final Color _currentColor;
  final String? title;
  final String? textActionSetColor;
  final String? textActionCancel;
  final String? textActionResetDefault;

  Color? _colorSelected;

  ColorPickerDialogBuilder(
    this._context,
    this._currentColor,
    {
      this.title,
      this.textActionSetColor,
      this.textActionCancel,
      this.textActionResetDefault,
      this.defaultColor = Colors.black,
      this.setColorActionCallback,
      this.cancelActionCallback,
      this.resetToDefaultActionCallback
    }
  ) : _colorSelected = _currentColor;

  Future show() async {
    await showDialog(context: _context, builder: (BuildContext context) {
      return PointerInterceptor(
        child: AlertDialog(
          title: Text(title ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black)),
          titleTextStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black),
          titlePadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          actionsPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          actionsAlignment: MainAxisAlignment.center,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          scrollable: true,
          elevation: 10,
          content: ColorPicker(
            color: _currentColor,
            onColorChanged: (color) => _colorSelected = color,
            width: 40,
            height: 40,
            spacing: 0,
            runSpacing: 0,
            borderRadius: 0,
            wheelDiameter: 165,
            enableOpacity: false,
            showColorCode: true,
            colorCodeHasColor: true,
            pickersEnabled: const <ColorPickerType, bool>{
              ColorPickerType.wheel: true,
            },
            copyPasteBehavior: const ColorPickerCopyPasteBehavior(
              parseShortHexCode: true,
            ),
            actionButtons: const ColorPickerActionButtons(
              dialogActionButtons: true,
            ),
          ),
          actions: <Widget>[
            buildButtonWrapText(
                textActionCancel ?? '',
                radius: 5,
                height: 30,
                textStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.normal),
                bgColor: AppColor.colorShadowComposer,
                onTap: () => cancelActionCallback?.call()),
            buildButtonWrapText(
                textActionResetDefault ?? '',
                radius: 5,
                height: 30,
                textStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.normal),
                bgColor: Colors.white,
                borderColor: Colors.black26,
                onTap: () => resetToDefaultActionCallback?.call()),
            buildButtonWrapText(
                textActionSetColor ?? '',
                radius: 5,
                height: 30,
                textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
                onTap: () => setColorActionCallback?.call(_colorSelected))
          ],
        ),
      );
    });
  }
}