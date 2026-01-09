import 'package:core/utils/app_logger.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_properties.dart';
import 'package:json_annotation/json_annotation.dart';

part 'ai_capability.g.dart';

@JsonSerializable(includeIfNull: false)
class AICapability extends CapabilityProperties {
  AICapability({this.scribeEndpoint});

  final String? scribeEndpoint;

  factory AICapability.fromJson(Map<String, dynamic> json) =>
      _$AICapabilityFromJson(json);

  Map<String, dynamic> toJson() => _$AICapabilityToJson(this);

  bool get isScribeEndpointAvailable {
    try {
      final urlEndpoint = scribeEndpoint?.trim() ?? '';

      if (urlEndpoint.isEmpty) return false;

      // Validate endpoint format - must be an absolute URI
      if (Uri.tryParse(urlEndpoint)?.isAbsolute != true) {
        logWarning(
          'AICapability::isScribeEndpointAvailable(): Invalid endpoint format: $urlEndpoint',
        );
        return false;
      }

      return true;
    } catch (e) {
      logWarning(
        'AICapability::isScribeEndpointAvailable(): Exception: $e',
      );
      return false;
    }
  }

  @override
  List<Object?> get props => [scribeEndpoint];
}
