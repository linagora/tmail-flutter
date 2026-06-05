import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:workplace/l10n/drive_attachment_localizations.dart';
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

typedef DriveMessageHandler = void Function(String raw, String? origin);
typedef OnRegisterExternalHandler = void Function(DriveMessageHandler handler);

class DriveIntentWebViewModalShell extends StatelessWidget {
  final Widget child;
  final VoidCallback onClose;

  const DriveIntentWebViewModalShell({
    super.key,
    required this.child,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final buttonTextStyle = textTheme.labelLarge?.copyWith(
      letterSpacing: 0.5,
    );

    Widget buildButton({
      required VoidCallback onTap,
      required String label,
      required Color textColor,
      required Color backgroundColor,
    }) {
      return TMailButtonWidget.fromText(
        text: label,
        textStyle: buttonTextStyle?.copyWith(color: textColor),
        backgroundColor: backgroundColor,
        hoverColor: Colors.transparent,
        border: BoxBorder.all(color: textColor),
        borderRadius: 100,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 10,
        ),
        onTapActionCallback: onTap,
      );
    }
    return PointerInterceptor(
    child: GestureDetector(
      onTap: onClose,
      behavior: HitTestBehavior.opaque,
      child: Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800, maxHeight: 677),
          child: GestureDetector(
            onTap: () {},
            behavior: HitTestBehavior.opaque,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsetsGeometry.directional(end: 17),
                  child: IconButton(
                    icon: Icon(
                      Icons.close,
                      color: const Color(0xFF424244).withValues(alpha: 0.64),
                    ),
                    padding: const EdgeInsets.all(12),
                    hoverColor: Colors.transparent,
                    onPressed: onClose,
                  ),
                ),
                Expanded(child: child),
                Container(
                  padding: const EdgeInsetsGeometry.fromSTEB(28, 25, 32, 25),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(6),
                    )
                  ),
                  child: Row(
                    children: [
                      const Spacer(),
                      buildButton(
                        onTap: onClose,
                        label: localizations.addAsAttachment,
                        textColor: AppColor.primaryMain,
                        backgroundColor: Colors.transparent,
                      ),
                      const SizedBox(width: 16),
                      buildButton(
                        onTap: onClose,
                        label: localizations.addAsLink,
                        textColor: Colors.white,
                        backgroundColor: AppColor.primaryMain,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  }
}
