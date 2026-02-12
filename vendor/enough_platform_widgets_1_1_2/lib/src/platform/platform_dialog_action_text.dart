import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

/// A platform aware dialog action text
class PlatformDialogActionText extends StatelessWidget {
  final String text;
  final Function()? onPressed;
  final bool isDestructiveAction;
  final bool isDefaultAction;

  /// Creates a new platform aware dialog action.
  ///
  /// Translates to a `TextButton` on material and a `CupertinoDialogAction` on cupertino.
  /// Default actions will have bold text but only on cupertino.
  /// Destructive actions will be rendered in red text on cupertino and with a red filled background on material.
  const PlatformDialogActionText({
    Key? key,
    required this.text,
    this.onPressed,
    this.isDestructiveAction = false,
    this.isDefaultAction = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformWidget(
      material: (context, platform) {
        final theme = Theme.of(context);
        var actionButtonStyle = theme.textButtonTheme.style;
        TextStyle? actionTextStyle;
        if (isDestructiveAction) {
          actionButtonStyle = TextButton.styleFrom(
            backgroundColor: Colors.red,
            disabledForegroundColor: Colors.white,
            foregroundColor: Colors.white,
          );
          actionTextStyle =
              theme.textTheme.labelLarge?.copyWith(color: Colors.white);
        }
        return TextButton(
          child: Text(text.toUpperCase(), style: actionTextStyle),
          style: actionButtonStyle,
          onPressed: onPressed,
        );
      },
      cupertino: (context, platform) => CupertinoDialogAction(
        child: Text(text),
        onPressed: onPressed,
        isDestructiveAction: isDestructiveAction,
        isDefaultAction: isDefaultAction,
      ),
    );
  }
}
