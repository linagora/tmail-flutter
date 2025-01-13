import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';

class ParsingEmailByBlobId extends LoadingState {}

class ParseEmailByBlobIdSuccess extends UIState {

  final Email email;
  final Id blobId;

  ParseEmailByBlobIdSuccess(this.email, this.blobId);

  @override
  List<Object> get props => [email, blobId];
}

class ParseEmailByBlobIdFailure extends FeatureFailure {
  ParseEmailByBlobIdFailure(dynamic exception) : super(exception: exception);
}