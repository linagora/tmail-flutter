import 'package:model/email/email_content.dart';
import 'package:tmail_ui_user/features/email/data/datasource/html_datasource.dart';
import 'package:tmail_ui_user/features/email/data/local/html_analyzer.dart';

class HtmlDataSourceImpl extends HtmlDataSource {

  final HtmlAnalyzer _htmlAnalyzer;

  HtmlDataSourceImpl(this._htmlAnalyzer);

  @override
  Future<EmailContent> transformEmailContent(EmailContent emailContent) {
    return Future.sync(() async {
      return await _htmlAnalyzer.transformEmailContent(emailContent);
    }).catchError((error) {
      throw error;
    });
  }
}