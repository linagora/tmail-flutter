import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:tmail_ui_user/features/login/domain/model/recent_login_url.dart';

class GetAllRecentLoginUrlLatestSuccess extends UIState {

  final List<RecentLoginUrl> listRecentLoginUrl;

  GetAllRecentLoginUrlLatestSuccess(this.listRecentLoginUrl);

  @override
  List<Object> get props => [listRecentLoginUrl];
}

class GetAllRecentLoginUrlLatestFailure extends FeatureFailure {
  final dynamic exception;

  GetAllRecentLoginUrlLatestFailure(this.exception);

  @override
  List<Object> get props => [exception];
}