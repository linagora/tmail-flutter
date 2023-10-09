import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/thread/presentation/styles/scroll_to_top_button_widget_styles.dart';

class ScrollToTopButtonWidget extends StatefulWidget {
  final ScrollController scrollController;
  final GestureTapCallback onTap;
  final ResponsiveUtils responsiveUtils;
  final double? limitIndicator;
  final double? elevation;
  final Color? colorButton;
  final double? buttonRadius;
  final Widget? icon;

  const ScrollToTopButtonWidget({
    Key? key,
    required this.scrollController,
    required this.onTap,
    required this.responsiveUtils,
    this.limitIndicator = ScrollToTopButtonWidgetStyles.defaultLimitIndicator,
    this.elevation = ScrollToTopButtonWidgetStyles.defaultElevation,
    this.colorButton = ScrollToTopButtonWidgetStyles.defaultColor,
    this.buttonRadius = ScrollToTopButtonWidgetStyles.defaultButtonRadius,
    this.icon,
  }) : super(key: key);

  @override
  State<ScrollToTopButtonWidget> createState() => _ScrollToTopButtonWidgetState();
}

class _ScrollToTopButtonWidgetState extends State<ScrollToTopButtonWidget> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _handleScroll();
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(() {});
    super.dispose();
  }

  void _handleScroll() {
    ScrollController scrollController = widget.scrollController;
    scrollController.addListener(() {
      if (scrollController.position.pixels > widget.limitIndicator!) {
        if (mounted) {
          setState(() {
            _isVisible = true;
          });
        }
      } else if (scrollController.position.pixels <= widget.limitIndicator!) {
        if (mounted) {
          setState(() {
            _isVisible = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.responsiveUtils.isWebDesktop(context)) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: AlignmentDirectional.bottomEnd,
      child: Visibility(
        visible: _isVisible,
        child: Card(
          elevation: widget.elevation,
          shape: const CircleBorder(),
          child: InkWell(
            borderRadius: BorderRadius.circular(widget.buttonRadius!),
            onTap: widget.onTap,
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.buttonRadius!),
                color: widget.colorButton,
              ),
              padding: const EdgeInsets.all(ScrollToTopButtonWidgetStyles.buttonPadding),
              child: widget.icon,
            )
          ),
        )
      ),
    );
  }
}