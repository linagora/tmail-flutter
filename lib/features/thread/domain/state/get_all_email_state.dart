import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:model/email/presentation_email.dart';

class RefreshAllEmailLoading extends LoadingState {}

class GetAllEmailLoading extends LoadingState {}

class GetAllEmailSuccess extends UIState {
  final List<PresentationEmail> emailList;
  final State? currentEmailState;

  GetAllEmailSuccess({required this.emailList, this.currentEmailState});

  @override
  List<Object?> get props => [emailList, currentEmailState];
}

class GetAllEmailFailure extends FeatureFailure {

  GetAllEmailFailure(dynamic exception) : super(exception: exception);
}