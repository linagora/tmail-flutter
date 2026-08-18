import 'package:equatable/equatable.dart';

class WorkplaceActionConfig with EquatableMixin {
  final String? label;
  final num? maxFileSize;
  final num? availableSize;

  const WorkplaceActionConfig({
    this.label,
    this.maxFileSize,
    this.availableSize,
  });

  @override
  List<Object?> get props => [label, maxFileSize, availableSize];
}
