
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:tmail_ui_user/features/composer/domain/model/auto_complete_pattern.dart';

abstract class AutoCompleteRepository {
  Future<List<EmailAddress>> getAutoComplete(AutoCompletePattern autoCompletePattern);
}