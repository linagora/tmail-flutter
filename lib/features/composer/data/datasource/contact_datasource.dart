
import 'package:model/model.dart';

abstract class ContactDataSource {
  Future<List<Contact>> getContactSuggestions(AutoCompletePattern autoCompletePattern);
}