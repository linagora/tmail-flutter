import 'package:equatable/equatable.dart';

class KeyShortcut with EquatableMixin{
  final String key;
  final String code;
  final bool shift;

  KeyShortcut({
    required this.key,
    required this.code,
    this.shift = false,
  });

  bool matches(String expectedKey, {bool shift = false}) {
    return key.toLowerCase() == expectedKey.toLowerCase() &&
        this.shift == shift;
  }

  @override
  List<Object?> get props => [key, code, shift];
}
