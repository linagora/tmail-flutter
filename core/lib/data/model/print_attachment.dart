
import 'package:equatable/equatable.dart';

class PrintAttachment with EquatableMixin {
  final String iconBase64Data;
  final String name;
  final String size;

  PrintAttachment({
    required this.iconBase64Data,
    required this.name,
    required this.size
  });

  @override
  List<Object?> get props => [
    iconBase64Data,
    name,
    size
  ];
}