import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class SaveRecentLoginUrlSuccess extends UIState {
  
  SaveRecentLoginUrlSuccess();

  @override
  List<Object> get props => [];
}

class SaveRecentLoginUrlFailed extends FeatureFailure {
  final dynamic exception;

  SaveRecentLoginUrlFailed(this.exception);
  
  @override
  List<Object?> get props => [exception];

}