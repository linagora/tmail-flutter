import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';

class SynchronizingLatestSession extends LoadingState {}

class SynchronizeLatestSessionSuccess extends UIState {
  final Session session;

  SynchronizeLatestSessionSuccess(this.session);

  @override
  List<Object?> get props => [session];
}

class SynchronizeLatestSessionFailure extends FeatureFailure {

  SynchronizeLatestSessionFailure(dynamic exception) : super(exception: exception);
}