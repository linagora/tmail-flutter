
import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

typedef OnConfirmButtonEditDialogAction = void Function(String);
typedef SetErrorStringEditDialog = String? Function(String);

class EditTextDialogBuilder {
  late TextEditingController _textController;

  Key? _key;
  String _title = '';
  String _hintText = '';
  String _confirmText = '';
  String _cancelText = '';

  OnConfirmButtonEditDialogAction? _onConfirmButtonAction;

  SetErrorStringEditDialog? _setErrorString;
  String? _error;
  Timer? _debounce;

  EditTextDialogBuilder();

  void key(Key key) {
    _key = key;
  }

  void title(String title) {
    _title = title;
  }

  void hintText(String hintText) {
    _hintText = hintText;
  }

  void cancelText(String cancelText) {
    _cancelText = cancelText;
  }

  void onConfirmButtonAction(String confirmText, OnConfirmButtonEditDialogAction? onConfirmButtonAction) {
    _confirmText = confirmText;
    _onConfirmButtonAction = onConfirmButtonAction;
  }

  void setTextController(TextEditingController textEditingController) {
    _textController = textEditingController;
  }

  void setTextSelection(TextSelection textSelection, {required String value}) {
    _textController = TextEditingController.fromValue(TextEditingValue(text: value, selection: textSelection));
  }

  void setErrorString(SetErrorStringModelSheets setErrorString) {
    _setErrorString = setErrorString;
  }

  void _onTextChanged(String name, StateSetter setState) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _error = (_setErrorString != null) ? _setErrorString!(name) : '';
      });
    });
  }

  void _onConfirmButtonPress(BuildContext context) {
    if (_error == null || (_error != null && _error!.isEmpty)) {
      Get.back();
      _onConfirmButtonAction?.call(_textController.text);
    }
  }

  void _onCancelButtonPress(BuildContext context) {
    Get.back();
    _debounce?.cancel();
  }

  Widget build() {
    return Dialog(
      key: _key,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
      insetPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Container(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        width: 400,
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
          return Container(
              padding: const EdgeInsets.only(left: 30, right: 30, top: 30, bottom: 24),
              child: Wrap(
                children: <Widget>[
                  Text(
                      _title,
                      style: const TextStyle(fontSize: 20, color: AppColor.colorNameEmail, fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center),
                  Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: TextFormField(
                        keyboardType: TextInputType.visiblePassword,
                        onChanged: (value) => _onTextChanged(value, setState),
                        autofocus: true,
                        controller: _textController,
                        decoration: InputDecoration(
                            errorText: _error,
                            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColor.colorDividerMailbox)),
                            hintText: _hintText),
                      )
                  ),
                  Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16, top: 24),
                      child: Row(
                          children: [
                            Expanded(
                                child: _buildButton(
                                    name: _cancelText,
                                    bgColor: AppColor.colorContentEmail,
                                    action: () => _onCancelButtonPress(context))
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                                child: _buildButton(
                                    name: _confirmText,
                                    bgColor: (_error == null || (_error != null && _error!.isEmpty))
                                        ? AppColor.colorTextButton
                                        : AppColor.colorDisableMailboxCreateButton,
                                    nameColor: (_error == null || (_error != null && _error!.isEmpty))
                                        ? Colors.white
                                        : AppColor.colorDisableMailboxCreateButton,
                                    action: () => _onConfirmButtonPress(context))
                            )
                          ]
                      )
                  )
                ],
              )
          );
        })
      ),
    );
  }

  Widget _buildButton({
    String? name, Color? nameColor, Color? bgColor, Function? action
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () => action?.call(),
        style: ButtonStyle(
            foregroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) => bgColor ?? AppColor.colorTextButton),
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) => bgColor ?? AppColor.colorTextButton),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(width: 0, color: bgColor ?? AppColor.colorTextButton),
            )),
            padding: MaterialStateProperty.resolveWith<EdgeInsets>(
                    (Set<MaterialState> states) => const EdgeInsets.symmetric(horizontal: 16)),
            elevation: MaterialStateProperty.resolveWith<double>((Set<MaterialState> states) => 0)),
        child: Text(name ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: nameColor ?? Colors.white)),
      )
    );
  }
}
