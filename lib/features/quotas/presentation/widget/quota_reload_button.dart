import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';

class QuotaReloadButton extends StatefulWidget {
  const QuotaReloadButton({
    super.key,
    required this.icon,
    required this.isLoading,
    required this.onTap,
  });

  final String icon;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  State<QuotaReloadButton> createState() => _QuotaReloadButtonState();
}

class _QuotaReloadButtonState extends State<QuotaReloadButton> with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: const Duration(seconds: 1));
  }

  @override
  void didUpdateWidget(covariant QuotaReloadButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLoading != widget.isLoading) {
      if (widget.isLoading) {
        controller.repeat();
      } else {
        controller.stop();
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: Tween(begin: 0.0, end: 1.0).animate(controller),
      child: TMailButtonWidget.fromIcon(
        icon: widget.icon,
        iconColor: AppColor.steelGray400,
        backgroundColor: Colors.transparent,
        iconSize: 20,
        padding: EdgeInsets.zero,
        onTapActionCallback: () {
          if (widget.isLoading) return;
      
          widget.onTap();
        },
      ),
    );
  }
}