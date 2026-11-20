import 'package:get/get.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/features/delegation/data/datasource/delegate_datasource.dart';
import 'package:tmail_ui_user/features/delegation/data/datasource_impl/delegate_datasource_impl.dart';
import 'package:tmail_ui_user/features/delegation/data/network/delegate_api.dart';
import 'package:tmail_ui_user/features/delegation/data/repository/delegate_repository_impl.dart';
import 'package:tmail_ui_user/features/delegation/domain/repository/delegate_repository.dart';
import 'package:tmail_ui_user/features/delegation/domain/usecases/add_delegates_interactor.dart';
import 'package:tmail_ui_user/features/delegation/domain/usecases/get_delegates_interactor.dart';
import 'package:tmail_ui_user/features/delegation/domain/usecases/remove_delegate_interactor.dart';
import 'package:tmail_ui_user/main/exceptions/thrower/remote_exception_thrower.dart';

part 'delegate_providers.g.dart';

@riverpod
DelegateApi delegateApi(Ref ref) => DelegateApi(Get.find<HttpClient>());

@riverpod
DelegateDatasource delegateDatasource(Ref ref) => DelegateDatasourceImpl(
      ref.watch(delegateApiProvider),
      Get.find<RemoteExceptionThrower>(),
    );

@riverpod
DelegateRepository delegateRepository(Ref ref) =>
    DelegateRepositoryImpl(ref.watch(delegateDatasourceProvider));

@riverpod
GetDelegatesInteractor getDelegatesInteractor(Ref ref) =>
    GetDelegatesInteractor(ref.watch(delegateRepositoryProvider));

@riverpod
AddDelegatesInteractor addDelegatesInteractor(Ref ref) =>
    AddDelegatesInteractor(ref.watch(delegateRepositoryProvider));

@riverpod
RemoveDelegateInteractor removeDelegateInteractor(Ref ref) =>
    RemoveDelegateInteractor(ref.watch(delegateRepositoryProvider));
