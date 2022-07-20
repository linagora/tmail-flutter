
import 'package:core/presentation/extensions/html_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/image_source.dart';

class InlineImage with EquatableMixin {
  final ImageSource source;
  final String? link;
  final FileInfo? fileInfo;
  final String? cid;
  final String? base64;

  InlineImage(
    this.source,
    {
      this.link,
      this.fileInfo,
      this.cid,
      this.base64,
    }
  );

  Future<String> generateImgTagHtml({double? maxWithEditor}) async {
    if (source == ImageSource.local && base64 != null) {
      return base64!.generateImageBase64(
          cid!,
          fileInfo!.fileExtension,
          fileInfo!.fileName,
          maxWithEditor: maxWithEditor);
    }
    return '';
  }

  @override
  List<Object?> get props => [source, link, fileInfo, cid];
}