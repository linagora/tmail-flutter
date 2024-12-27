import 'package:equatable/equatable.dart';

class EmptyMailboxResponse with EquatableMixin {

  final bool isSuccess;
  final int deletedCount;

  EmptyMailboxResponse(this.isSuccess, this.deletedCount);

  @override
  List<Object?> get props => [isSuccess, deletedCount];

}