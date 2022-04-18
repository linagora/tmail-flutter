
import 'package:model/model.dart';

abstract class HtmlDataSource {
  Future<EmailContent> transformEmailContent(
    EmailContent emailContent,
    Map<String, String> mapUrlDownloadCID
  );

  Future<EmailContent> addTooltipWhenHoverOnLink(EmailContent emailContent);
}