
import 'package:core/utils/app_logger.dart';
import 'package:equatable/equatable.dart';
import 'package:model/email/email_content_type.dart';
import 'package:model/model.dart';

class EmailContent with EquatableMixin {

  static const defaultHtmlTagsWrapContent = '<html><head></head><body></body></html>';

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
    final newContent = _getContentOriginal(content);
    return newContent;
  }

  String _getContentOriginal(String content) {
    if (content == EmailContent.defaultHtmlTagsWrapContent ||
        content.trim().isEmpty) {
      return '';
    }

    final firstTags = '<html><head></head><body>';
    final latestTags = '</body></html>';
    if (content.startsWith(firstTags) && content.endsWith(latestTags)) {
      final firstIndex = firstTags.length;
      final latestIndex = content.length - latestTags.length;
      log('EmailContentExtension::_getContentOriginal(): firstIndex: $firstIndex');
      log('EmailContentExtension::_getContentOriginal(): latestIndex: $latestIndex');

      if (latestIndex > firstIndex) {
        final contentOriginal = content.substring(firstIndex, latestIndex);
        log('EmailContentExtension::_getContentOriginal(): contentOriginal: $contentOriginal');
        return contentOriginal;
      }
    }

    return content;
  }
}