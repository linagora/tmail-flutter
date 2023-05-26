import 'package:jmap_dart_client/jmap/mail/email/email_header.dart';
import '../../../offline_mode/model/email_header_hive_cache.dart';

extension EmailHeaderHiveCacheExtension on EmailHeaderHiveCache {

  EmailHeader toEmailHeader() => EmailHeader (name,value);
}