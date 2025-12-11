import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:labels/extensions/label_extension.dart';
import 'package:labels/model/label.dart';

class LabelItemContextMenu extends StatelessWidget {
  final Label label;
  final ImagePaths imagePaths;
  final bool isSelected;

  const LabelItemContextMenu({
    super.key,
    required this.label,
    required this.imagePaths,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () {},
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              SvgPicture.asset(
                isSelected
                    ? imagePaths.icCheckboxSelected
                    : imagePaths.icCheckboxUnselected,
                width: 20,
                height: 20,
                colorFilter: isSelected
                    ? AppColor.primaryMain.asFilter()
                    : AppColor.steelGrayA540.asFilter(),
                fit: BoxFit.fill,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label.safeDisplayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ThemeUtils.textStyleBodyBody3(color: Colors.black),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
