
import 'dart:async';

import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

typedef OnConfirmModelSheetsActionClick = void Function(String);
typedef SetErrorStringModelSheets = String? Function(String);

class EditTextModalSheetBuilder {
  @protected
  late TextEditingController _textController;

  @protected
  late Key _key;

  @protected
  String _title = '';

  @protected
  String _cancelText = '';

  @protected
  String _confirmText = '';

  @protected
  String _hintText = '';

  @protected
  OnConfirmModelSheetsActionClick? _onConfirmActionClick;

  @protected
  SetErrorStringModelSheets? _setErrorString;

  @protected
  String? _error;

  @protected
  Timer? _debounce;

  @protected
  BoxConstraints? _constraints;

  EditTextModalSheetBuilder();

  void key(Key key) {
    _key = key;
  }

  void title(String title) {
    _title = title;
  }

  void cancelText(String cancelText) {
    _cancelText = cancelText;
  }

  void hintText(String hintText) {
    _hintText = hintText;
  }

  void boxConstraints(BoxConstraints? constraints) {
    _constraints = constraints;
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

  void onConfirmAction(String confirmText, OnConfirmModelSheetsActionClick onConfirmActionClick) {
    _onConfirmActionClick = onConfirmActionClick;
    _confirmText = confirmText;
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
      _onConfirmActionClick?.call(_textController.text);
    }
  }

  void _onCancelButtonPress(BuildContext context) {
    Get.back();
    _debounce?.cancel();
  }

  void show(context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      constraints: _constraints,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0))),
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
          return Padding(
              key: _key,
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                  padding: const EdgeInsets.only(left: 50, right: 50, top: 48, bottom: 20),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => _onCancelButtonPress(context),
                            child: Text(_cancelText.toUpperCase(), style: const TextStyle(color: AppColor.colorTextButton)),
                          ),
                          TextButton(
                            onPressed: () => _onConfirmButtonPress(context),
                            child: Text(_confirmText.toUpperCase(),
                                style: TextStyle(
                                    color: (_error == null || (_error != null && _error!.isEmpty))
                                        ? AppColor.colorTextButton
                                        : AppColor.colorDisableMailboxCreateButton)),
                          )
                        ],
                      )
                    ],
                  )
              )
          );
        });
      },
    );
  }
}