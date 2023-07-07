
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/email/presentation_email.dart';

class RefreshingChangeSearchEmailState extends UIState {}

class RefreshChangesSearchEmailSuccess extends UIState {
  final List<PresentationEmail> emailList;

  RefreshChangesSearchEmailSuccess(this.emailList);

  @override
  List<Object> get props => [emailList];
}

class RefreshChangesSearchEmailFailure extends FeatureFailure {

  RefreshChangesSearchEmailFailure(dynamic exception) : super(exception: exception);
}