
import 'package:equatable/equatable.dart';

class PrintAttachment with EquatableMixin {
  final String iconSvg;
  final String name;
  final String size;

  PrintAttachment({
    required this.iconSvg,
    required this.name,
    required this.size
  });

  @override
  List<Object?> get props => [
    iconSvg,
    name,
    size
  ];
}