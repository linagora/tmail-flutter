
import 'package:equatable/equatable.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/image_source.dart';

class InlineImage with EquatableMixin {
  final ImageSource source;
  final String? link;
  final FileInfo? fileInfo;
  final String? cid;
  final String? base64Uri;

  InlineImage(
    this.source,
    {
      this.link,
      this.fileInfo,
      this.cid,
      this.base64Uri,
    }
  );

  @override
  List<Object?> get props => [source, link, fileInfo, cid, base64Uri];
}