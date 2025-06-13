import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/views/checkbox/default_labeled_checkbox.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/isolate/background_isolate_binary_messenger/background_isolate_binary_messenger_mobile.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnChangedHasAttachment = void Function(bool? value);

class CheckBoxHasAttachmentWidget extends StatelessWidget {
  final bool hasAttachmentValue;
  final FocusNode currentFocusNode;
  final FocusNode? nextFocusNode;
  final OnChangedHasAttachment onChanged;

  const CheckBoxHasAttachmentWidget({
    super.key,
    required this.hasAttachmentValue,
    required this.currentFocusNode,
    required this.onChanged,
    this.nextFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (event) {
        if (event.logicalKey == LogicalKeyboardKey.tab) {
          nextFocusNode?.requestFocus();
        }
      },
      child: DefaultLabeledCheckbox(
        label: AppLocalizations.of(context).hasAttachment,
        focusNode: currentFocusNode,
        value: hasAttachmentValue,
        activeColor: AppColor.primaryColor,
        onChanged: onChanged, 
      )
    );
  }
}