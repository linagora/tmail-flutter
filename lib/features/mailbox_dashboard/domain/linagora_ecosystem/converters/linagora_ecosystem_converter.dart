import 'package:built_collection/built_collection.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/api_key_linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/api_url_linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/app_linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/converters/mobile_apps_linagora_ecosystem_converter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/default_linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/empty_linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem_identifier.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem_properties.dart';

class LinagoraEcosystemConverter {
  static final defaultConverter = LinagoraEcosystemConverter();

  BuiltMap<LinagoraEcosystemIdentifier, LinagoraEcosystemProperties? Function(dynamic)>? _mapLinagoraEcosystemConverter;
  final mapLinagoraEcosystemConverterBuilder = MapBuilder<LinagoraEcosystemIdentifier, LinagoraEcosystemProperties? Function(dynamic)>();

  LinagoraEcosystemConverter() {
    mapLinagoraEcosystemConverterBuilder.addAll(
      {
        LinagoraEcosystemIdentifier.linShareApiUrl: ApiUrlLinagoraEcosystem.deserialize,
        LinagoraEcosystemIdentifier.linToApiUrl: ApiUrlLinagoraEcosystem.deserialize,
        LinagoraEcosystemIdentifier.twakeApiUrl: ApiUrlLinagoraEcosystem.deserialize,
        LinagoraEcosystemIdentifier.linToApiKey: ApiKeyLinagoraEcosystem.deserialize,
        LinagoraEcosystemIdentifier.twakeDrive: AppLinagoraEcosystem.deserialize,
        LinagoraEcosystemIdentifier.twakeChat: AppLinagoraEcosystem.deserialize,
        LinagoraEcosystemIdentifier.twakeSync: AppLinagoraEcosystem.deserialize,
        LinagoraEcosystemIdentifier.linShare: AppLinagoraEcosystem.deserialize,
        LinagoraEcosystemIdentifier.mobileApps: MobileAppsLinagoraEcosystemConverter.deserialize,
      });
  }

  void build() {
    _mapLinagoraEcosystemConverter = mapLinagoraEcosystemConverterBuilder.build();
  }

  MapEntry<LinagoraEcosystemIdentifier, LinagoraEcosystemProperties?> convert(String key, dynamic value) {
    if (_mapLinagoraEcosystemConverter == null) {
      build();
    }

    final identifier = LinagoraEcosystemIdentifier(key);
    if (_mapLinagoraEcosystemConverter!.containsKey(identifier)) {
      try {
        return MapEntry(identifier, _mapLinagoraEcosystemConverter![identifier]!.call(value));
      } catch (e) {
        return MapEntry(identifier, EmptyLinagoraEcosystem());
      }
    } else {
      if (value is Map<String, dynamic>) {
        return MapEntry(identifier, AppLinagoraEcosystem.deserialize(value));
      } else {
        return MapEntry(identifier, DefaultLinagoraEcosystem(value));
      }
    }
  }

  static LinagoraEcosystem deserialize(Map<String, dynamic>? json) {
    final apps = json?.map((key, value) => defaultConverter.convert(key, value));
    return LinagoraEcosystem(apps);
  }
}