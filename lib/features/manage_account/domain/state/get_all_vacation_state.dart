import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/vacation/vacation_response.dart';

class LoadingGetAllVacation extends UIState {

  LoadingGetAllVacation();

  @override
  List<Object?> get props => [];
}

class GetAllVacationSuccess extends UIState {
  final List<VacationResponse>? listVacationResponse;

  GetAllVacationSuccess(this.listVacationResponse);

  @override
  List<Object?> get props => [listVacationResponse];
}

class GetAllVacationFailure extends FeatureFailure {
  final dynamic exception;

  GetAllVacationFailure(this.exception);

  @override
  List<Object> get props => [exception];
}