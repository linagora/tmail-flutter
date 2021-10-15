
import 'package:model/model.dart';

abstract class HtmlDataSource {
  Future<EmailContent> transformEmailContent(EmailContent emailContent);
}