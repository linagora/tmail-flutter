import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:workplace/l10n/workplace_localizations.dart';
import 'package:workplace/presentation/mixin/drive_picker_state_mixin.dart';
import 'package:workplace/presentation/model/drive_intent_image_assets.dart';

class DriveAttachmentContextMenuTile extends StatefulWidget {
  final ImagePaths imagePaths;
  final Uri workplaceUri;
  final OnPickDriveCallback? onPickCallback;
  final FetchDriveIntentCallback onFetchIntent;
  final num? Function() maxAttachmentSizeBytesGetter;

  const DriveAttachmentContextMenuTile({
    super.key,
    required this.imagePaths,
    required this.workplaceUri,
    required this.onFetchIntent,
    required this.maxAttachmentSizeBytesGetter,
    this.onPickCallback,
  });

  @override
  State<DriveAttachmentContextMenuTile> createState() =>
      _DriveAttachmentContextMenuTileState();
}

class _DriveAttachmentContextMenuTileState
    extends State<DriveAttachmentContextMenuTile>
    with DrivePickerStateMixin<DriveAttachmentContextMenuTile> {
  @override
  FetchDriveIntentCallback get pickerFetchIntent => widget.onFetchIntent;

  @override
  OnPickDriveCallback? get pickerOnCallback => widget.onPickCallback;

  @override
  num? get maxAttachmentSizeBytes => widget.maxAttachmentSizeBytesGetter();

  @override
  DriveIntentImageAssets get driveIntentImageAssets => DriveIntentImageAssets(
        driveLogo: widget.imagePaths.twakeDriveLogo,
        closeIcon: widget.imagePaths.icClose,
        searchIcon: widget.imagePaths.icSearchBar,
      );

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final label = appLocalizations!.attachFromDrive;
    return ListTile(
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: SvgPicture.asset(
          widget.imagePaths.icCloudPlus,
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
      onTap: () {
        Navigator.pop(context);
        onPickerTap();
      },
    );
  }
}
