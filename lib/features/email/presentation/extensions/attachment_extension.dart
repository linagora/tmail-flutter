import 'package:core/data/constants/constant.dart';
import 'package:core/presentation/extensions/media_type_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/utils/platform_info.dart';
import 'package:model/download/download_task_id.dart';
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';

extension AttachmentExtension on Attachment {
  String getIcon(ImagePaths imagePaths) => type?.getIcon(imagePaths, fileName: name) ?? imagePaths.icFileEPup;

  bool get isPDFFile => type?.isPDFFile(fileName: name) ?? false;

  bool get isEMLFile => type?.isEMLFile ?? false;

  String get hyperLink => isEMLFile ? emlLink : attachmentLink;

  String get emlLink {
    if (blobId == null) return '';

    if (PlatformInfo.isWeb) {
      return RouteUtils.createUrlWebLocationBar(
        AppRoutes.emailEMLPreviewer,
        previewId: blobId!.value,
      ).toString();
    } else if (PlatformInfo.isMobile) {
      return '${Constant.emlPreviewerScheme}:${blobId!.value}';
    } else {
      return '';
    }
  }

  String get attachmentLink {
    if (blobId == null) return '';

    return '${Constant.attachmentScheme}:${blobId!.value}?name=${name ?? ''}&size=${size?.value ?? ''}&type=${type?.mimeType ?? ''}';
  }

  DownloadTaskId get downloadTaskId => DownloadTaskId(blobId!.value);

  bool get isHTMLFile => type?.isHTMLFile(fileName: name) ?? false;
}