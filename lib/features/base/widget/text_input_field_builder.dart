
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/widget/text_input_decoration_builder.dart';

typedef OnChangeInputAction = Function(String? value);

class TextInputFieldBuilder extends StatelessWidget {

  final String? label;
  final String? error;
  final String? hint;
  final TextEditingController? editingController;
  final FocusNode? focusNode;
  final TextInputType? inputType;
  final bool isMandatory;
  final int? minLines;
  final int? maxLines;
  final Color? backgroundColor;
  final OnChangeInputAction? onChangeInputAction;

  const TextInputFieldBuilder({
    Key? key,
    this.label,
    this.hint,
    this.error,
    this.isMandatory = false,
    this.editingController,
    this.focusNode,
    this.inputType,
    this.minLines,
    this.maxLines,
    this.backgroundColor,
    this.onChangeInputAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (label != null)
        ...[
          Text(isMandatory ? '${label!}*' : label!,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: AppColor.colorContentEmail)),
          const SizedBox(height: 8)
        ],
      (TextFieldBuilder()
          ..onChange((value) => onChangeInputAction?.call(value))
          ..textInputAction(TextInputAction.next)
          ..addController(editingController ?? TextEditingController())
          ..addFocusNode(focusNode)
          ..textStyle(const TextStyle(color: Colors.black, fontSize: 16))
          ..keyboardType(inputType ?? TextInputType.text)
          ..minLines(minLines)
          ..maxLines(maxLines)
          ..textDecoration((TextInputDecorationBuilder()
                ..setContentPadding(const EdgeInsets.symmetric(
                    vertical: BuildUtils.isWeb ? 16 : 12,
                    horizontal: 12))
                ..setHintText(hint)
                ..setFillColor(backgroundColor)
                ..setErrorText(error))
              .build()))
        .build()
    ]);
  }
}