import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';

class DeleteAllPermanentlyEmailsLoading extends LoadingState {}

class DeleteAllPermanentlyEmailsUpdating extends UIState {

  final int total;
  final int countDeleted;

  DeleteAllPermanentlyEmailsUpdating({
    required this.total,
    required this.countDeleted
  });

  @override
  List<Object?> get props => [total, countDeleted];
}

class DeleteAllPermanentlyEmailsSuccess extends UIState {

  final List<EmailId> emailIds;

  DeleteAllPermanentlyEmailsSuccess( this.emailIds);

  @override
  List<Object?> get props => [emailIds];
}

class DeleteAllPermanentlyEmailsFailure extends FeatureFailure {

  DeleteAllPermanentlyEmailsFailure(dynamic exception) : super(exception: exception);
}