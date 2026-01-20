import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class SidebarToggleButton extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;

  const SidebarToggleButton({
    super.key,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final imagePaths = Get.find<ImagePaths>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      alignment: Alignment.center,
      child: TMailButtonWidget.fromIcon(
        key: const Key('sidebar_toggle_button'),
        icon: isExpanded ? imagePaths.icArrowLeft : imagePaths.icArrowRight,
        borderRadius: 8,
        iconSize: 16,
        iconColor: AppColor.colorTextButton,
        backgroundColor: AppColor.colorBgMailboxSelected,
        tooltipMessage: isExpanded
            ? AppLocalizations.of(context).collapse
            : AppLocalizations.of(context).expand,
        onTapActionCallback: onToggle,
      ),
    );
  }
}
