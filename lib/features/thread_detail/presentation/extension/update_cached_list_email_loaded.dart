import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/email/presentation/model/email_loaded.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';

extension UpdateCachedEmailLoaded on ThreadDetailController {
  void cacheEmailLoaded(EmailId emailId, EmailLoaded emailLoaded) {
    const cacheLimit = 20;
    
    while (cachedEmailLoaded[emailId] == null &&
        cachedEmailLoaded.length >= cacheLimit) {
      cachedEmailLoaded.remove(cachedEmailLoaded.keys.first);
    }
    cachedEmailLoaded[emailId] = emailLoaded;
  }
}