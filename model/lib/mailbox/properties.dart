import 'package:equatable/equatable.dart';

class Properties with EquatableMixin {
  final Set<String> value;

  Properties(this.value);

  static Properties empty() => Properties(Set());

  Properties union(Properties other) => Properties(value.union(other.value));

  Properties removeAll(Properties other) => Properties(value..removeAll(other.value));

  bool isEmpty() => value.isEmpty;

  Properties operator +(Properties other) => union(other);

  Properties operator -(Properties other) => removeAll(other);

  @override
  List<Object?> get props => [value];
}