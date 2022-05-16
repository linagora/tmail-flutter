
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/widgets/identity_input_decoration_builder.dart';

typedef OnChangeInputNameAction = Function(String? value);

class IdentityInputFieldBuilder {

  final String _label;
  final String? _error;
  final TextEditingController? editingController;
  final FocusNode? focusNode;
  final TextInputType? inputType;
  final bool isMandatory;

  OnChangeInputNameAction? onChangeInputNameAction;

  IdentityInputFieldBuilder(
    this._label,
    this._error, {
    this.isMandatory = false,
    this.editingController,
    this.focusNode,
    this.inputType
  });

  void addOnChangeInputNameAction(OnChangeInputNameAction action) {
    onChangeInputNameAction = action;
  }

  Widget build() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(isMandatory ? '$_label*' : _label, style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColor.colorContentEmail)),
      const SizedBox(height: 8),
      (TextFieldBuilder()
          ..onChange((value) => onChangeInputNameAction?.call(value))
          ..textInputAction(TextInputAction.next)
          ..addController(editingController ?? TextEditingController())
          ..addFocusNode(focusNode)
          ..textStyle(const TextStyle(color: Colors.black, fontSize: 16))
          ..keyboardType(inputType ?? TextInputType.text)
          ..textDecoration((IdentityInputDecorationBuilder()
                ..setContentPadding(const EdgeInsets.symmetric(
                    vertical: BuildUtils.isWeb ? 16 : 12,
                    horizontal: 12))
                ..setErrorText(_error))
              .build()))
        .build()
    ]);
  }
}