
import 'package:equatable/equatable.dart';

class ServicePath with EquatableMixin {
  final String path;

  ServicePath(this.path);

  @override
  List<Object?> get props => [path];
}