
import 'package:model/upload/file_info.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/shared_media_file_extension.dart';

extension ListSharedMediaFileExtension on List<SharedMediaFile> {
  List<FileInfo> toListFileInfo({bool? isShared}) => map((sharedMediaFile) => sharedMediaFile.toFileInfo(isShared: isShared)).toList();

  int get unreadableCount => where((file) => file.type == SharedMediaType.unreadable).length;

  List<SharedMediaFile> get readableFiles => where((file) => file.type != SharedMediaType.unreadable).toList();
}