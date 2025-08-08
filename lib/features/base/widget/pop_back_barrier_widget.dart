import 'package:flutter/widgets.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class PopBackBarrierWidget extends StatelessWidget {
  const PopBackBarrierWidget({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: popBack,
      child: child,
    );
  }
}