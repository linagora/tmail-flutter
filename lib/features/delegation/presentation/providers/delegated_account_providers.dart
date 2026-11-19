import 'package:get/get.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/features/delegation/data/datasource/delegated_account_datasource.dart';
import 'package:tmail_ui_user/features/delegation/data/datasource_impl/delegated_account_datasource_impl.dart';
import 'package:tmail_ui_user/features/delegation/data/network/delegated_account_api.dart';
import 'package:tmail_ui_user/features/delegation/data/repository/delegated_account_repository_impl.dart';
import 'package:tmail_ui_user/features/delegation/domain/repository/delegated_account_repository.dart';
import 'package:tmail_ui_user/features/delegation/domain/usecases/get_delegated_accounts_interactor.dart';
import 'package:tmail_ui_user/features/delegation/domain/usecases/remove_delegated_account_interactor.dart';
import 'package:tmail_ui_user/main/exceptions/thrower/remote_exception_thrower.dart';

part 'delegated_account_providers.g.dart';

@riverpod
DelegatedAccountApi delegatedAccountApi(Ref ref) =>
    DelegatedAccountApi(Get.find<HttpClient>());

@riverpod
DelegatedAccountDatasource delegatedAccountDatasource(Ref ref) =>
    DelegatedAccountDatasourceImpl(
      ref.watch(delegatedAccountApiProvider),
      Get.find<RemoteExceptionThrower>(),
    );

@riverpod
DelegatedAccountRepository delegatedAccountRepository(Ref ref) =>
    DelegatedAccountRepositoryImpl(ref.watch(delegatedAccountDatasourceProvider));

@riverpod
GetDelegatedAccountsInteractor getDelegatedAccountsInteractor(Ref ref) =>
    GetDelegatedAccountsInteractor(ref.watch(delegatedAccountRepositoryProvider));

@riverpod
RemoveDelegatedAccountInteractor removeDelegatedAccountInteractor(Ref ref) =>
    RemoveDelegatedAccountInteractor(ref.watch(delegatedAccountRepositoryProvider));
