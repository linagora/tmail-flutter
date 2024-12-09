
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

mixin ImageLoaderMixin {

  Widget buildImage({
    required String imagePath,
    double? imageSize
  }) {
    if (isImageNetworkLink(imagePath)) {
      return Image.network(
        imagePath,
        fit: BoxFit.fill,
        width: imageSize ?? 150,
        height: imageSize ?? 150,
        errorBuilder: (_, __, ___) {
          return Container(
            width: imageSize ?? 150,
            height: imageSize ?? 150,
            color: AppColor.textFieldHintColor,
          );
        },
      );
    } else if (isImageSVG(imagePath)) {
      return SvgPicture.asset(
        imagePath,
        width: imageSize ?? 150,
        height: imageSize ?? 150,
      );
    } else {
      return Image.asset(
        imagePath,
        fit: BoxFit.fill,
        width: imageSize ?? 150,
        height: imageSize ?? 150,
      );
    }
  }

  bool isImageNetworkLink(String imagePath) {
    return imagePath.startsWith('http') == true ||
        imagePath.startsWith('https') == true;
  }

  bool isImageSVG(String imagePath) => imagePath.endsWith('svg') == true;
}