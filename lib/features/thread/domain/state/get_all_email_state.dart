import 'package:core/core.dart';
import 'package:model/model.dart';

class GetAllEmailSuccess extends UIState {
  final List<PresentationEmail> emailList;

  GetAllEmailSuccess(this.emailList);

  @override
  List<Object> get props => [emailList];
}

class GetAllEmailFailure extends FeatureFailure {
  final exception;

  GetAllEmailFailure(this.exception);

  @override
  List<Object> get props => [exception];
}