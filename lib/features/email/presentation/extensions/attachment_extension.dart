import 'package:core/presentation/resources/image_paths.dart';
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/upload/domain/extensions/media_type_extension.dart';

extension AttachmentExtension on Attachment {
  String getIcon(ImagePaths imagePaths) => type?.getIcon(imagePaths, fileName: name) ?? imagePaths.icFileEPup;
}