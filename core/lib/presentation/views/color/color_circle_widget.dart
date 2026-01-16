import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ColorCircleWidget extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final ImagePaths imagePaths;
  final VoidCallback onTap;

  const ColorCircleWidget({
    super.key,
    required this.color,
    required this.isSelected,
    required this.imagePaths,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: isSelected
              ? Center(
                  child: SvgPicture.asset(
                    imagePaths.icCheck,
                    colorFilter: Colors.white.asFilter(),
                    width: 18.46,
                    height: 18.46,
                    fit: BoxFit.fill,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
