import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/isolate/background_isolate_binary_messenger/background_isolate_binary_messenger_mobile.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnChangedHasAttachment = void Function(bool? value);

class CheckBoxHasAttachmentWidget extends StatelessWidget {
  final bool hasAttachmentValue;
  final FocusNode? currentFocusNode;
  final FocusNode? nextFocusNode;
  final OnChangedHasAttachment? onChanged;

  const CheckBoxHasAttachmentWidget({
    super.key,
    required this.hasAttachmentValue,
    this.currentFocusNode,
    this.nextFocusNode,
    this.onChanged,
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
      child: CheckboxListTile(
        value: hasAttachmentValue,
        contentPadding: const EdgeInsetsDirectional.only(start: 4),
        activeColor: AppColor.primaryColor,
        focusNode: currentFocusNode,
        controlAffinity: ListTileControlAffinity.leading,
        onChanged: onChanged,
        title: Text(
          AppLocalizations.of(context).hasAttachment,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: Colors.black
          ),
        ),
      )
    );
  }
}