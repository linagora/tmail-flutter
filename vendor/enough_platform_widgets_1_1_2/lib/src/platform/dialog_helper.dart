import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Common dialog actions
enum DialogActions { ok, cancel, okAndCancel }

/// Helps to display dialogs
class DialogHelper {
  DialogHelper._();

  /// Asks the user for confirmation with the given [title] and [query].
  ///
  /// Specify the [action] in case it's different from the title.
  /// Set [isDangerousAction] to `true` for marking the action as dangerous on Cupertino
  /// When no [cancelActionText] is specified, a cancel icon is is used
  static Future<bool?> askForConfirmation(
    BuildContext context, {
    required String title,
    required String query,
    String? action,
    bool isDangerousAction = false,
    String? cancelActionText,
  }) {
    if (PlatformInfo.isCupertino) {
      return showCupertinoDialog<bool>(
        builder: (context) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(query),
          actions: [
            CupertinoDialogAction(
              child: cancelActionText != null
                  ? Text(cancelActionText)
                  : Icon(CupertinoIcons.clear),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            CupertinoDialogAction(
              child: Text(action ?? title),
              onPressed: () => Navigator.of(context).pop(true),
              isDestructiveAction: isDangerousAction,
            ),
          ],
        ),
        context: context,
      );
    } else {
      final theme = Theme.of(context);
      var actionButtonStyle = theme.textButtonTheme.style;
      TextStyle? actionTextStyle;
      if (isDangerousAction) {
        actionButtonStyle = TextButton.styleFrom(
          backgroundColor: Colors.red,
          disabledForegroundColor: Colors.white,
          foregroundColor: Colors.white,
        );
        actionTextStyle =
            theme.textTheme.labelLarge?.copyWith(color: Colors.white);
      }

      return showDialog<bool>(
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(query),
          actions: [
            TextButton(
              child: cancelActionText != null
                  ? PlatformText(cancelActionText)
                  : Icon(Icons.cancel),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: PlatformText(action ?? title, style: actionTextStyle),
              onPressed: () => Navigator.of(context).pop(true),
              style: actionButtonStyle,
            ),
          ],
        ),
        context: context,
      );
    }
  }

  /// Shows a simple text dialog with the given [title] and [text].
  ///
  /// Compare [showWidgetDialog] for parameter details.
  static Future<T?> showTextDialog<T>(
    BuildContext context,
    String title,
    String text, {
    List<Widget>? actions,
    String? okActionText,
    String? cancelActionText,
  }) =>
      showWidgetDialog<T>(
        context,
        Text(text),
        title: title,
        actions: actions,
        okActionText: okActionText,
        cancelActionText: cancelActionText,
      );

  /// Shows a dialog with the given [content].
  ///
  /// Set the [title] to display the title on top
  /// Specify custom [actions] to provide dialog specific actions, alternatively specify the [defaultActions]. Without [actions] or [defaultActions] only and OK button is shown.
  /// Specify the [okActionText] and [cancelActionText] when no icons should be used for the default actions.
  /// When default actions are used, this method will return `true` when the user pressed `ok` and `false` after selecting `cancel`.
  static Future<T?> showWidgetDialog<T>(
    BuildContext context,
    Widget content, {
    String? title,
    List<Widget>? actions,
    DialogActions defaultActions = DialogActions.ok,
    String? okActionText,
    String? cancelActionText,
  }) {
    actions ??= [
      if (defaultActions == DialogActions.cancel ||
          defaultActions == DialogActions.okAndCancel) ...{
        PlatformTextButton(
          child: cancelActionText != null
              ? PlatformText(cancelActionText)
              : Icon(CommonPlatformIcons.cancel),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      },
      if (defaultActions == DialogActions.ok ||
          defaultActions == DialogActions.okAndCancel) ...{
        PlatformTextButton(
          child: okActionText != null
              ? PlatformText(okActionText)
              : Icon(CommonPlatformIcons.ok),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      },
    ];
    if (PlatformInfo.isCupertino) {
      return showCupertinoDialog<T>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: title == null ? null : Text(title),
          content: content,
          actions: actions!,
        ),
      );
    } else {
      return showDialog<T>(
        builder: (context) => AlertDialog(
          title: title == null ? null : Text(title),
          content: content,
          actions: actions,
        ),
        context: context,
      );
    }
  }
}
