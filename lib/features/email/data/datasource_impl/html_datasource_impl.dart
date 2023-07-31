import 'package:model/email/email_content.dart';
import 'package:tmail_ui_user/features/email/data/datasource/html_datasource.dart';
import 'package:tmail_ui_user/features/email/data/local/html_analyzer.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class HtmlDataSourceImpl extends HtmlDataSource {

  final HtmlAnalyzer _htmlAnalyzer;
  final ExceptionThrower _exceptionThrower;

  HtmlDataSourceImpl(this._htmlAnalyzer, this._exceptionThrower);

  @override
  Future<EmailContent> transformEmailContent(
    EmailContent emailContent,
    Map<String, String>? mapUrlDownloadCID,
    {bool draftsEmail = false}
  ) {
    return Future.sync(() async {
      return await _htmlAnalyzer.transformEmailContent(
        emailContent,
        mapUrlDownloadCID,
        draftsEmail: draftsEmail
      );
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<EmailContent> addTooltipWhenHoverOnLink(EmailContent emailContent) {
    return Future.sync(() async {
      return await _htmlAnalyzer.addTooltipWhenHoverOnLink(emailContent);
    }).catchError(_exceptionThrower.throwException);
  }
}