import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:tmail_ui_user/features/login/domain/model/recent_login_username.dart';

class GetAllRecentLoginUsernameLatestSuccess extends UIState {

  final List<RecentLoginUsername> listRecentLoginUsername;

  GetAllRecentLoginUsernameLatestSuccess(this.listRecentLoginUsername);

  @override
  List<Object> get props => [listRecentLoginUsername];
}

class GetAllRecentLoginUsernameLatestFailure extends FeatureFailure {
  final dynamic exception;

  GetAllRecentLoginUsernameLatestFailure(this.exception);

  @override
  List<Object> get props => [exception];
}