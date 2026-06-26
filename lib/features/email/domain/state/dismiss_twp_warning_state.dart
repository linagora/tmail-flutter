import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';

class DismissTwpWarningSuccess extends UIState {
  DismissTwpWarningSuccess(this.emailId, this.index);

  final EmailId emailId;
  final int index;

  @override
  List<Object?> get props => [emailId, index];
}

class DismissTwpWarningFailure extends FeatureFailure {

  final int? index;

  DismissTwpWarningFailure({this.index, dynamic exception}) : super(exception: exception);
}
