import 'package:core/utils/string_convert.dart';
import 'package:equatable/equatable.dart';
import 'package:model/email/email_content_type.dart';

class EmailContent with EquatableMixin {
  final String content;
  final EmailContentType type;

  EmailContent(this.type, this.content);

  @override
  List<Object?> get props => [type, content];
}

extension EmailContentExtension on EmailContent {
  String get asHtml {
    if (type == EmailContentType.textPlain) {
      return content
          .replaceAll('\r', '')
          .replaceAll('\r\n', '')
          .replaceAll('\n', '<br/>')
          .replaceAll('\n\n', '<br/>');
    }
    return StringConvert.getContentOriginal(content);
  }
}