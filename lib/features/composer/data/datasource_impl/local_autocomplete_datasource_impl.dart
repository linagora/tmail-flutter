import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:tmail_ui_user/features/composer/data/datasource/autocomplete_datasource.dart';
import 'package:tmail_ui_user/features/composer/data/local/email_address_database_manager.dart';
import 'package:tmail_ui_user/features/composer/domain/model/auto_complete_pattern.dart';

class LocalAutoCompleteDataSourceImpl extends AutoCompleteDataSource {

  final EmailAddressDatabaseManager emailAddressDatabaseManager;

  LocalAutoCompleteDataSourceImpl(this.emailAddressDatabaseManager);

  @override
  Future<List<EmailAddress>> getAutoComplete(AutoCompletePattern autoCompletePattern) {
    return Future.sync(() async {
      if (autoCompletePattern.isAll == true) {
        return await emailAddressDatabaseManager.getListData(
            word: autoCompletePattern.word,
            limit: autoCompletePattern.limit,
            orderBy: autoCompletePattern.orderBy);
      } else {
        final condition = '${EmailAddressTable.NAME} LIKE \'%?${autoCompletePattern.word}\' OR ${EmailAddressTable.EMAIL} LIKE \'%${autoCompletePattern.word}%\'';
        return await emailAddressDatabaseManager.getListDataWithCondition(
            condition,
            word: autoCompletePattern.word,
            limit: autoCompletePattern.limit,
            orderBy: autoCompletePattern.orderBy);
      }
    }).catchError((error) {
      throw error;
    });
  }
}