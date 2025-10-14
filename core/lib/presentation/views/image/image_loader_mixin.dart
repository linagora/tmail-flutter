
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

mixin ImageLoaderMixin {

  Widget buildImage({
    required String imagePath,
    double? imageSize
  }) {
    log('$runtimeType::buildImage: imagePath = $imagePath');
    if (PlatformInfo.isIntegrationTesting) {
      return buildNoImage(imageSize ?? 150);
    }
    if (isImageNetworkLink(imagePath) && isImageSVG(imagePath)) {
      return SvgPicture.network(
        imagePath,
        width: imageSize ?? 150,
        height: imageSize ?? 150,
        fit: BoxFit.fill,
        placeholderBuilder: (_) {
          return const CupertinoActivityIndicator();
        },
        errorBuilder: (_, __, ___) {
          return buildNoImage(imageSize ?? 150);
        },
      );
    } else if (isImageNetworkLink(imagePath)) {
      return Image.network(
        imagePath,
        fit: BoxFit.fill,
        width: imageSize ?? 150,
        height: imageSize ?? 150,
        loadingBuilder: (_, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CupertinoActivityIndicator());
        },
        errorBuilder: (_, __, ___) {
          return buildNoImage(imageSize ?? 150);
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

  Widget buildNoImage(double imageSize) {
    return Container(
      width: imageSize,
      height: imageSize,
      alignment: Alignment.center,
      child: const Icon(Icons.error_outline),
    );
  }

  bool isImageNetworkLink(String imagePath) {
    return imagePath.startsWith('http') == true ||
        imagePath.startsWith('https') == true;
  }

  bool isImageSVG(String imagePath) => imagePath.endsWith('svg') == true;
}