
import 'package:tmail_ui_user/features/home/domain/state/auto_sign_in_via_deep_link_state.dart';
import 'package:tmail_ui_user/main/deep_links/deep_link_data.dart';

typedef OnDeepLinkSuccessCallback = Function(AutoSignInViaDeepLinkSuccess success);

typedef OnDeepLinkFailureCallback = Function();

typedef OnDeepLinkConfirmLogoutCallback = Function(DeepLinkData deepLinkData);