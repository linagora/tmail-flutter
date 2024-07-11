import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';

class UpdatingAccountCache extends LoadingState {}

class UpdateAccountCacheSuccess extends UIState {
  final Session session;
  final String apiUrl;

  UpdateAccountCacheSuccess({
    required this.session,
    required this.apiUrl});

  @override
  List<Object?> get props => [session, apiUrl];
}

class UpdateAccountCacheFailure extends FeatureFailure {

  UpdateAccountCacheFailure(dynamic exception) : super(exception: exception);
}