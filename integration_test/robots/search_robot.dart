import 'package:core/presentation/views/text/text_field_builder.dart';
import 'package:tmail_ui_user/features/search/email/presentation/search_email_view.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../base/core_robot.dart';

class SearchRobot extends CoreRobot {
  SearchRobot(super.$);

  Future<void> enterKeyword(String keyword) async {
    await $(SearchEmailView).$(TextFieldBuilder).enterText(keyword);
  }
  
  Future<void> tapOnShowAllResultsText() async {
    await ensureViewVisible($(AppLocalizations().showingResultsFor));
    await $(AppLocalizations().showingResultsFor).tap();
  }
}