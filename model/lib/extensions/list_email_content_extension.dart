import 'package:model/model.dart';

extension ListEmailContentExtension on List<EmailContent> {

  String get asHtmlString {
    if (isNotEmpty) {
      return map((content) => content.asHtml).join('</br>');
    }
    return '';
  }
}