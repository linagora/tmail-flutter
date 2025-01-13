
import 'package:equatable/equatable.dart';

class PreviewAttachment with EquatableMixin {
  final String iconBase64Data;
  final String name;
  final String size;
  final String? link;

  PreviewAttachment({
    required this.iconBase64Data,
    required this.name,
    required this.size,
    this.link,
  });

  @override
  List<Object?> get props => [
    iconBase64Data,
    name,
    size,
    link,
  ];
}