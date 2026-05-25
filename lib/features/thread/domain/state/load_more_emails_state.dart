import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:model/email/presentation_email.dart';

class LoadingMoreEmails extends LoadingState {}

class LoadMoreEmailsSuccess extends UIState {
  final List<PresentationEmail> emailList;
  final int serverEmailCount;

  LoadMoreEmailsSuccess(this.emailList, {required this.serverEmailCount});

  @override
  List<Object?> get props => [emailList, serverEmailCount];
}

class LoadMoreEmailsFailure extends FeatureFailure {

  LoadMoreEmailsFailure(dynamic exception) : super(exception: exception);
}