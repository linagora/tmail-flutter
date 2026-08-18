import 'package:core/presentation/extensions/composer_toolbar_button_style.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:workplace/presentation/mixin/drive_picker_state_mixin.dart';
import 'package:workplace/presentation/model/drive_intent_image_assets.dart';

class DriveAttachmentPickerButton extends StatefulWidget {
  final String composerId;
  final ImagePaths imagePaths;
  final Uri workplaceUri;
  final ComposerToolbarButtonStyle style;
  final OnPickDriveCallback? onPickCallback;
  final FetchDriveIntentCallback onFetchIntent;
  final num? Function() maxAttachmentSizeBytesGetter;

  const DriveAttachmentPickerButton({
    super.key,
    required this.composerId,
    required this.imagePaths,
    required this.workplaceUri,
    required this.onFetchIntent,
    required this.maxAttachmentSizeBytesGetter,
    this.style = const ComposerToolbarButtonStyle(),
    this.onPickCallback,
  });

  @override
  State<DriveAttachmentPickerButton> createState() =>
      _DriveAttachmentPickerButtonState();
}

class _DriveAttachmentPickerButtonState
    extends State<DriveAttachmentPickerButton>
    with DrivePickerStateMixin<DriveAttachmentPickerButton> {
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
    return TMailButtonWidget.fromIcon(
      icon: widget.imagePaths.icCloudPlus,
      iconColor: widget.style.iconColor,
      backgroundColor: Colors.transparent,
      iconSize: widget.style.iconSize,
      borderRadius: widget.style.borderRadius,
      padding: widget.style.padding,
      margin: widget.style.margin,
      tooltipMessage: widget.style.tooltipLabel,
      onTapActionCallback: onPickerTap,
    );
  }
}
