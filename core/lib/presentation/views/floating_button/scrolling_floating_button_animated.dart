import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;

/// Widget to animate the button when scroll down
class ScrollingFloatingButtonAnimated extends StatefulWidget {
  /// Function to use when press the button
  final GestureTapCallback? onPress;

  /// Double value to set the button elevation
  final double? elevation;

  /// Double value to set the button width
  final double? width;

  /// Double value to set the button height
  final double? height;

  /// Value to set the duration for animation
  final Duration? duration;

  /// Widget to use as button icon
  final Widget? icon;

  /// Widget to use as button text when button is expanded
  final Widget? text;

  /// Value to set the curve for animation
  final Curve? curve;

  /// ScrollController to use to determine when user is on top or not
  final ScrollController? scrollController;

  /// Double value to set the boundary value when scroll animation is triggered
  final double? limitIndicator;

  /// Color to set the button background color
  final Color? color;

  /// Value to indicate if animate or not the icon
  final bool? animateIcon;

  const ScrollingFloatingButtonAnimated(
      {Key? key,
      required this.icon,
      required this.text,
      required this.onPress,
      required this.scrollController,
      this.elevation = 5.0,
      this.width = 120.0,
      this.height = 60.0,
      this.duration = const Duration(milliseconds: 250),
      this.curve,
      this.limitIndicator = 10.0,
      this.color = Colors.blueAccent,
      this.animateIcon = true})
      : super(key: key);

  @override
  _ScrollingFloatingButtonAnimatedState createState() =>
      _ScrollingFloatingButtonAnimatedState();
}

class _ScrollingFloatingButtonAnimatedState
    extends State<ScrollingFloatingButtonAnimated>
    with SingleTickerProviderStateMixin {
  /// Boolean value to indicate when scroll view is on top
  bool _onTop = true;

  /// Controller for icon animation
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      reverseDuration: const Duration(milliseconds: 250),
      animationBehavior: AnimationBehavior.normal,
      lowerBound: 0,
      upperBound: 120,
    );
    super.initState();
    _handleScroll();
  }

  @override
  void dispose() {
    widget.scrollController!.removeListener(() {});
    _animationController.dispose();
    super.dispose();
  }

  /// Function to add listener for scroll
  void _handleScroll() {
    ScrollController _scrollController = widget.scrollController!;
    _scrollController.addListener(() {
      if (_scrollController.position.pixels > widget.limitIndicator! &&
          _scrollController.position.userScrollDirection ==
              ScrollDirection.reverse) {
        if (widget.animateIcon!) _animationController.forward();
        if (mounted) {
          setState(() {
            _onTop = false;
          });
        }
      } else if (_scrollController.position.pixels <= widget.limitIndicator! &&
          _scrollController.position.userScrollDirection ==
              ScrollDirection.forward) {
        if (widget.animateIcon!) _animationController.reverse();
        if (mounted) {
          setState(() {
            _onTop = true;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    if (shortestSide < 60) {
      return const SizedBox.shrink();
    }
    return Card(
      elevation: widget.elevation,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(widget.height! / 2))),
      child: AnimatedContainer(
        curve: widget.curve ?? Curves.easeInOut,
        duration: widget.duration!,
        height: widget.height,
        width: _onTop ? widget.width : widget.height,
        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(widget.height! / 2))),
        child: InkWell(
          borderRadius: BorderRadius.all(Radius.circular(widget.height! / 2)),
          onTap: widget.onPress,
          child: Ink(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(widget.height! / 2)),
                color: widget.color),
            child: Row(
              mainAxisAlignment: _onTop ? MainAxisAlignment.spaceEvenly : MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.only(left: 16, right: _onTop ? 10 : 16),
                  child: AnimatedBuilder(
                      child: widget.icon!,
                      animation: _animationController,
                      builder: (BuildContext context, Widget? _widget) {
                        return Transform.rotate(
                          angle: (_animationController.value * 3 * math.pi) / 180,
                          child: _widget!,
                        );
                      }),
                ),
                ...(_onTop
                    ? [
                        Expanded(child: widget.text!)
                      ]
                    : []),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
