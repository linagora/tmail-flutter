import 'package:dartz/dartz.dart';
import 'package:labels/model/label.dart';
import 'package:tmail_ui_user/features/search/email/presentation/search_email_controller.dart';

extension UpdateSearchFilterExtension on SearchEmailController {
  void deleteQuickSearchLabelFilter() {
    updateSimpleSearchFilter(labelOption: const None());
    searchEmailAction();
  }

  void onSelectLabelFilter(Label? newLabel) {
    updateSimpleSearchFilter(labelOption: optionOf(newLabel));
    searchEmailAction();
  }
}
