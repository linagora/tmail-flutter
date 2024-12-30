import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/rename_mailbox_request.dart';

class LoadingRenameMailbox extends UIState {}

class RenameMailboxSuccess extends UIState {
  RenameMailboxSuccess({required this.request});

  final RenameMailboxRequest request;

  @override
  List<Object> get props => [request];
}

class RenameMailboxFailure extends FeatureFailure {

  RenameMailboxFailure(dynamic exception) : super(exception: exception);
}