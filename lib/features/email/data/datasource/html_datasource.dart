
import 'package:model/model.dart';

abstract class HtmlDataSource {
  Future<String> transformToHtml(EmailContent emailContent);
}