import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DriveAttachmentContextMenuTile extends StatelessWidget {
  final String composerId;
  final ImagePaths imagePaths;
  final Uri workplaceUri;
  final String label;

  const DriveAttachmentContextMenuTile({
    super.key,
    required this.composerId,
    required this.imagePaths,
    required this.workplaceUri,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: SvgPicture.asset(
          imagePaths.icCloudPlus,
          width: 24,
          height: 24,
          fit: BoxFit.fill,
        ),
      ),
      title: Text(
        label,
        style: ThemeUtils.defaultTextStyleInterFont.copyWith(
          fontSize: 15,
          color: AppColor.nameUserColor,
        ),
      ),
      onTap: () {},
    );
  }
}
