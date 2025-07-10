import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/views/dialog/confirm_dialog_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class ListButtonWidget extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onRestore;
  final bool isMobile;
  final FocusNode? nextFocusNode;
  final EdgeInsetsGeometry? padding;

  const ListButtonWidget({
    super.key,
    required this.onCancel,
    required this.onRestore,
    this.isMobile = false,
    this.nextFocusNode,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Widget cancelButton = Container(
      constraints: !isMobile ? const BoxConstraints(minWidth: 67) : null,
      height: 48,
      child: ConfirmDialogButton(
        label: AppLocalizations.of(context).cancel,
        onTapAction: onCancel,
      ),
    );

    Widget restoreButton = Container(
      constraints: !isMobile ? const BoxConstraints(minWidth: 117) : null,
      height: 48,
      child: ConfirmDialogButton(
        label: AppLocalizations.of(context).restore,
        backgroundColor: AppColor.primaryMain,
        textColor: Colors.white,
        onTapAction: onRestore,
      ),
    );

    if (nextFocusNode != null) {
      restoreButton = KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.tab) {
            nextFocusNode?.requestFocus();
          }
        },
        child: restoreButton,
      );
    }

    Widget bodyWidget;

    if (!isMobile) {
      bodyWidget = Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(child: cancelButton),
          const SizedBox(width: 8),
          Flexible(child: restoreButton),
        ],
      );
    } else {
      bodyWidget = Row(
        children: [
          Expanded(child: cancelButton),
          const SizedBox(width: 8),
          Expanded(child: restoreButton),
        ],
      );
    }

    if (padding != null) {
      return Padding(padding: padding!, child: bodyWidget);
    } else {
      return bodyWidget;
    }
  }
}
