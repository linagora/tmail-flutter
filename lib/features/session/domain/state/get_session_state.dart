import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';

class GetSessionLoading extends UIState {}

class GetSessionSuccess extends UIState {
  final Session session;

  GetSessionSuccess(this.session);

  @override
  List<Object> get props => [session];
}

class GetSessionFailure extends FeatureFailure {

  GetSessionFailure(dynamic exception) : super(exception: exception);

  @override
  List<Object?> get props => [exception];
}