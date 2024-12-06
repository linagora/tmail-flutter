
import 'package:equatable/equatable.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/converters/linagora_ecosystem_converter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem_identifier.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem_properties.dart';

class LinagoraEcosystem with EquatableMixin {
  final Map<LinagoraEcosystemIdentifier, LinagoraEcosystemProperties?>? properties;

  LinagoraEcosystem(this.properties);

  factory LinagoraEcosystem.deserialize(Map<String, dynamic>? json) {
    return LinagoraEcosystemConverter.deserialize(json);
  }

  @override
  List<Object?> get props => [properties];
}