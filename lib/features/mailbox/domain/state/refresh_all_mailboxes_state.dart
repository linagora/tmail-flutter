import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class RefreshingAllMailbox extends LoadingState {}

class RefreshAllMailboxSuccess extends UIState {}

class RefreshAllMailboxFailure extends FeatureFailure {

  RefreshAllMailboxFailure({dynamic exception}) : super(exception: exception);
}