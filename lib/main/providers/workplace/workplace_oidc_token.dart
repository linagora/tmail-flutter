import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

String? currentWorkplaceOidcToken() =>
    getBinding<AuthorizationInterceptors>()?.currentOidcIdToken;

/// Triggers the main app's OIDC refresh for Workplace's own (unwired) Dio.
/// The interceptor owns the outcome, logging included; a dead session surfaces
/// as RefreshTokenFailedException and is routed by the registry's pick-state handler.
Future<String?> refreshWorkplaceOidcToken() async {
  final interceptor = getBinding<AuthorizationInterceptors>();
  if (interceptor == null) return null;
  final newToken = await interceptor.requestTokenRefresh();
  return newToken.tokenId.uuid;
}
