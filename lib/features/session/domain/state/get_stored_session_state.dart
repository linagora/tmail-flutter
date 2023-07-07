import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';

class GetStoredSessionLoading extends UIState {}

class GetStoredSessionSuccess extends UIState {

  final Session session;

  GetStoredSessionSuccess(this.session);

  @override
  List<Object?> get props => [session];
}

class GetStoredSessionFailure extends FeatureFailure {

  GetStoredSessionFailure(dynamic exception) : super(exception: exception);
}