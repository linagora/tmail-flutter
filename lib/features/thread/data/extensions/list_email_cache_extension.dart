
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/thread/data/extensions/email_cache_extension.dart';
import 'package:tmail_ui_user/features/thread/data/model/email_cache.dart';

extension ListEmailCacheExtension on List<EmailCache> {
  List<Email> toEmailList() => map((emailCache) => emailCache.toEmail()).toList();
}