import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/email/domain/model/detailed_email.dart';

class GetDetailedEmailByIdLoading extends UIState {}

class GetDetailedEmailByIdSuccess extends UIState {

  final Map<Email, DetailedEmail> mapDetailedEmail;
  final AccountId accountId;
  final Session session;

  GetDetailedEmailByIdSuccess(this.mapDetailedEmail, this.accountId, this.session);

  @override
  List<Object?> get props => [mapDetailedEmail, accountId, session];
}

class GetDetailedEmailByIdFailure extends FeatureFailure {

  GetDetailedEmailByIdFailure(dynamic exception) : super(exception: exception);
}