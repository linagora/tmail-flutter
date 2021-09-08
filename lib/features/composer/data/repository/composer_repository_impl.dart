
import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:tmail_ui_user/features/composer/data/datasource/composer_datasource.dart';
import 'package:tmail_ui_user/features/composer/domain/repository/composer_repository.dart';

class ComposerRepositoryImpl extends ComposerRepository {

  final Map<DataSourceType, ComposerDataSource> composerDataSources;

  ComposerRepositoryImpl(this.composerDataSources);

  @override
  Future<bool> saveEmailAddresses(List<EmailAddress> listEmailAddress) {
    return composerDataSources[DataSourceType.local]!.saveEmailAddresses(listEmailAddress);
  }
}