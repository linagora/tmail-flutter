import 'package:mockito/annotations.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/push_notification/data/network/web_socket_api.dart';

@GenerateMocks([
  AuthorizationInterceptors,
  WebSocketApi,
])
void main() {}
