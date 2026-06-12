import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:workplace/presentation/provider/drive_attachment_available_provider.dart';

class DriveAttachmentContextMenuTile extends ConsumerWidget {
  final String composerId;
  final ImagePaths imagePaths;
  final String label;

  const DriveAttachmentContextMenuTile({
    super.key,
    required this.composerId,
    required this.imagePaths,
    required this.label,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAvailable = ref.watch(isDriveAttachmentAvailableProvider);
    if (!isAvailable) return const SizedBox.shrink();
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
