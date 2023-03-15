
import 'package:model/model.dart';

abstract class HtmlDataSource {
  Future<EmailContent> transformEmailContent(
    EmailContent emailContent,
    Map<String, String> mapUrlDownloadCID,
    {bool draftsEmail = false}
  );

  Future<EmailContent> addTooltipWhenHoverOnLink(EmailContent emailContent);
}