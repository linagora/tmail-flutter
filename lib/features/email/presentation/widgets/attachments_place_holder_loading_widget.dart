
import 'package:core/core.dart';
import 'package:flutter/material.dart';

const List<Color> _defaultColors = [Color.fromRGBO(0, 0, 0, 0.1), Color(0x44CCCCCC), Color.fromRGBO(0, 0, 0, 0.1)];

Decoration _radiusBoxDecoration({
  required Animation animation,
  bool hasCustomColors = false,
  AlignmentGeometry beginAlign = Alignment.topLeft,
  AlignmentGeometry endAlign = Alignment.bottomRight,
  List<Color> colors = _defaultColors,
  double radius = 10.0
}) {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(radius),
    shape: BoxShape.rectangle,
    gradient: LinearGradient(
      begin: beginAlign,
      end: endAlign,
      colors: hasCustomColors
        ? colors.map((color) {
            return color;
          }).toList()
        : [
            const Color.fromRGBO(0, 0, 0, 0.1),
            const Color(0x32E5E5E5),
            const Color.fromRGBO(0, 0, 0, 0.1),
          ],
      stops: [animation.value - 2, animation.value, animation.value + 1]));
}

class AttachmentsPlaceHolderLoading extends StatefulWidget {

  final ResponsiveUtils responsiveUtils;

  const AttachmentsPlaceHolderLoading({
    Key? key,
    required this.responsiveUtils,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AttachmentsPlaceHolderLoadingState();
}

class _AttachmentsPlaceHolderLoadingState extends State<AttachmentsPlaceHolderLoading> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(seconds: 1), vsync: this)..repeat();
    _animation = Tween<double>(begin: -2, end: 2)
      .animate(CurvedAnimation(curve: Curves.easeInOutSine, parent: _animationController));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (BuildContext context, Widget? child) {
        return Container(
          margin: const EdgeInsets.only(top: 20),
          padding: EdgeInsets.zero,
          color: Colors.transparent,
          child: Row(children: [
            _placeHolderAttachment(context),
            if (widget.responsiveUtils.isDesktop(context))
              const SizedBox(width: 16),
            if (widget.responsiveUtils.isDesktop(context))
              _placeHolderAttachment(context),
          ]),
        );
      },
    );
  }

  Widget _placeHolderAttachment(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final percentAttachment = widget.responsiveUtils.isScreenWithShortestSide(context)
        ? 0.4
        : widget.responsiveUtils.isTablet(context) ? 0.22 : 0.14;
    return Container(
      height: 55,
      width: width * percentAttachment,
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: _radiusBoxDecoration(animation: _animation),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 24,
            width: 24,
            decoration: _radiusBoxDecoration(animation: _animation, radius: 12)),
          const SizedBox(width: 8),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 5,
                decoration: _radiusBoxDecoration(animation: _animation)),
              const SizedBox(height: 10),
              Container(
                height: 5,
                decoration: _radiusBoxDecoration(animation: _animation))
            ],
          ))
        ]
      )
    );
  }
}