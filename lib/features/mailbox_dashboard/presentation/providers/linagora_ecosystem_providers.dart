import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/linagora_ecosystem_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource_impl/linagora_ecosystem_datasource_impl.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/network/linagora_ecosystem_api.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/repository/linagora_ecosystem_repository_impl.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/repository/linagora_ecosystem_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/get_linagora_system_interactor.dart';
import 'package:tmail_ui_user/main/exceptions/thrower/remote_exception_thrower.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

part 'linagora_ecosystem_providers.g.dart';

/// Ecosystem data layer, wired in Riverpod instead of a GetX binding.
///
/// Every stage stays nullable so a screen reached before the network bindings
/// are registered fails closed (no ecosystem, hidden premium CTA) rather than
/// throwing out of a provider body.
@riverpod
LinagoraEcosystemDatasource? linagoraEcosystemDatasource(Ref ref) {
  final api = getBinding<LinagoraEcosystemApi>();
  final exceptionThrower = getBinding<RemoteExceptionThrower>();
  if (api == null || exceptionThrower == null) return null;

  return LinagoraEcosystemDatasourceImpl(api, exceptionThrower);
}

@riverpod
LinagoraEcosystemRepository? linagoraEcosystemRepository(Ref ref) {
  final datasource = ref.watch(linagoraEcosystemDatasourceProvider);
  return datasource == null ? null : LinagoraEcosystemRepositoryImpl(datasource);
}

@riverpod
GetLinagoraEcosystemInteractor? getLinagoraEcosystemInteractor(Ref ref) {
  final repository = ref.watch(linagoraEcosystemRepositoryProvider);
  return repository == null ? null : GetLinagoraEcosystemInteractor(repository);
}
