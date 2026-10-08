import 'package:core/presentation/resources/image_paths.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/drive_oversize_transfer_state.dart';
import 'package:tmail_ui_user/features/upload/presentation/providers/drive_oversize_transfer_notifier.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

/// Binds the oversize transfer state to the design-system file transfer
/// dialog. The surface itself is the presenter's job.
class DriveOversizeUploadDialogView extends ConsumerWidget {
  final ImagePaths imagePaths;
  final bool isWebLayout;

  const DriveOversizeUploadDialogView({
    super.key,
    required this.imagePaths,
    required this.isWebLayout,
  });

  LinagoraFileTransferLayout get _layout => isWebLayout
      ? LinagoraFileTransferLayout.wide
      : LinagoraFileTransferLayout.compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemCount = ref.watch(
      driveOversizeTransferProvider.select((items) => items.length));
    final anyRunning = ref.watch(driveOversizeTransferProvider.select(
      (items) => items.any((item) => !item.status.settled)));
    final notifier = ref.read(driveOversizeTransferProvider.notifier);
    final appLocalizations = AppLocalizations.of(context);

    // Header ✕ means the same as Cancel: abandon the batch and close.
    return LinagoraFileTransferDialog(
      layout: _layout,
      title: appLocalizations.attachingFileTitle,
      description: _buildDescription(appLocalizations),
      itemCount: itemCount,
      itemBuilder: (_, index) => _DriveOversizeUploadRowSlot(
        index: index,
        imagePaths: imagePaths,
        layout: _layout,
      ),
      cancelLabel: appLocalizations.cancel,
      onClose: notifier.cancelAll,
      onCancelAll: notifier.cancelAll,
      showCancelAll: anyRunning,
    );
  }

  /// "Your file is larger than 25 MB. It will be uploaded to Twake Drive and
  /// attached as **a link**." — the trailing run is emphasised, as in Figma.
  InlineSpan _buildDescription(AppLocalizations appLocalizations) {
    final maxSize = filesize(
      Get.find<MailboxDashBoardController>().maxSizeAttachmentsPerEmail?.value ?? 0,
      0,
    );
    return TextSpan(
      children: [
        TextSpan(text: appLocalizations.driveOversizeDialogMessage(maxSize)),
        TextSpan(
          text: appLocalizations.driveOversizeDialogMessageEmphasis,
          style: LinagoraFileTransferStyle.forLayout(_layout).emphasisTextStyle,
        ),
        const TextSpan(text: '.'),
      ],
    );
  }
}

/// Watches only its own row, so a progress tick leaves the rest of the dialog alone.
class _DriveOversizeUploadRowSlot extends ConsumerWidget {
  final int index;
  final ImagePaths imagePaths;
  final LinagoraFileTransferLayout layout;

  const _DriveOversizeUploadRowSlot({
    required this.index,
    required this.imagePaths,
    required this.layout,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = ref.watch(driveOversizeTransferProvider.select(
      (items) => index < items.length ? items[index] : null));
    // The list only empties on clear(), as the dialog closes.
    if (item == null) return const SizedBox.shrink();
    final notifier = ref.read(driveOversizeTransferProvider.notifier);
    return LinagoraFileTransferRow(
      layout: layout,
      fileName: item.fileName,
      statusLabel: _statusLabel(item, AppLocalizations.of(context)),
      progress: _progress(item),
      // A settled row has nothing left to cancel.
      onCancel: item.status.settled ? null : () => notifier.cancel(item.taskId),
      leading: SvgPicture.asset(imagePaths.icFileDefault, width: 20, height: 20),
    );
  }

  /// `332M` while running (the design shows size, not percent); a terminal
  /// word once the row settles.
  String _statusLabel(
    DriveOversizeTransferState item,
    AppLocalizations appLocalizations,
  ) =>
      switch (item.status) {
        DriveOversizeTransferStatus.waiting ||
        DriveOversizeTransferStatus.uploading => filesize(item.fileSize, 0),
        DriveOversizeTransferStatus.linked => appLocalizations.driveUploadRowDone,
        DriveOversizeTransferStatus.failed => appLocalizations.driveUploadRowFailed,
        DriveOversizeTransferStatus.cancelled =>
          appLocalizations.driveUploadRowCancelled,
      };

  /// The bridge path reports no bytes, so it stays indeterminate (null) rather
  /// than sitting at 0%; a settled row freezes its bar.
  double? _progress(DriveOversizeTransferState item) {
    if (item.status == DriveOversizeTransferStatus.linked) return 1.0;
    if (!item.status.settled && item.sentBytes == 0) return null;
    return item.progress;
  }
}
