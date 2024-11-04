import 'package:fcm/model/type_name.dart';

class WebSocketPushEnableRequest {
  static const String type = 'WebSocketPushEnable';

  static Map<String, dynamic> toJson({
    required List<TypeName> dataTypes,
  }) {
    return {
      '@type': type,
      'dataTypes': dataTypes.map((typeName) => typeName.value).toList(),
    };
  }
}