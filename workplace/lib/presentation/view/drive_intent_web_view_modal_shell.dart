import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:workplace/l10n/workplace_localizations.dart';
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

  Widget buildButton({
    required VoidCallback onTap,
    required String label,
    required TextTheme? textTheme,
    required Color textColor,
    required Color backgroundColor,
  }) {
    return TMailButtonWidget.fromText(
      text: label,
      textStyle: textTheme?.labelLarge?.copyWith(
        letterSpacing: 0.5,
        color: textColor,
      ),
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

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return PointerInterceptor(
    child: GestureDetector(
      onTap: onClose,
      behavior: HitTestBehavior.opaque,
      child: Dialog(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
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
                  child: TMailButtonWidget.fromIcon(
                    icon: ImagePaths().icClose,
                    iconColor: const Color(0xFF424244).withValues(alpha: 0.64),
                    padding: const EdgeInsets.all(12),
                    hoverColor: Colors.transparent,
                    onTapActionCallback: onClose,
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
                        textTheme: textTheme,
                        textColor: AppColor.primaryMain,
                        backgroundColor: Colors.transparent,
                      ),
                      const SizedBox(width: 16),
                      buildButton(
                        onTap: onClose,
                        label: localizations.addAsLink,
                        textTheme: textTheme,
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
