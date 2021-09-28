
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';

extension PropertiesExtension on Properties {

  bool contain(String key) => value.contains(key);
}