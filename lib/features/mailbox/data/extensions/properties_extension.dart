import 'package:jmap_dart_client/jmap/core/properties/properties.dart' as JmapProperties;
import 'package:model/model.dart';

extension PropertiesExtension on Properties {
  JmapProperties.Properties toJmapProperties() => JmapProperties.Properties(value);
}