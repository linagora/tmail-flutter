import 'package:equatable/equatable.dart';

class Status with EquatableMixin {
  static final waiting = Status('waiting');
  static final inProgress = Status('inProgress');
  static final completed = Status('completed');
  static final failed = Status('failed');
  static final canceled = Status('canceled');
  
  final String value;

  Status(this.value);

  @override
  List<Object?> get props => [value];
}