
import 'package:jmap_dart_client/jmap/mail/email/email_header.dart';
import 'package:tmail_ui_user/features/email/domain/extensions/email_header_extension.dart';
import 'package:tmail_ui_user/features/offline_mode/model/email_header_hive_cache.dart';

extension ListEmailHeaderExtension on List<EmailHeader> {
  List<EmailHeaderHiveCache> toHiveCache() => map((emailHeader) => emailHeader.toHiveCache()).toList();
}