import 'package:core/core.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/empty_linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem_properties.dart';

part 'app_linagora_ecosystem.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class AppLinagoraEcosystem extends LinagoraEcosystemProperties {
  final String? appName;
  final String? logoURL;
  final String? androidPackageId;
  final String? iosUrlScheme;
  final String? iosAppStoreLink;
  final Uri? webLink;

  AppLinagoraEcosystem({
    this.appName,
    this.logoURL,
    this.androidPackageId,
    this.iosUrlScheme,
    this.iosAppStoreLink,
    this.webLink,
  });

  factory AppLinagoraEcosystem.fromJson(Map<String, dynamic> json) => _$AppLinagoraEcosystemFromJson(json);

  Map<String, dynamic> toJson() => _$AppLinagoraEcosystemToJson(this);

  static LinagoraEcosystemProperties? deserialize(dynamic json) {
    if (json is Map<String, dynamic>) {
      return AppLinagoraEcosystem.fromJson(json);
    } else {
      return EmptyLinagoraEcosystem();
    }
  }

  String? getIconPath(ImagePaths imagePaths) => logoURL;

  Uri? get appRedirectLink => webLink;

  bool get isAppIOSEnabled => iosUrlScheme?.isNotEmpty == true ||
      iosAppStoreLink?.isNotEmpty == true ||
      appRedirectLink != null;

  bool get isAppAndroidEnabled => androidPackageId?.isNotEmpty == true ||
      appRedirectLink != null;

  @override
  List<Object?> get props => [
    appName,
    logoURL,
    androidPackageId,
    iosUrlScheme,
    iosAppStoreLink,
    webLink,
  ];
}