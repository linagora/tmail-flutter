
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/views/text/text_field_builder.dart';
import 'package:core/utils/build_utils.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/identity_creator/presentation/widgets/identity_input_decoration_builder.dart';

typedef OnChangeInputNameAction = Function(String? value);

class IdentityInputFieldBuilder extends StatelessWidget {

  final String _label;
  final String? _error;
  final String? requiredIndicator;
  final TextEditingController? editingController;
  final FocusNode? focusNode;
  final TextInputType? inputType;
  final bool isMandatory;
  final OnChangeInputNameAction? onChangeInputNameAction;

  const IdentityInputFieldBuilder(
    this._label,
    this._error,
    this.requiredIndicator, {
    super.key,
    this.isMandatory = false,
    this.editingController,
    this.focusNode,
    this.inputType,
    this.onChangeInputNameAction
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        isMandatory 
          ? '$_label ($requiredIndicator)' 
          : _label, style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColor.colorContentEmail)),
      const SizedBox(height: 8),
      (TextFieldBuilder()
          ..onChange((value) => onChangeInputNameAction?.call(value))
          ..textInputAction(TextInputAction.next)
          ..addController(editingController ?? TextEditingController())
          ..autoFocus(true)
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