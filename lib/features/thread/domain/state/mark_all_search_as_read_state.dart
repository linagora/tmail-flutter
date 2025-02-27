import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';

class MarkAllSearchAsReadLoading extends LoadingState {}

class MarkAllSearchAsReadSuccess extends UIState {
  final List<EmailId> listEmailId;

  MarkAllSearchAsReadSuccess(this.listEmailId);

  @override
  List<Object> get props => [listEmailId];
}

class MarkAllSearchAsReadFailure extends FeatureFailure {

  MarkAllSearchAsReadFailure(dynamic exception) : super(exception: exception);
}