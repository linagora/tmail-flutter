import 'package:core/presentation/views/text/text_field_builder.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/composer/presentation/styles/subject_composer_widget_style.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class SubjectComposerWidget extends StatelessWidget {

  final FocusNode? focusNode;
  final TextEditingController textController;
  final ValueChanged<String>? onTextChange;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const SubjectComposerWidget({
    super.key,
    required this.focusNode,
    required this.textController,
    required this.onTextChange,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: SubjectComposerWidgetStyle.borderColor,
            width: 1
          )
        ),
      ),
      margin: margin,
      padding: padding,
      child: Row(
        children: [
          Text(
            '${AppLocalizations.of(context).subject_email}:',
            style: SubjectComposerWidgetStyle.labelTextStyle
          ),
          const SizedBox(width:SubjectComposerWidgetStyle.space),
          Expanded(
            child: TextFieldBuilder(
              cursorColor: SubjectComposerWidgetStyle.cursorColor,
              focusNode: focusNode,
              onTextChange: onTextChange,
              maxLines: 1,
              decoration: const InputDecoration(border: InputBorder.none),
              textDirection: DirectionUtils.getDirectionByLanguage(context),
              textStyle: SubjectComposerWidgetStyle.inputTextStyle,
              controller: textController,
            )
          )
        ]
      ),
    );
  }
}