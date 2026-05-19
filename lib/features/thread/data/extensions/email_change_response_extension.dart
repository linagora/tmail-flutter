import 'package:tmail_ui_user/features/thread/data/model/email_change_response.dart';

extension EmailChangeResponseExtension on EmailChangeResponse? {
  bool get hasChanged =>
      this?.created?.isNotEmpty == true
      || this?.updated?.isNotEmpty == true
      || this?.destroyed?.isNotEmpty == true;
}
