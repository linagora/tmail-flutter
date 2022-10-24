import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class SaveRecentLoginUsernameSuccess extends UIState {
  
  SaveRecentLoginUsernameSuccess();

  @override
  List<Object> get props => [];
}

class SaveRecentLoginUsernameFailed extends FeatureFailure {
  final dynamic exception;

  SaveRecentLoginUsernameFailed(this.exception);
  
  @override
  List<Object?> get props => [exception];

}