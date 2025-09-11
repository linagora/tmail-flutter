import 'package:equatable/equatable.dart';

class NamedAddress with EquatableMixin {
  final String name;
  final String address;

  NamedAddress({required this.name, required this.address});

  @override
  List<Object?> get props => [name, address];

  @override
  String toString() => name.isNotEmpty ? '$name <$address>' : address;
}