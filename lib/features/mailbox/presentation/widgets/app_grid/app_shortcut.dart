import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/image/image_loader_mixin.dart';
import 'package:flutter/material.dart';

class AppShortcut extends StatelessWidget with ImageLoaderMixin {
  final String? icon;
  final String label;
  final VoidCallback onTapAction;

  const AppShortcut({
    super.key,
    required this.icon,
    required this.label,
    required this.onTapAction,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTapAction,
        child: Container(
          width: 78,
          height: 80.58,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null)
                buildImage(
                  imagePath: icon!,
                  imageSize: 42,
                )
              else
                buildNoImage(42),
              const SizedBox(height: 4),
              Text(
                label,
                style: ThemeUtils.textStyleAppShortcut(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
