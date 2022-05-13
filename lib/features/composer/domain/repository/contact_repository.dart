
import 'package:model/model.dart';

abstract class ContactRepository {
  Future<List<Contact>> getContactSuggestions(AutoCompletePattern autoCompletePattern);
}