
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/autocomplete/auto_complete_pattern.dart';

abstract class AutoCompleteRepository {
  Future<List<EmailAddress>> getAutoComplete(AutoCompletePattern autoCompletePattern);
}