import 'package:contact/data/datasource/auto_complete_datasource.dart';
import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/autocomplete/auto_complete_pattern.dart';
import 'package:tmail_ui_user/features/composer/data/local/email_address_database_manager.dart';

class LocalAutoCompleteDataSourceImpl extends AutoCompleteDataSource {

  final EmailAddressDatabaseManager emailAddressDatabaseManager;

  LocalAutoCompleteDataSourceImpl(this.emailAddressDatabaseManager);

  @override
  Future<List<EmailAddress>> getAutoComplete(AutoCompletePattern autoCompletePattern) {
    return Future.sync(() async {
      if (autoCompletePattern.word.isEmpty) {
        return await emailAddressDatabaseManager.getListData(
            word: autoCompletePattern.word,
            limit: autoCompletePattern.limit);
      } else {
        final condition = '${EmailAddressTable.NAME} LIKE \'%?${autoCompletePattern.word}\' OR ${EmailAddressTable.EMAIL} LIKE \'%${autoCompletePattern.word}%\'';
        return await emailAddressDatabaseManager.getListDataWithCondition(
            condition,
            word: autoCompletePattern.word,
            limit: autoCompletePattern.limit);
      }
    }).catchError((error) {
      throw error;
    });
  }
}