import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/vacation/vacation_response.dart';

class LoadingUpdateVacation extends UIState {}

class UpdateVacationSuccess extends UIState {
  final List<VacationResponse> listVacationResponse;

  UpdateVacationSuccess(this.listVacationResponse);

  @override
  List<Object?> get props => [listVacationResponse];
}

class UpdateVacationFailure extends FeatureFailure {

  UpdateVacationFailure(exception) : super(exception: exception);
}