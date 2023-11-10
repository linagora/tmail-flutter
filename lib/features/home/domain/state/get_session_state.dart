import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';

class GetSessionLoading extends LoadingState {}

class GetSessionSuccess extends UIState {
  final Session session;

  GetSessionSuccess(this.session);

  @override
  List<Object> get props => [session];
}

class GetSessionFailure extends FeatureFailure {

  GetSessionFailure(dynamic exception) : super(exception: exception);
}