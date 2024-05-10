import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/push/state_change.dart';

class GetSessionLoading extends LoadingState {}

class GetSessionSuccess extends UIState {
  final Session session;
  final StateChange? stateChange;

  GetSessionSuccess(this.session, {this.stateChange});

  @override
  List<Object?> get props => [session, stateChange];
}

class GetSessionFailure extends FeatureFailure {

  GetSessionFailure(dynamic exception) : super(exception: exception);
}