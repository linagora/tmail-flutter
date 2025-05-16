import 'package:equatable/equatable.dart';

class TraceLog with EquatableMixin {
  final String path;
  final int size;
  final List<String> listFilePaths;

  TraceLog({
    required this.path,
    required this.size,
    required this.listFilePaths
  });

  @override
  List<Object?> get props => [path, size, listFilePaths];
}