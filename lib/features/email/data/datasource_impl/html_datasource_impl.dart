import 'package:core/core.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/email/data/datasource/html_datasource.dart';
import 'package:tmail_ui_user/features/email/data/local/html_analyzer.dart';

class HtmlDataSourceImpl extends HtmlDataSource {

  final HtmlAnalyzer _htmlAnalyzer;
  final DioClient _dioClient;

  HtmlDataSourceImpl(this._htmlAnalyzer, this._dioClient);

  @override
  Future<EmailContent> transformEmailContent(
      EmailContent emailContent,
      Map<String, String>? mapUrlDownloadCID
  ) {
    return Future.sync(() async {
      return await _htmlAnalyzer.transformEmailContent(emailContent, mapUrlDownloadCID, _dioClient);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<EmailContent> addTooltipWhenHoverOnLink(EmailContent emailContent) {
    return Future.sync(() async {
      return await _htmlAnalyzer.addTooltipWhenHoverOnLink(emailContent);
    }).catchError((error) {
      throw error;
    });
  }
}