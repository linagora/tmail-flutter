import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';

class MarkAllSearchAsStarredLoading extends LoadingState {}

class MarkAllSearchAsStarredSuccess extends UIState {
  final List<EmailId> listEmailId;

  MarkAllSearchAsStarredSuccess(this.listEmailId);

  @override
  List<Object> get props => [listEmailId];
}

class MarkAllSearchAsStarredFailure extends FeatureFailure {

  MarkAllSearchAsStarredFailure(dynamic exception) : super(exception: exception);
}