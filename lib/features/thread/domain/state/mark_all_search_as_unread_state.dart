import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';

class MarkAllSearchAsUnreadLoading extends LoadingState {}

class MarkAllSearchAsUnreadSuccess extends UIState {
  final List<EmailId> listEmailId;

  MarkAllSearchAsUnreadSuccess(this.listEmailId);

  @override
  List<Object> get props => [listEmailId];
}

class MarkAllSearchAsUnreadFailure extends FeatureFailure {

  MarkAllSearchAsUnreadFailure(dynamic exception) : super(exception: exception);
}