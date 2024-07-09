import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/text/text_field_builder.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/isolate/background_isolate_binary_messenger/background_isolate_binary_messenger_mobile.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/model/email_recovery_field.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/styles/text_input_field/text_input_field_widget_styles.dart';

typedef OnTextSubmitted = void Function(String text)?;

class TextInputFieldWidget extends StatelessWidget {
  final EmailRecoveryField field;
  final ResponsiveUtils responsiveUtils;
  final ImagePaths imagePaths;
  final TextEditingController textEditingController;
  final VoidCallback? onTap;
  final MouseCursor? mouseCursor;
  final FocusNode? currentFocusNode;
  final FocusNode? nextFocusNode;
  final OnTextSubmitted? onTextSubmitted;

  const TextInputFieldWidget({
    super.key,
    required this.field,
    required this.responsiveUtils,
    required this.imagePaths,
    required this.textEditingController,
    this.onTap,
    this.mouseCursor,
    this.currentFocusNode,
    this.nextFocusNode,
    this.onTextSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final title = SizedBox(
      width: responsiveUtils.isMobile(context) 
        ? null 
        : TextInputFieldWidgetStyles.titleWidth,
      child: Text(
        field.getTitle(context),
        style: field.getTitleTextStyle(),
      ),
    );
    final inputField = TextFieldBuilder(
      controller: textEditingController,
      readOnly: false,
      mouseCursor: mouseCursor,
      maxLines: 1,
      textInputAction: TextInputAction.next,
      textStyle: TextInputFieldWidgetStyles.inputtedTextStyle,
      onTap: onTap,
      onTextSubmitted: onTextSubmitted,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: TextInputFieldWidgetStyles.contentPadding,
        enabledBorder: TextInputFieldWidgetStyles.enableBorder,
        border: TextInputFieldWidgetStyles.border,
        focusedBorder: TextInputFieldWidgetStyles.focusedBorder,
        hintText: field.getHintText(context),
        hintStyle: field.getHintTextStyle(),
      ),
    );

    return KeyboardListener(
      focusNode: currentFocusNode ?? FocusNode(),
      onKeyEvent: (event) {
        if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.tab) {
          nextFocusNode?.requestFocus();
        }
      },
      child: Padding(
        padding: TextInputFieldWidgetStyles.padding,
        child: responsiveUtils.isMobile(context)
          ? Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              title,
              const SizedBox(height: TextInputFieldWidgetStyles.spaceMobile),
              inputField,
            ]
          )
          : SizedBox(
            height: 44,
            child: Row(
              children: [
                title,
                const SizedBox(width: TextInputFieldWidgetStyles.space),
                Expanded(
                  child: inputField,
                )
              ],
            ),
          ),
      )
    );
  }
}