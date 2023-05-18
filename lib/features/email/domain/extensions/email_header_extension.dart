
import 'package:jmap_dart_client/jmap/mail/email/email_header.dart';
import 'package:tmail_ui_user/features/offline_mode/model/email_header_hive_cache.dart';

extension EmailHeaderExtension on EmailHeader {
  EmailHeaderHiveCache toHiveCache() => EmailHeaderHiveCache(name: name ?? "", value: value ?? "");
}