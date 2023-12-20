import 'package:core/presentation/utils/keyboard_utils.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/base/mixin/date_range_picker_mixin.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/controller/input_field_focus_manager.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/model/email_recovery_field.dart';
import 'package:tmail_ui_user/features/email_recovery/presentation/model/email_recovery_time_type.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class EmailRecoveryController extends BaseController with DateRangePickerMixin {

  final deletionDateFieldSelected = EmailRecoveryTimeType.last1Year.obs;
  final receptionDateFieldSelected = EmailRecoveryTimeType.allTime.obs;
  final startDeletionDate = Rxn<DateTime>();
  final endDeletionDate = Rxn<DateTime>();
  final startReceptionDate = Rxn<DateTime>();
  final endReceptionDate = Rxn<DateTime>();
  final focusManager = InputFieldFocusManager.initial();

  List<EmailAddress> listRecipients = <EmailAddress>[];
  List<EmailAddress> listSenders = <EmailAddress>[];

  EmailRecoveryController();

  void onSelectDeletionDateRange(BuildContext context) {
    showMultipleViewDateRangePicker(
      context,
      startDeletionDate.value,
      endDeletionDate.value,
      onCallbackAction: (startDate, endDate) {
        _updateDateRangeTime(
          EmailRecoveryField.deletionDate,
          EmailRecoveryTimeType.customRange,
          startDate: startDate,
          endDate: endDate,
        );
      }
    );
  }

  void onSelectReceptionDateRange(BuildContext context) {
    showMultipleViewDateRangePicker(
      context,
      startReceptionDate.value,
      endReceptionDate.value,
      onCallbackAction: (startDate, endDate) {
        _updateDateRangeTime(
          EmailRecoveryField.receptionDate,
          EmailRecoveryTimeType.customRange,
          startDate: startDate,
          endDate: endDate,
        );
      }
    );
  }

  void _updateDateRangeTime(
    EmailRecoveryField field,
    EmailRecoveryTimeType recoveryTimeType,
    {
      DateTime? startDate,
      DateTime? endDate,
    }
  ) {
    if (field == EmailRecoveryField.deletionDate) {
      deletionDateFieldSelected.value = recoveryTimeType;
      startDeletionDate.value = startDate;
      endDeletionDate.value = endDate;
    } else {
      receptionDateFieldSelected.value = recoveryTimeType;
      startReceptionDate.value = startDate;
      endReceptionDate.value = endDate;
    }
  }

  void onDeletionDateTypeSelected(BuildContext context, EmailRecoveryTimeType type) {
    if (type == EmailRecoveryTimeType.customRange) {
      onSelectDeletionDateRange(context);
    } else {
      _updateDateRangeTime(
        EmailRecoveryField.deletionDate,
        type,
        startDate: type.toLatestUTCDate()?.value,
        endDate: DateTime.now(),
      );
    }
  }

  void onReceptionDateTypeSelected(BuildContext context, EmailRecoveryTimeType type) {
    if (type == EmailRecoveryTimeType.customRange) {
      onSelectReceptionDateRange(context);
    } else {
      _updateDateRangeTime(
        EmailRecoveryField.receptionDate,
        type,
      );
    }
  }

  void closeView(BuildContext context) {
    KeyboardUtils.hideKeyboard(context);
    popBack();
  }
}