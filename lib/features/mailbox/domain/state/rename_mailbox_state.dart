import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class LoadingRenameMailbox extends UIState {}

class RenameMailboxSuccess extends UIState {}

class RenameMailboxFailure extends FeatureFailure {

  RenameMailboxFailure(dynamic exception) : super(exception: exception);
}