import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class GettingCountUnreadEmailsInFolder extends LoadingState {}

class GetCountUnreadEmailsInFolderSuccess extends UIState {
  final int count;

  GetCountUnreadEmailsInFolderSuccess({required this.count});

  @override
  List<Object> get props => [count];
}

class GetCountUnreadEmailsInFolderFailure extends FeatureFailure {
  GetCountUnreadEmailsInFolderFailure(dynamic exception)
      : super(exception: exception);
}
