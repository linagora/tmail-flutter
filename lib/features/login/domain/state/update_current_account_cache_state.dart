import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';

class UpdateCurrentAccountCacheLoading extends LoadingState {}

class UpdateCurrentAccountCacheSuccess extends UIState {
  final Session session;
  final String apiUrl;

  UpdateCurrentAccountCacheSuccess({required this.session, required this.apiUrl});

  @override
  List<Object?> get props => [session, apiUrl];
}

class UpdateCurrentAccountCacheFailure extends FeatureFailure {

  UpdateCurrentAccountCacheFailure(dynamic exception) : super(exception: exception);
}