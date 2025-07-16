import 'package:collection/collection.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:model/upload/file_info.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/file_upload_extension.dart';

extension ListFileUploadExtension on List<FileUpload> {
  List<FileInfo> toListFileInfo() => map((fileUpload) => fileUpload.toFileInfo()).whereNotNull().toList();
}