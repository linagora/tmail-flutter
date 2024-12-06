import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/converters/api_url_linagora_ecosystem_converter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/empty_linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem_properties.dart';

class ApiUrlLinagoraEcosystem extends LinagoraEcosystemProperties {
  final String value;

  ApiUrlLinagoraEcosystem(this.value);

  static LinagoraEcosystemProperties? deserialize(dynamic json) {
    if (json is String) {
      return const ApiUrlLinagoraEcosystemConverter().fromJson(json);
    } else {
      return EmptyLinagoraEcosystem();
    }
  }

  @override
  List<Object?> get props => [value];
}