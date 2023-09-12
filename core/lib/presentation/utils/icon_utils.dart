
import 'package:core/utils/platform_info.dart';

class IconUtils {
  static const double defaultIconSize = PlatformInfo.isWeb ? 20.0 : 24.0;

  static const String chevronUpSVGIconUrlEncoded = '''
    url("data:image/svg+xml,%3Csvg class='chevron-down' width='20' height='20' viewBox='0 0 20 20' fill='none' xmlns='http://www.w3.org/2000/svg' %3E%3Cpath d='M14.5352 11.9709C14.8347 12.2276 15.2857 12.193 15.5424 11.8934C15.7991 11.5939 15.7644 11.143 15.4649 10.8863L10.4649 6.60054C10.1974 6.37127 9.8027 6.37127 9.53521 6.60054L4.53521 10.8863C4.23569 11.143 4.201 11.5939 4.45773 11.8934C4.71446 12.193 5.16539 12.2276 5.46491 11.9709L10.0001 8.08364L14.5352 11.9709Z' fill='%23AEAEC0' /%3E%3C/svg%3E")
  ''';

  static const String chevronDownSVGIconUrlEncoded = '''
    url("data:image/svg+xml,%3Csvg width='20' height='20' viewBox='0 0 20 20' fill='none' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath d='M10.0003 11.8319L5.53383 8.1098C5.18027 7.81516 4.6548 7.86293 4.36016 8.21649C4.06553 8.57006 4.1133 9.09553 4.46686 9.39016L9.46686 13.5568C9.7759 13.8144 10.2248 13.8144 10.5338 13.5568L15.5338 9.39016C15.8874 9.09553 15.9352 8.57006 15.6405 8.21649C15.3459 7.86293 14.8204 7.81516 14.4669 8.1098L10.0003 11.8319Z' fill='%23AEAEC0'/%3E%3C/svg%3E%0A")
  ''';
}