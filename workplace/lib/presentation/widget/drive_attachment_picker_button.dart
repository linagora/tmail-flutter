import 'package:core/presentation/extensions/composer_toolbar_button_style.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:workplace/presentation/mixin/drive_picker_state_mixin.dart';
import 'package:workplace/presentation/mixin/web_window_message_mixin.dart';

class DriveAttachmentPickerButton extends StatefulWidget {
  final String composerId;
  final ImagePaths imagePaths;
  final Uri workplaceUri;
  final ComposerToolbarButtonStyle style;
  final OnPickDriveCallback? onPickCallback;
  final FetchDriveIntentCallback? onFetchIntent;

  const DriveAttachmentPickerButton({
    super.key,
    required this.composerId,
    required this.imagePaths,
    required this.workplaceUri,
    this.style = const ComposerToolbarButtonStyle(),
    this.onPickCallback,
    this.onFetchIntent,
  });

  @override
  State<DriveAttachmentPickerButton> createState() =>
      _DriveAttachmentPickerButtonState.create();
}

abstract class _DriveAttachmentPickerButtonState
    extends State<DriveAttachmentPickerButton>
    with DrivePickerStateMixin<DriveAttachmentPickerButton> {
  _DriveAttachmentPickerButtonState();

  factory _DriveAttachmentPickerButtonState.create() => PlatformInfo.isWeb
      ? _WebDriveAttachmentPickerButtonState()
      : _MobileDriveAttachmentPickerButtonState();

  @override
  FetchDriveIntentCallback? get pickerFetchIntent => widget.onFetchIntent;

  @override
  OnPickDriveCallback? get pickerOnCallback => widget.onPickCallback;

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

class _MobileDriveAttachmentPickerButtonState
    extends _DriveAttachmentPickerButtonState {}

class _WebDriveAttachmentPickerButtonState
    extends _DriveAttachmentPickerButtonState
    with WebWindowMessageMixin<DriveAttachmentPickerButton>,
         DrivePickerWebStateMixin<DriveAttachmentPickerButton> {}
