import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';

class ScrollbarListView extends StatelessWidget {

  static bool isVerticalScrollNotification(
    ScrollNotification notification,
  ) => notification.metrics.axis == Axis.vertical;

  final Widget child;
  final ScrollController scrollController;
  final ScrollBehavior? scrollBehavior;
  final ScrollNotificationPredicate? notificationPredicate;
  final bool thumbVisibility;
  final bool trackVisibility;

  const ScrollbarListView({
    super.key,
    required this.child,
    required this.scrollController,
    this.scrollBehavior,
    this.notificationPredicate,
    this.thumbVisibility = true,
    this.trackVisibility = true,
  });

  @override
  Widget build(BuildContext context) {
    return RawScrollbar(
      thickness: 6,
      thumbColor: AppColor.thumbScrollbarColor,
      radius: const Radius.circular(10.0),
      trackRadius: const Radius.circular(10.0),
      minThumbLength: 70,
      minOverscrollLength: 70,
      controller: scrollController,
      thumbVisibility: thumbVisibility,
      trackVisibility: trackVisibility,
      interactive: true,
      notificationPredicate:
          notificationPredicate ?? defaultScrollNotificationPredicate,
      child: ScrollConfiguration(
        behavior: scrollBehavior ?? ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: child,
      ),
    );
  }
}
