
import 'package:core/core.dart';
import 'package:model/email/presentation_email.dart';

class RefreshingChangeSearchEmailState extends UIState {

  RefreshingChangeSearchEmailState();

  @override
  List<Object> get props => [];
}

class RefreshChangesSearchEmailSuccess extends UIState {
  final List<PresentationEmail> emailList;

  RefreshChangesSearchEmailSuccess(this.emailList);

  @override
  List<Object> get props => [emailList];
}

class RefreshChangesSearchEmailFailure extends FeatureFailure {
  final dynamic exception;

  RefreshChangesSearchEmailFailure(this.exception);

  @override
  List<Object> get props => [exception];
}