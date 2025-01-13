import 'package:core/presentation/extensions/media_type_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:model/email/attachment.dart';

extension AttachmentExtension on Attachment {
  String getIcon(ImagePaths imagePaths) => type?.getIcon(imagePaths, fileName: name) ?? imagePaths.icFileEPup;

  bool get isPDFFile => type?.isPDFFile(fileName: name) ?? false;

  bool get isEMLFile => type?.isEMLFile ?? false;
}