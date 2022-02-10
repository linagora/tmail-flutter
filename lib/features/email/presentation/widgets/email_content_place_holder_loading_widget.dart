
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
            Color.fromRGBO(0, 0, 0, 0.1),
            Color(0x32E5E5E5),
            Color.fromRGBO(0, 0, 0, 0.1),
          ],
      stops: [animation.value - 2, animation.value, animation.value + 1]));
}

class EmailContentPlaceHolderLoading extends StatefulWidget {

  final ResponsiveUtils responsiveUtils;

  const EmailContentPlaceHolderLoading({
    Key? key,
    required this.responsiveUtils,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EmailContentPlaceHolderLoadingState();
}

class _EmailContentPlaceHolderLoadingState extends State<EmailContentPlaceHolderLoading> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: Duration(seconds: 1), vsync: this)..repeat();
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
          margin: EdgeInsets.only(top: 16),
          padding: EdgeInsets.zero,
          color: Colors.transparent,
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(right: 64),
                height: 10,
                decoration: _radiusBoxDecoration(animation: _animation, radius: 5)),
              SizedBox(height: 16),
              Container(
                height: 10,
                decoration: _radiusBoxDecoration(animation: _animation, radius: 5)),
              SizedBox(height: 16),
              Container(
                margin: EdgeInsets.only(right: 128),
                height: 10,
                decoration: _radiusBoxDecoration(animation: _animation, radius: 5)),
            ],
          ),
        );
      },
    );
  }
}