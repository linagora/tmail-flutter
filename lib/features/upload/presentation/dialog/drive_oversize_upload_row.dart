import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:tmail_ui_user/features/upload/domain/model/upload_task_id.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/drive_oversize_transfer_state.dart';
import 'package:tmail_ui_user/features/upload/presentation/styles/drive_oversize_upload_dialog_style.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

/// One row per file: `[chip][size][bar][✕]` on web, `[chip][size][✕]` plus a
/// full-width bar underneath on mobile — the only structural platform diff.
class DriveOversizeUploadRow extends StatelessWidget {
  final DriveOversizeTransferState item;
  final ImagePaths imagePaths;
  final bool isWebLayout;
  final void Function(UploadTaskId taskId) onCancel;

  const DriveOversizeUploadRow({
    super.key,
    required this.item,
    required this.imagePaths,
    required this.isWebLayout,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final topLine = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildChip(),
        const SizedBox(width: 16),
        SizedBox(
          width: DriveOversizeUploadDialogStyle.sizeLabelWidth(isWebLayout),
          child: Text(
            _sizeLabel(AppLocalizations.of(context)),
            style: DriveOversizeUploadDialogStyle.sizeText(isWebLayout),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
          ),
        ),
        if (isWebLayout) ...[
          const SizedBox(width: 16),
          Expanded(child: _buildBar()),
        ] else
          const Spacer(),
        _buildCloseButton(),
      ],
    );

    return Padding(
      padding: DriveOversizeUploadDialogStyle.rowPadding,
      child: isWebLayout
          ? topLine
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                topLine,
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: DriveOversizeUploadDialogStyle.mobileBarInset),
                  child: _buildBar(),
                ),
              ],
            ),
    );
  }

  /// Fixed 191pt wide in both frames, so a long name ellipsises instead of
  /// pushing the bar off the row.
  Widget _buildChip() => Container(
        width: DriveOversizeUploadDialogStyle.chipWidth,
        padding: DriveOversizeUploadDialogStyle.chipPadding,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            DriveOversizeUploadDialogStyle.chipRadius),
          border: Border.all(
            color: DriveOversizeUploadDialogStyle.chipBorderColor),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(
                DriveOversizeUploadDialogStyle.thumbnailRadius),
              child: SvgPicture.asset(
                imagePaths.icFileDefault,
                width: DriveOversizeUploadDialogStyle.thumbnailSize,
                height: DriveOversizeUploadDialogStyle.thumbnailSize,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: DriveOversizeUploadDialogStyle.fileNameTextStyle,
              ),
            ),
          ],
        ),
      );

  /// `332M` while running (the design shows size, not percent); a terminal
  /// word once the row settles.
  String _sizeLabel(AppLocalizations appLocalizations) {
    final size = filesize(item.fileSize, 0);
    return switch (item.status) {
      DriveOversizeTransferStatus.waiting ||
      DriveOversizeTransferStatus.uploading => size,
      DriveOversizeTransferStatus.linked => appLocalizations.driveUploadRowDone,
      DriveOversizeTransferStatus.failed => appLocalizations.driveUploadRowFailed,
      DriveOversizeTransferStatus.cancelled =>
        appLocalizations.driveUploadRowCancelled,
    };
  }

  Widget _buildBar() {
    // The bridge path reports no bytes, so it stays indeterminate rather
    // than sitting at 0% for the whole transfer.
    if (!item.status.settled && item.sentBytes == 0) {
      return const ClipRRect(
        borderRadius: BorderRadius.all(
          Radius.circular(DriveOversizeUploadDialogStyle.barRadius)),
        child: LinearProgressIndicator(
          minHeight: DriveOversizeUploadDialogStyle.barHeight,
          backgroundColor: DriveOversizeUploadDialogStyle.barTrackColor,
          color: AppColor.primaryColor,
        ),
      );
    }
    // A settled row freezes its bar — no empty state in the design.
    return LinearPercentIndicator(
      percent: item.status == DriveOversizeTransferStatus.linked ? 1.0 : item.progress,
      lineHeight: DriveOversizeUploadDialogStyle.barHeight,
      barRadius: const Radius.circular(DriveOversizeUploadDialogStyle.barRadius),
      backgroundColor: DriveOversizeUploadDialogStyle.barTrackColor,
      progressColor: AppColor.primaryColor,
      padding: EdgeInsets.zero,
      animation: true,
      animateFromLastPercent: true,
    );
  }

  /// A settled row has nothing left to cancel, so the ✕ goes.
  Widget _buildCloseButton() => SizedBox.square(
        dimension: DriveOversizeUploadDialogStyle.rowCloseButtonSize,
        child: item.status.settled
            ? null
            : TMailButtonWidget.fromIcon(
                icon: imagePaths.icClose,
                iconSize: DriveOversizeUploadDialogStyle.rowCloseIconSize,
                backgroundColor: Colors.white,
                onTapActionCallback: () => onCancel(item.taskId),
              ),
      );
}
