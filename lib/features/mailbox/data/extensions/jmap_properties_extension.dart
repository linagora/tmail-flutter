import 'package:jmap_dart_client/jmap/core/properties/properties.dart' as JmapProperties;
import 'package:model/model.dart';

extension JmapPropertiesExtension on JmapProperties.Properties {
  Properties toProperties() => Properties(value);
}