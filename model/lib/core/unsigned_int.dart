import 'package:quiver/check.dart';

class UnsignedInt {
  static final defaultValue = UnsignedInt(0);

  final num value;

  // UnsignedInt in range [0...2^53-1].
  UnsignedInt(this.value) {
    checkArgument(value >= 0);
    checkArgument(value < 9007199254740992);
  }
}