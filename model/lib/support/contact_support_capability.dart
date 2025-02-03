
import 'package:jmap_dart_client/jmap/core/capability/capability_properties.dart';
import 'package:json_annotation/json_annotation.dart';

part 'contact_support_capability.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class ContactSupportCapability extends CapabilityProperties {
  final String? httpLink;
  final String? supportMailAddress;

  ContactSupportCapability({this.httpLink, this.supportMailAddress});

  factory ContactSupportCapability.fromJson(Map<String, dynamic> json) => _$ContactSupportCapabilityFromJson(json);

  Map<String, dynamic> toJson() => _$ContactSupportCapabilityToJson(this);

  static ContactSupportCapability deserialize(Map<String, dynamic> json) {
    return ContactSupportCapability.fromJson(json);
  }

  bool get isAvailable =>
      httpLink?.trim().isNotEmpty == true ||
      supportMailAddress?.trim().isNotEmpty == true;

  @override
  List<Object?> get props => [httpLink, supportMailAddress];
}