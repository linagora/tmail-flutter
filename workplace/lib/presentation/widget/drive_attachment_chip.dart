import 'package:workplace/domain/entity/drive_document.dart';
import 'package:flutter/material.dart';

class DriveAttachmentChip extends StatelessWidget {
  final DriveDocument attachment;
  final VoidCallback onRemove;

  const DriveAttachmentChip({
    super.key,
    required this.attachment,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) => Chip(
        avatar: const Icon(Icons.cloud, size: 16),
        label: Text(
          attachment.name,
          overflow: TextOverflow.ellipsis,
        ),
        deleteIcon: const Icon(Icons.close, size: 16),
        onDeleted: onRemove,
      );
}
