import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';

class GetSessionSuccess extends UIState {
  final Session session;

  GetSessionSuccess(this.session);

  @override
  List<Object> get props => [session];
}

class GetSessionFailure extends FeatureFailure {
  final exception;

  GetSessionFailure(this.exception);

  @override
  List<Object> get props => [exception];
}