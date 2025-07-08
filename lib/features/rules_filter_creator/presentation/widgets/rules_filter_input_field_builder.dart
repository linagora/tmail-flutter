
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/text/text_field_builder.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/rules_filter_creator/presentation/widgets/rules_filter_input_decoration_builder.dart';

typedef OnChangeFilterInputAction = Function(String? value);

class RulesFilterInputField extends StatelessWidget {

  final String? errorText;
  final String? hintText;
  final TextEditingController? editingController;
  final FocusNode? focusNode;
  final OnChangeFilterInputAction? onChangeAction;

  const RulesFilterInputField({
    Key? key,
    this.hintText,
    this.errorText,
    this.editingController,
    this.focusNode,
    this.onChangeAction
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFieldBuilder(
      onTextChange: onChangeAction,
      textInputAction: TextInputAction.next,
      controller: editingController,
      textStyle: ThemeUtils.defaultTextStyleInterFont.copyWith(
        color: Colors.black,
        fontSize: 16,
      ),
      textDirection: DirectionUtils.getDirectionByLanguage(context),
      keyboardType: TextInputType.text,
      focusNode: focusNode,
      maxLines: 1,
      decoration: (RulesFilterInputDecorationBuilder()
        ..setContentPadding(EdgeInsets.symmetric(vertical: PlatformInfo.isWeb ? 14 : 12, horizontal: 12))
        ..setHintText(hintText)
        ..setErrorText(errorText))
      .build(),
    );
  }
}