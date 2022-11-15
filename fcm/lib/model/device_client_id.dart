
import 'package:equatable/equatable.dart';

class DeviceClientId with EquatableMixin {

  final String value;

  DeviceClientId(this.value);

  @override
  List<Object?> get props => [value];
}