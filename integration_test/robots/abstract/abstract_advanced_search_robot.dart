import 'package:tmail_ui_user/features/base/model/filter_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';

abstract class AbstractAdvancedSearchRobot {
  Future<void> closeAdvancedSearch();
  Future<void> tapSearchButton();
  Future<void> expectHasAttachmentChecked(bool checked);
  Future<void> enterFromEmail(String email);
  Future<void> expectFromFieldContains(String email);
  Future<void> removeFromEmailTag(String email);
  Future<void> expectFromFieldEmpty();
  Future<void> expectReceiveTimeSelected(EmailReceiveTimeType receiveTimeType);
  Future<void> focusField(FilterField filterField);
}
