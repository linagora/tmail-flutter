import 'package:jmap_dart_client/jmap/core/capability/capability_properties.dart';
import 'package:json_annotation/json_annotation.dart';

part 'saas_account_capability.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class SaaSAccountCapability extends CapabilityProperties {
  final bool isPaying;
  final bool canUpgrade;

  SaaSAccountCapability({this.isPaying = false, this.canUpgrade = false});

  factory SaaSAccountCapability.fromJson(Map<String, dynamic> json) =>
      _$SaaSAccountCapabilityFromJson(json);

  Map<String, dynamic> toJson() => _$SaaSAccountCapabilityToJson(this);

  static SaaSAccountCapability deserialize(Map<String, dynamic> json) {
    return SaaSAccountCapability.fromJson(json);
  }

  bool get isPremiumAvailable => canUpgrade;

  bool get isAlreadyHighestSubscription => isPaying && !canUpgrade;

  @override
  List<Object?> get props => [isPaying, canUpgrade];
}
