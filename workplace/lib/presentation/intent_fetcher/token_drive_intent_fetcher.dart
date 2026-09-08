import 'package:workplace/data/datasource_impl/workplace_datasource_impl.dart';
import 'package:workplace/data/repository_impl/workplace_repository_impl.dart';
import 'package:workplace/domain/entity/workplace_intent.dart';
import 'package:workplace/domain/entity/workplace_intent_config.dart';
import 'package:workplace/domain/exceptions/workplace_exceptions.dart';
import 'package:workplace/domain/repository/workplace_repository.dart';
import 'package:workplace/domain/state/workplace_intent_state.dart';
import 'package:workplace/domain/usecase/create_drive_intent_interactor.dart';
import 'package:workplace/domain/usecase/exchange_drive_token_interactor.dart';
import 'package:workplace/presentation/intent_fetcher/drive_intent_fetcher.dart';
import 'package:workplace/presentation/intent_fetcher/interactor_result_extension.dart';

/// Direct HTTP to Drive: OIDC id_token → Drive access token → bearer call.
class TokenDriveIntentFetcher implements DriveIntentFetcher {
  final String? Function() oidcTokenGetter;
  final WorkplaceRepository _repository;
  late final _createIntentInteractor = CreateDriveIntentInteractor(_repository);
  late final _exchangeTokenInteractor = ExchangeDriveTokenInteractor(_repository);

  TokenDriveIntentFetcher({
    required this.oidcTokenGetter,
    WorkplaceRepository? repository,
  }) : _repository =
            repository ?? WorkplaceRepositoryImpl(WorkplaceDataSourceImpl());

  /// Always a candidate; a missing OIDC token is reported as a failure, not
  /// as "unavailable", so the user learns why the picker did not open.
  @override
  bool get isAvailable => true;

  @override
  Future<WorkplaceIntent> fetchIntent(
    Uri platformUrl,
    WorkplaceIntentConfig config,
  ) async {
    final oidcToken = oidcTokenGetter();
    if (oidcToken == null) throw StateError('OIDC token is unavailable');
    final accessToken = await _exchangeAccessToken(platformUrl, oidcToken);
    final success = await _createIntentInteractor
        .execute(platformUrl, accessToken, config: config)
        .firstSuccess<CreateWorkplaceIntentSuccess>(
          orElse: WorkplaceCreateIntentException.new,
        );
    return success.intent;
  }

  Future<String> _exchangeAccessToken(Uri platformUrl, String oidcToken) async {
    final success = await _exchangeTokenInteractor
        .execute(platformUrl, oidcToken)
        .firstSuccess<ExchangeWorkplaceTokenSuccess>(
          orElse: WorkplaceExchangeTokenException.new,
        );
    return success.accessToken;
  }
}
