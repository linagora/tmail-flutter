import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:core/utils/app_logger.dart';
import 'package:core/utils/config/app_config_parser.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/keyword_config.dart';

class AttachmentKeywordsConfigurationParser
    extends AppConfigParser<KeywordConfig> {
  @override
  Future<KeywordConfig> parse(String value) async {
    try {
      final jsonObject = jsonDecode(value);
      return KeywordConfig.fromJson(jsonObject);
    } catch (e) {
      logWarning('AttachmentKeywordsConfigurationParser::parse(): $e');
      rethrow;
    }
  }

  @override
  Future<KeywordConfig> parseData(ByteData data) {
    throw UnimplementedError();
  }
}
