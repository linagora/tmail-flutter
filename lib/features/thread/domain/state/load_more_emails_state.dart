import 'package:core/core.dart';
import 'package:model/model.dart';

class LoadMoreEmailsSuccess extends UIState {
  final List<PresentationEmail> emailList;

  LoadMoreEmailsSuccess(this.emailList);

  @override
  List<Object?> get props => [emailList];
}

class LoadMoreEmailsFailure extends FeatureFailure {
  final dynamic exception;

  LoadMoreEmailsFailure(this.exception);

  @override
  List<Object> get props => [exception];
}