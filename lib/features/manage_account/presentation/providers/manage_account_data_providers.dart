import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource/manage_account_datasource.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource_impl/manage_account_datasource_impl.dart';
import 'package:tmail_ui_user/features/manage_account/data/repository/manage_account_repository_impl.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/manage_account_repository.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_experimental_preferences_revealed_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/providers/local/local_cache_managers_providers.dart';
import 'package:tmail_ui_user/main/providers/thrower/cache_exception_thrower_provider.dart';

part 'manage_account_data_providers.g.dart';

@riverpod
ManageAccountDataSource manageAccountDataSource(Ref ref) =>
    ManageAccountDataSourceImpl(
      ref.watch(languageCacheManagerProvider),
      ref.watch(preferencesSettingManagerProvider),
      ref.watch(cacheExceptionThrowerProvider),
    );

@riverpod
ManageAccountRepository manageAccountRepository(Ref ref) =>
    ManageAccountRepositoryImpl(ref.watch(manageAccountDataSourceProvider));

@riverpod
GetExperimentalPreferencesRevealedInteractor getExperimentalPreferencesRevealedInteractor(
  Ref ref,
) =>
    GetExperimentalPreferencesRevealedInteractor(
      ref.watch(manageAccountRepositoryProvider),
    );
