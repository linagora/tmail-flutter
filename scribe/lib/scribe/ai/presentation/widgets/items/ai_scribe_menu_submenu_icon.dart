import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AiScribeMenuSubmenuIcon extends StatelessWidget {
  final ImagePaths imagePaths;

  const AiScribeMenuSubmenuIcon({super.key, required this.imagePaths});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 3),
      child: SvgPicture.asset(
        imagePaths.icArrowRight,
        width: 16,
        height: 16,
        fit: BoxFit.fill,
        colorFilter: AppColor.gray777778.asFilter(),
      ),
    );
  }
}