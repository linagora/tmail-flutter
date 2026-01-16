import 'package:equatable/equatable.dart';
import 'package:quiver/check.dart';

class HexColor with EquatableMixin {
  // Only accept #RRGGBB or #AARRGGBB format
  static final RegExp _hexPattern =
      RegExp(r'^#[0-9a-fA-F]{6}([0-9a-fA-F]{2})?$');

  final String value;

  HexColor(this.value) {
    checkArgument(value.isNotEmpty, message: 'hex string must not be empty');
    checkArgument(
      value.startsWith('#'),
      message: 'hex string must start with #',
    );
    checkArgument(
      _hexPattern.hasMatch(value),
      message: 'invalid hex format: expected #RRGGBB or #AARRGGBB',
    );
  }

  @override
  List<Object> get props => [value];
}
