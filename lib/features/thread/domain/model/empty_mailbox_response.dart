import 'package:equatable/equatable.dart';

class EmptyMailboxResponse with EquatableMixin {

  final bool isSuccess;
  final int destroyedCount;
  final int notFoundCount;

  EmptyMailboxResponse(this.isSuccess, this.destroyedCount, this.notFoundCount);

  @override
  List<Object?> get props => [isSuccess, destroyedCount, notFoundCount];
}