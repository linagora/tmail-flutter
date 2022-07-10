import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/email_cache.dart';

abstract class EmailCacheDataSource {
  void saveEmailCacheOnWeb(Email email);

  EmailCache? getEmailCacheOnWeb();

  void removeEmailCacheOnWeb();
}