import 'package:core/presentation/resources/image_paths.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/app_linagora_ecosystem.dart';

part 'linagora_app.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class LinagoraApp extends AppLinagoraEcosystem {
  @JsonKey(name: 'icon')
  final String? iconName;

  @JsonKey(name: 'appLink')
  final Uri appUri;

  final Uri? publicIconUri;

  LinagoraApp({
    required this.appUri,
    this.iconName,
    this.publicIconUri,
    super.appName,
    super.androidPackageId,
    super.iosUrlScheme,
    super.iosAppStoreLink,
  });

  factory LinagoraApp.fromJson(Map<String, dynamic> json) => _$LinagoraAppFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$LinagoraAppToJson(this);

  @override
  String? getIconPath(ImagePaths imagePaths) => iconName != null
      ? imagePaths.getConfigurationImagePath(iconName!)
      : publicIconUri?.toString();

  @override
  Uri? get appRedirectLink => appUri;

  @override
  List<Object?> get props => [
    appName,
    iconName,
    appUri,
    androidPackageId,
    iosUrlScheme,
    iosAppStoreLink,
    publicIconUri
  ];
}