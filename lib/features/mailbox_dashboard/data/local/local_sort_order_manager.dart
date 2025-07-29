import 'package:core/utils/app_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';

class LocalSortOrderManager {
  static const String _emailSortOrderKey = 'email.sort_order';

  final SharedPreferences _sharedPreferences;

  LocalSortOrderManager(this._sharedPreferences);

  Future<bool> storeEmailSortOrder(
    EmailSortOrderType emailSortOrderType,
  ) async {
    return await _sharedPreferences.setString(
      _emailSortOrderKey,
      emailSortOrderType.name,
    );
  }

  bool isEmailSortOrderStored(EmailSortOrderType emailSortOrderType) {
    final stored = _sharedPreferences.getString(_emailSortOrderKey);
    return stored == emailSortOrderType.name;
  }

  Future<bool> storeEmailSortOrderIfChanged(
    EmailSortOrderType emailSortOrderType,
  ) async {
    if (isEmailSortOrderStored(emailSortOrderType)) {
      return false;
    }
    return await storeEmailSortOrder(emailSortOrderType);
  }

  EmailSortOrderType getStoredEmailSortOrder() {
    final value = _sharedPreferences.getString(_emailSortOrderKey);
    log('LocalSortOrderManager::getStoredEmailSortOrder: $value');
    if (value == null) {
      return SearchEmailFilter.defaultSortOrder;
    }
    return EmailSortOrderType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SearchEmailFilter.defaultSortOrder,
    );
  }
}
