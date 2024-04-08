
import 'package:flutter/cupertino.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap;
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/base/action/ui_action.dart';

class EmailUIAction extends UIAction {
  static final idle = EmailUIAction();

  EmailUIAction() : super();

  @override
  List<Object?> get props => [];
}

class RefreshChangeEmailAction extends EmailUIAction {
  final jmap.State? newState;

  RefreshChangeEmailAction(this.newState);

  @override
  List<Object?> get props => [newState];
}

class CloseEmailDetailedViewToRedirectToTheInboxAction extends EmailUIAction {}

class CloseEmailDetailedViewAction extends EmailUIAction {}

class PrintEmailAction extends EmailUIAction {

  final BuildContext context;
  final String userEmail;
  final PresentationEmail email;

  PrintEmailAction({
    required this.context,
    required this.userEmail,
    required this.email
  });

  @override
  List<Object?> get props => [context, userEmail, email];
}