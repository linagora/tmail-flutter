
import 'package:core/presentation/views/text/text_field_builder.dart';
import 'package:core/utils/build_utils.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rules_filter_input_decoration_builder.dart';

typedef OnChangeFilterInputAction = Function(String? value);

class RulesFilterInputField extends StatelessWidget {

  final String? errorText;
  final String? hintText;
  final TextEditingController? editingController;
  final bool isMandatory;
  final OnChangeFilterInputAction? onChangeAction;

  const RulesFilterInputField({
    Key? key,
    this.hintText,
    this.errorText,
    this.isMandatory = false,
    this.editingController,
    this.onChangeAction
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return (TextFieldBuilder()
        ..onChange((value) => onChangeAction?.call(value))
        ..textInputAction(TextInputAction.next)
        ..addController(editingController ?? TextEditingController())
        ..textStyle(const TextStyle(color: Colors.black, fontSize: 16))
        ..keyboardType(TextInputType.text)
        ..textDecoration((RulesFilterInputDecorationBuilder()
              ..setContentPadding(const EdgeInsets.symmetric(
                  vertical: BuildUtils.isWeb ? 16 : 12,
                  horizontal: 12))
              ..setHintText(hintText)
              ..setErrorText(errorText))
            .build()))
      .build();
  }
}