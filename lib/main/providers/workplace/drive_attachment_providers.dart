import 'package:dio/dio.dart';
import 'package:workplace/data/datasource/workplace_datasource.dart';
import 'package:workplace/data/datasource_impl/workplace_datasource_impl.dart';
import 'package:workplace/data/repository_impl/workplace_repository_impl.dart';
import 'package:workplace/domain/repository/workplace_repository.dart';
import 'package:workplace/domain/usecase/create_drive_intent_interactor.dart';
import 'package:workplace/domain/usecase/exchange_drive_token_interactor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Dio? _dio;
String? Function()? _oidcIdTokenGetter;

/// Call once at app startup (e.g. in NetworkBindings) after Dio is ready.
void setupDriveAttachment(Dio dio) => _dio = dio;

/// Call once after AuthorizationInterceptors is registered.
/// The getter returns the current OIDC id_token from the interceptor.
void setupDriveAttachmentOidcTokenGetter(String? Function() getter) =>
    _oidcIdTokenGetter = getter;

String? getDriveOidcIdToken() => _oidcIdTokenGetter?.call();

final _driveAttachmentDioProvider = Provider<Dio>((ref) =>
    _dio ??
    (throw StateError('Call setupDriveAttachment(dio) before using drive_attachment providers')));

final driveAttachmentDataSourceProvider = Provider<WorkplaceDataSource>(
  (ref) => WorkplaceDataSourceImpl(ref.watch(_driveAttachmentDioProvider)),
);

final driveAttachmentRepositoryProvider = Provider<WorkplaceRepository>(
  (ref) => WorkplaceRepositoryImpl(
    ref.watch(driveAttachmentDataSourceProvider),
  ),
);

final createDriveIntentInteractorProvider = Provider<CreateDriveIntentInteractor>(
  (ref) => CreateDriveIntentInteractor(
    ref.watch(driveAttachmentRepositoryProvider),
  ),
);

final exchangeDriveTokenInteractorProvider = Provider<ExchangeDriveTokenInteractor>(
  (ref) => ExchangeDriveTokenInteractor(
    ref.watch(driveAttachmentRepositoryProvider),
  ),
);
