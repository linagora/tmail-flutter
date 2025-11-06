import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';

class ParsingEmailByBlobId extends LoadingState {}

class ParseEmailByBlobIdSuccess extends UIState {
  final AccountId accountId;
  final Session session;
  final String ownEmailAddress;
  final Email email;
  final Id blobId;

  ParseEmailByBlobIdSuccess({
    required this.email,
    required this.blobId,
    required this.accountId,
    required this.session,
    required this.ownEmailAddress,
  });

  @override
  List<Object?> get props => [
        email,
        blobId,
        accountId,
        session,
        ownEmailAddress,
      ];
}

class ParseEmailByBlobIdFailure extends FeatureFailure {
  ParseEmailByBlobIdFailure(dynamic exception) : super(exception: exception);
}
