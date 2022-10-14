import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/config/app_config_parser.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/app_dashboard/linagora_applications.dart';

class AppDashboardConfigurationParser extends AppConfigParser<LinagoraApplications> {
  @override
  Future<LinagoraApplications> parse(String value) async {
    try {
      final jsonObject = jsonDecode(value);
      return LinagoraApplications.fromJson(jsonObject);
    } catch (e) {
      logError('AppDashboardConfigurationParser::parse(): $e');
      rethrow;
    }
  }

  @override
  Future<LinagoraApplications> parseData(ByteData data) {
    throw UnimplementedError();
  }
}