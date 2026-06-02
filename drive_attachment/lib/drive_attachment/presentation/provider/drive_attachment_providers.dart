import 'package:dio/dio.dart';
import 'package:drive_attachment/drive_attachment/data/datasource/drive_attachment_datasource.dart';
import 'package:drive_attachment/drive_attachment/data/datasource_impl/drive_attachment_datasource_impl.dart';
import 'package:drive_attachment/drive_attachment/data/repository_impl/drive_attachment_repository_impl.dart';
import 'package:drive_attachment/drive_attachment/domain/repository/drive_attachment_repository.dart';
import 'package:drive_attachment/drive_attachment/domain/usecase/create_drive_intent_interactor.dart';
import 'package:drive_attachment/drive_attachment/domain/usecase/exchange_drive_token_interactor.dart';
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

final driveAttachmentDataSourceProvider = Provider<DriveAttachmentDataSource>(
  (ref) => DriveAttachmentDataSourceImpl(ref.watch(_driveAttachmentDioProvider)),
);

final driveAttachmentRepositoryProvider = Provider<DriveAttachmentRepository>(
  (ref) => DriveAttachmentRepositoryImpl(
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
