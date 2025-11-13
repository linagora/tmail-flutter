import 'package:model/oidc/response/oidc_user_info.dart';

extension OidcUserInfoExtension on OidcUserInfo {
  bool get isWorkplaceFqdnValid => workplaceFqdn?.trim().isNotEmpty == true;
}
