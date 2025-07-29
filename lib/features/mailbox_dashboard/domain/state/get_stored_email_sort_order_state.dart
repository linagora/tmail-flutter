import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';

class GettingStoredEmailSortOrder extends LoadingState {}

class GetStoredEmailSortOrderSuccess extends UIState {
  final EmailSortOrderType emailSortOrderType;

  GetStoredEmailSortOrderSuccess(this.emailSortOrderType);

  @override
  List<Object?> get props => [emailSortOrderType];
}

class GetStoredEmailSortOrderFailure extends FeatureFailure {

  GetStoredEmailSortOrderFailure(dynamic exception) : super(exception: exception);
}