import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';

class GetComposedEmailFromLocalStorageBrowserLoading extends LoadingState {}

class GetComposedEmailFromLocalStorageBrowserSuccess extends UIState {

  final Email email;

  GetComposedEmailFromLocalStorageBrowserSuccess(this.email);

  @override
  List<Object> get props => [email];
}

class GetComposedEmailFromLocalStorageBrowserFailure extends FeatureFailure {

  GetComposedEmailFromLocalStorageBrowserFailure(dynamic exception) : super(exception: exception);
}