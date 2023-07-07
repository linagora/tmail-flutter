
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;

class GetStoredEmailStateSuccess extends UIState {

  final jmap.State state;

  GetStoredEmailStateSuccess(this.state);

  @override
  List<Object> get props => [state];
}

class NotFoundEmailState extends FeatureFailure {}

class GetStoredEmailStateFailure extends FeatureFailure {

  GetStoredEmailStateFailure(dynamic exception) : super(exception: exception);
}