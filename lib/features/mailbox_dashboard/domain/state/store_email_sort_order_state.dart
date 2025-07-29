import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class StoringEmailSortOrder extends LoadingState {}

class StoreEmailSortOrderSuccess extends UIState {}

class StoreEmailSortOrderFailure extends FeatureFailure {

  StoreEmailSortOrderFailure(dynamic exception) : super(exception: exception);
}