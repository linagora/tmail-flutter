
import 'dart:io';

import 'package:core/utils/platform_info.dart';
import 'package:model/upload/file_info.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/file_extension.dart';

extension SharedMediaFileExtension on SharedMediaFile {
  File toFile() {
    if (PlatformInfo.isIOS) {
      final pathFile = type == SharedMediaType.FILE
        ? path.toString().replaceAll('file:/', '').replaceAll('%20', ' ')
        : path.toString().replaceAll('%20', ' ');
      return File(pathFile);
    } else {
      return File(path);
    }
  }

  FileInfo toFileInfo({bool? isShared}) => toFile().toFileInfo(isInline: type == SharedMediaType.IMAGE, isShared: isShared);
}