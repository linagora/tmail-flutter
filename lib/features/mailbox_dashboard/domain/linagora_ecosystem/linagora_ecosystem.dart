
import 'package:equatable/equatable.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/app_linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/converters/linagora_ecosystem_converter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem_identifier.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem_properties.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/mobile_apps_linagora_ecosystem.dart';

class LinagoraEcosystem with EquatableMixin {
  final Map<LinagoraEcosystemIdentifier, LinagoraEcosystemProperties?>? properties;

  LinagoraEcosystem(this.properties);

  factory LinagoraEcosystem.deserialize(Map<String, dynamic>? json) {
    return LinagoraEcosystemConverter.deserialize(json);
  }

  @override
  List<Object?> get props => [properties];
}

extension LinagoraEcosystemExtension on LinagoraEcosystem {
  List<AppLinagoraEcosystem> get listAppLinagoraEcosystem {
    if (properties == null) return [];

    final listWebAppLinagora = properties
      !.values
      .whereType<AppLinagoraEcosystem>()
      .toList();

    final listMobileAppLinagora = (properties![LinagoraEcosystemIdentifier.mobileApps] as MobileAppsLinagoraEcosystem?)
      ?.apps
      ?.values
      .whereType<AppLinagoraEcosystem>()
      .toList() ?? [];

    return listWebAppLinagora + listMobileAppLinagora;
  }

  List<AppLinagoraEcosystem> get listAppLinagoraEcosystemOnIOS {
    return listAppLinagoraEcosystem.where((app) => app.isAppIOSEnabled).toList();
  }

  List<AppLinagoraEcosystem> get listAppLinagoraEcosystemOnAndroid {
    return listAppLinagoraEcosystem.where((app) => app.isAppAndroidEnabled).toList();
  }
}