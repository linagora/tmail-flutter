import 'package:equatable/equatable.dart';

class KeyShortcut with EquatableMixin{
  final String key;
  final String code;
  final bool shift;
  final bool ctrl;
  final bool meta;

  KeyShortcut({
    required this.key,
    required this.code,
    this.shift = false,
    this.ctrl = false,
    this.meta = false,
  });

  bool matches(String expectedKey, {bool shift = false, bool ctrl = false, bool meta = false}) {
    return key.toLowerCase() == expectedKey.toLowerCase() &&
        this.shift == shift &&
        this.ctrl == ctrl &&
        this.meta == meta;
  }

  @override
  List<Object?> get props => [key, code, shift, ctrl, meta];
}
