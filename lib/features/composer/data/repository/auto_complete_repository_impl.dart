
import 'package:contact/data/datasource/auto_complete_datasource.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/autocomplete/auto_complete_pattern.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/auto_complete_repository.dart';

class AutoCompleteRepositoryImpl extends AutoCompleteRepository {

  final Set<AutoCompleteDataSource> autoCompleteDataSources;

  AutoCompleteRepositoryImpl(this.autoCompleteDataSources);

  @override
  Future<List<EmailAddress>> getAutoComplete(AutoCompletePattern autoCompletePattern) async {
    List<EmailAddress> listEmailAddress = <EmailAddress>[];

   await Future.wait(autoCompleteDataSources.map(
           (datasource) => datasource.getAutoComplete(autoCompletePattern)))
       .then((newListResult) {
          for (var listEmails in newListResult) {
            listEmailAddress.addAll(listEmails);
          }
        });

    return listEmailAddress;
  }
}