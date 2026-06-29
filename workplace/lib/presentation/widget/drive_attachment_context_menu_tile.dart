import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:workplace/domain/entity/workplace_intent.dart';
import 'package:workplace/presentation/mixin/drive_picker_state_mixin.dart';
import 'package:workplace/presentation/mixin/web_window_message_mixin.dart';

class DriveAttachmentContextMenuTile extends StatefulWidget {
  final String composerId;
  final ImagePaths imagePaths;
  final Uri workplaceUri;
  final String label;
  final OnPickDriveCallback? onPickCallback;
  final Future<WorkplaceIntent?> Function({
    required String addAsLinkTitle,
  })? onFetchIntent;

  const DriveAttachmentContextMenuTile({
    super.key,
    required this.composerId,
    required this.imagePaths,
    required this.workplaceUri,
    required this.label,
    this.onPickCallback,
    this.onFetchIntent,
  });

  @override
  State<DriveAttachmentContextMenuTile> createState() =>
      _DriveAttachmentContextMenuTileState.create();
}

abstract class _DriveAttachmentContextMenuTileState
    extends State<DriveAttachmentContextMenuTile>
    with DrivePickerStateMixin<DriveAttachmentContextMenuTile> {
  _DriveAttachmentContextMenuTileState();

  factory _DriveAttachmentContextMenuTileState.create() => PlatformInfo.isWeb
      ? _WebDriveAttachmentContextMenuTileState()
      : _MobileDriveAttachmentContextMenuTileState();

  @override
  Future<WorkplaceIntent?> Function({
    required String addAsLinkTitle,
  })? get pickerFetchIntent => widget.onFetchIntent;

  @override
  OnPickDriveCallback? get pickerOnCallback => widget.onPickCallback;

  @override
  Widget build(BuildContext context) {
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
        widget.label,
        style: ThemeUtils.defaultTextStyleInterFont.copyWith(
          fontSize: 15,
          color: AppColor.nameUserColor,
        ),
      ),
      onTap: onPickerTap,
    );
  }
}

class _MobileDriveAttachmentContextMenuTileState
    extends _DriveAttachmentContextMenuTileState {}

class _WebDriveAttachmentContextMenuTileState
    extends _DriveAttachmentContextMenuTileState
    with WebWindowMessageMixin<DriveAttachmentContextMenuTile>,
         DrivePickerWebStateMixin<DriveAttachmentContextMenuTile> {}
