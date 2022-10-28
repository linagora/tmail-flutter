import 'package:core/core.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/email/data/datasource/html_datasource.dart';
import 'package:tmail_ui_user/features/email/data/local/html_analyzer.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class HtmlDataSourceImpl extends HtmlDataSource {

  final HtmlAnalyzer _htmlAnalyzer;
  final DioClient _dioClient;
  final ExceptionThrower _exceptionThrower;

  HtmlDataSourceImpl(this._htmlAnalyzer, this._dioClient, this._exceptionThrower);

  @override
  Future<EmailContent> transformEmailContent(
      EmailContent emailContent,
      Map<String, String>? mapUrlDownloadCID
  ) {
    return Future.sync(() async {
      return await _htmlAnalyzer.transformEmailContent(emailContent, mapUrlDownloadCID, _dioClient);
    }).catchError((error) {
      _exceptionThrower.throwException(error);
    });
  }

  @override
  Future<EmailContent> addTooltipWhenHoverOnLink(EmailContent emailContent) {
    return Future.sync(() async {
      return await _htmlAnalyzer.addTooltipWhenHoverOnLink(emailContent);
    }).catchError((error) {
      _exceptionThrower.throwException(error);
    });
  }
}