import 'package:drive_attachment/drive_attachment/presentation/notifier/drive_attachment_notifier.dart';
import 'package:drive_attachment/drive_attachment/presentation/widget/drive_attachment_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DriveAttachmentListWidget extends ConsumerWidget {
  final String composerId;

  const DriveAttachmentListWidget({super.key, required this.composerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attachments = ref
        .watch(driveAttachmentProvider(composerId))
        .attachments;
    if (attachments.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: attachments
            .map((a) => DriveAttachmentChip(
                  attachment: a,
                  onRemove: () => ref
                      .read(driveAttachmentProvider(composerId).notifier)
                      .remove(a),
                ))
            .toList(),
      ),
    );
  }
}
