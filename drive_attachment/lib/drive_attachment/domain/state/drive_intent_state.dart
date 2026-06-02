import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:drive_attachment/drive_attachment/domain/entity/drive_intent.dart';

class CreatingDriveIntent extends LoadingState {}

class CreateDriveIntentSuccess extends UIState {
  final DriveIntent intent;
  CreateDriveIntentSuccess(this.intent);

  @override
  List<Object?> get props => [intent];
}

class CreateDriveIntentFailure extends FeatureFailure {
  CreateDriveIntentFailure(dynamic exception) : super(exception: exception);

  @override
  List<Object?> get props => [exception];
}

class ExchangingDriveToken extends LoadingState {}

class ExchangeDriveTokenSuccess extends UIState {
  final String accessToken;
  ExchangeDriveTokenSuccess(this.accessToken);

  @override
  List<Object?> get props => [accessToken];
}

class ExchangeDriveTokenFailure extends FeatureFailure {
  ExchangeDriveTokenFailure(dynamic exception) : super(exception: exception);

  @override
  List<Object?> get props => [exception];
}
