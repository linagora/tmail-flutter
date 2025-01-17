import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/views/checkbox/labeled_checkbox.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/isolate/background_isolate_binary_messenger/background_isolate_binary_messenger_mobile.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnAcceptSelfSignedChange = void Function(bool? value);

class AcceptSelfSignedCheckBoxWidget extends StatelessWidget {
  final bool acceptSelfSignedValue;
  final FocusNode? currentFocusNode;
  final FocusNode? nextFocusNode;
  final OnAcceptSelfSignedChange? onChanged;

  const AcceptSelfSignedCheckBoxWidget({
    super.key,
    required this.acceptSelfSignedValue,
    this.currentFocusNode,
    this.nextFocusNode,
    required this.onChanged,
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
        child: LabeledCheckbox(
          label: AppLocalizations.of(context).acceptSelfSignedCertificates,
          //focusNode: currentFocusNode,
          //contentPadding: EdgeInsets.zero,
          value: acceptSelfSignedValue,
          activeColor: AppColor.primaryColor,
          onChanged: onChanged,
        )
    );
  }
}