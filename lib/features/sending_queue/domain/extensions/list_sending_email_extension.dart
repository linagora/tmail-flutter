import 'package:tmail_ui_user/features/offline_mode/model/sending_email_hive_cache.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/extensions/sending_email_extension.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/model/sending_email.dart';

extension ListSendingEmailExtension on List<SendingEmail> {
  List<SendingEmailHiveCache> toHiveCache() => map((sendingEmail) => sendingEmail.toHiveCache()).toList();

  List<String> get sendingIds => map((sendingEmail) => sendingEmail.sendingId).toSet().toList();
}