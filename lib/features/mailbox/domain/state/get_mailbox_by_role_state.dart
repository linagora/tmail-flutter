import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';

class GetMailboxByRoleLoading extends LoadingState {}

class GetMailboxByRoleSuccess extends UIState {
  final Mailbox mailbox;

  GetMailboxByRoleSuccess(this.mailbox);

  @override
  List<Object> get props => [mailbox];
}

class InvalidMailboxRole extends FeatureFailure {}

class GetMailboxByRoleFailure extends FeatureFailure {
  GetMailboxByRoleFailure(dynamic exception) : super(exception: exception);
}