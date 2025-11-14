
import 'package:model/oidc/response/oidc_user_info.dart';

class TwakeAppManager {
  bool _hasComposer = false;
  bool _isExecutingBeforeReconnect = false;
  OidcUserInfo? _oidcUserInfo;

  void setHasComposer(bool value) => _hasComposer = value;

  bool get hasComposer => _hasComposer;

  void setExecutingBeforeReconnect(bool value) => _isExecutingBeforeReconnect = value;

  bool get isExecutingBeforeReconnect => _isExecutingBeforeReconnect;

  void setOidcUserInfo(OidcUserInfo value) => _oidcUserInfo = value;

  void clearOidcUserInfo() => _oidcUserInfo = null;

  OidcUserInfo? get oidcUserInfo => _oidcUserInfo;
}
