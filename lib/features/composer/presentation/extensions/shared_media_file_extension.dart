
import 'dart:io';

import 'package:model/upload/file_info.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/file_extension.dart';

extension SharedMediaFileExtension on SharedMediaFile {
  File toFile() => File(path);

  /// Whether [path] points at an actual file on disk (a shared file copied
  /// into the app cache) rather than holding literal shared text. Android
  /// reports both a shared sentence and a shared text-format file (.vcf,
  /// .ics, .csv, ...) with a `text/*` mime type and [SharedMediaType.text],
  /// so the payload kind can only be told apart by checking the filesystem.
  bool get isFileShare => File(path).existsSync();

  FileInfo toFileInfo({bool? isShared}) =>
    toFile().toFileInfo(
      isInline: type == SharedMediaType.image,
      isShared: isShared,
    );
}