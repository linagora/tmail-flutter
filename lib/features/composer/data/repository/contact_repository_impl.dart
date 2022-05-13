

import 'package:model/model.dart';
import 'package:tmail_ui_user/features/composer/data/datasource/contact_datasource.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/contact_repository.dart';

class ContactRepositoryImpl implements ContactRepository {
  final ContactDataSource _contactDataSource;

  ContactRepositoryImpl(this._contactDataSource);

  @override
  Future<List<Contact>> getContactSuggestions(AutoCompletePattern autoCompletePattern) {
    return _contactDataSource.getContactSuggestions(autoCompletePattern);
  }
}