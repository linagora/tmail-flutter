
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:tmail_ui_user/features/thread/data/model/email_address_hive_cache.dart';

extension EmailAddressHiveCacheExtension on EmailAddressHiveCache {

  EmailAddress toEmailAddress() => EmailAddress(name, email);
}