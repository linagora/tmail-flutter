import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/account/personal_account.dart';

class GetSessionCacheLoading extends LoadingState {}

class GetSessionCacheSuccess extends UIState {
  final Session session;
  final PersonalAccount personalAccount;

  GetSessionCacheSuccess({
    required this.session,
    required this.personalAccount
  });

  @override
  List<Object?> get props => [session];
}

class GetSessionCacheFailure extends FeatureFailure {
  final PersonalAccount personalAccount;

  GetSessionCacheFailure({
    required this.personalAccount,
    dynamic exception
  }) : super(exception: exception);

  @override
  List<Object?> get props => [personalAccount, ...super.props];
}