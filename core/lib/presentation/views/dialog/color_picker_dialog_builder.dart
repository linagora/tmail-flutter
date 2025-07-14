
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

typedef SelectColorActionCallback = Function(Color? colorSelected);

class ColorPickerDialogBuilder {
  final SelectColorActionCallback? setColorActionCallback;
  final VoidCallback? cancelActionCallback;
  final VoidCallback? resetToDefaultActionCallback;
  final Color defaultColor;
  final ValueNotifier<Color> _currentColor;
  final String? title;
  final String? textActionSetColor;
  final String? textActionCancel;
  final String? textActionResetDefault;
  final Function(Color)? onSelected;

  bool _shouldUpdate = false;
  Color _colorCode = Colors.black;

  ColorPickerDialogBuilder(
    this._currentColor,
    {
      this.onSelected,
      this.title,
      this.textActionSetColor,
      this.textActionCancel,
      this.textActionResetDefault,
      this.defaultColor = Colors.black,
      this.setColorActionCallback,
      this.cancelActionCallback,
      this.resetToDefaultActionCallback
    }
  );

  Future<dynamic> show() async {
    return Get.dialog(
      PointerInterceptor(
        child: AlertDialog(
          title: Text(
            title ?? '',
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
          actionsOverflowButtonSpacing: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          scrollable: true,
          elevation: 10,
          content: ValueListenableBuilder(
            valueListenable: _currentColor,
            builder: (context, _, __) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 500,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                      color: Colors.white
                    ),
                    child: Center(
                      child: Wrap(children: AppColor.listColorsPicker
                        .map((color) => _itemColorWidget(context, color))
                        .toList(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: ColorCodeField(
                      color: _currentColor.value,
                      colorCodeHasColor: true,
                      shouldUpdate: _shouldUpdate,
                      onColorChanged: (Color color) {
                        if (AppColor.listColorsPicker.any((element) => element.toInt32 == color.toInt32)) {
                          _shouldUpdate = true;
                          _currentColor.value = color;
                        } else {
                          _shouldUpdate = false;
                          _currentColor.value = Colors.black;
                          _colorCode = color;
                        }
                      },
                      onEditFocused: (bool editInFocus) {
                        _shouldUpdate = editInFocus ? true : false;
                      },
                      copyPasteBehavior: const ColorPickerCopyPasteBehavior(
                        parseShortHexCode: true,
                      ),
                      toolIcons: const ColorPickerActionButtons(
                        dialogActionButtons: true,
                      ),
                    ),
                  ),
                ],
              );
            },
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
                onTap: () {
                  if (!_shouldUpdate) {
                    setColorActionCallback?.call(_colorCode);
                  } else {
                    setColorActionCallback?.call(_currentColor.value);
                  }
                })
          ],
        ),
      )
    );
  }

  Widget _itemColorWidget(BuildContext context, Color color) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _shouldUpdate = true;
          _currentColor.value = color;
        },
        child: Container(
          decoration: BoxDecoration(
            color: color,
            border: Border.all(
              color: _currentColor.value == color ? Colors.white : Colors.transparent,
              width: 8,
            ),
          ),
          width: 40,
          height: 40,
        ),
      ),
    );
  }
}