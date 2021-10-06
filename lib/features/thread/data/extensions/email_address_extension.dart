
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:tmail_ui_user/features/thread/data/model/email_address_hive_cache.dart';

extension EmailAddressExtension on EmailAddress {

  EmailAddressHiveCache toEmailAddressHiveCache() => EmailAddressHiveCache(name, email);
}