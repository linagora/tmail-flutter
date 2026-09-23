import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/upload/presentation/dialog/drive_oversize_upload_row.dart';
import 'package:tmail_ui_user/features/upload/presentation/model/drive_oversize_transfer_state.dart';
import 'package:tmail_ui_user/features/upload/presentation/providers/drive_oversize_transfer_notifier.dart';
import 'package:tmail_ui_user/features/upload/presentation/styles/drive_oversize_upload_dialog_style.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

/// One widget serves both frames; [isWebLayout] picks the type scale, the row
/// shape and the Cancel alignment. The surface itself is the presenter's job.
class DriveOversizeUploadDialogView extends ConsumerWidget {
  final ImagePaths imagePaths;
  final bool isWebLayout;

  const DriveOversizeUploadDialogView({
    super.key,
    required this.imagePaths,
    required this.isWebLayout,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemCount = ref.watch(
      driveOversizeTransferProvider.select((items) => items.length));
    final notifier = ref.read(driveOversizeTransferProvider.notifier);
    final appLocalizations = AppLocalizations.of(context);
    final anyRunning = ref.watch(driveOversizeTransferProvider.select(
      (items) => items.any((item) => !item.status.settled)));

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: DriveOversizeUploadDialogStyle.headerPadding,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  appLocalizations.attachingFileTitle,
                  style: DriveOversizeUploadDialogStyle.title(isWebLayout),
                ),
              ),
              // Header ✕ means the same as Cancel: abandon the batch and close.
              SizedBox.square(
                dimension: DriveOversizeUploadDialogStyle.rowCloseButtonSize,
                child: TMailButtonWidget.fromIcon(
                  icon: imagePaths.icClose,
                  iconSize: DriveOversizeUploadDialogStyle.headerCloseIconSize,
                  backgroundColor: Colors.transparent,
                  onTapActionCallback: notifier.cancelAll,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: DriveOversizeUploadDialogStyle.descriptionPadding,
          child: _buildDescription(context, appLocalizations, itemCount),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: DriveOversizeUploadDialogStyle.maxListHeight),
          // shrinkWrap keeps a 1-file dialog at the Figma frame's height; the
          // list only scrolls once the batch outgrows the box.
          child: ListView.builder(
            shrinkWrap: true,
            primary: false,
            padding: EdgeInsets.zero,
            itemCount: itemCount,
            itemBuilder: (_, index) => _DriveOversizeUploadRowSlot(
              index: index,
              imagePaths: imagePaths,
              isWebLayout: isWebLayout,
            ),
          ),
        ),
        const Divider(
          height: 1,
          thickness: 1,
          color: DriveOversizeUploadDialogStyle.separatorColor,
        ),
        // The footer keeps its height when nothing is cancellable, so the
        // dialog does not jump as the last row settles.
        Align(
          alignment: isWebLayout
              ? AlignmentDirectional.centerEnd
              : AlignmentDirectional.centerStart,
          child: Padding(
            padding: DriveOversizeUploadDialogStyle.headerPadding,
            child: Opacity(
              opacity: anyRunning ? 1 : 0,
              child: IgnorePointer(
                ignoring: !anyRunning,
                child: TMailButtonWidget.fromText(
                  text: appLocalizations.cancel,
                  padding: DriveOversizeUploadDialogStyle.cancelPadding,
                  backgroundColor: Colors.transparent,
                  borderRadius: 100,
                  textStyle: DriveOversizeUploadDialogStyle.cancelTextStyle,
                  onTapActionCallback: notifier.cancelAll,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// "Your file is larger than 25 MB. It will be uploaded to Twake Drive and
  /// attached as **a link**." — the trailing run is emphasised, as in Figma.
  Widget _buildDescription(
    BuildContext context,
    AppLocalizations appLocalizations,
    int fileCount,
  ) {
    final baseStyle = DriveOversizeUploadDialogStyle.body(isWebLayout);
    final maxSize = filesize(
      Get.find<MailboxDashBoardController>().maxSizeAttachmentsPerEmail?.value ?? 0,
      0,
    );
    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: [
          TextSpan(text: appLocalizations.driveOversizeDialogMessage(maxSize)),
          TextSpan(
            text: appLocalizations.driveOversizeDialogMessageEmphasis,
            style: baseStyle.merge(DriveOversizeUploadDialogStyle.emphasisedBody),
          ),
          const TextSpan(text: '.'),
        ],
      ),
    );
  }
}

/// Watches only its own row, so a progress tick leaves the rest of the dialog alone.
class _DriveOversizeUploadRowSlot extends ConsumerWidget {
  final int index;
  final ImagePaths imagePaths;
  final bool isWebLayout;

  const _DriveOversizeUploadRowSlot({
    required this.index,
    required this.imagePaths,
    required this.isWebLayout,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = ref.watch(driveOversizeTransferProvider.select(
      (items) => index < items.length ? items[index] : null));
    // The list only empties on clear(), as the dialog closes.
    if (item == null) return const SizedBox.shrink();
    return DriveOversizeUploadRow(
      item: item,
      imagePaths: imagePaths,
      isWebLayout: isWebLayout,
      onCancel: ref.read(driveOversizeTransferProvider.notifier).cancel,
    );
  }
}
