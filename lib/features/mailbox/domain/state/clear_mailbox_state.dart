import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';

class ClearingMailbox extends LoadingState {}

class ClearMailboxSuccess extends UIState {
  final UnsignedInt totalDeletedMessages;

  ClearMailboxSuccess(this.totalDeletedMessages);

  @override
  List<Object> get props => [totalDeletedMessages];
}

class ClearMailboxFailure extends FeatureFailure {

  ClearMailboxFailure(dynamic exception) : super(exception: exception);
}