
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DefaultSwitchIconWidget extends StatelessWidget {

  final ImagePaths imagePaths;
  final bool isEnabled;

  const DefaultSwitchIconWidget({
    super.key,
    required this.imagePaths,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      key: key,
      isEnabled ? imagePaths.icSwitchOn : imagePaths.icSwitchOff,
      fit: BoxFit.fill,
      width: 44,
      height: 28,
    );
  }
}
