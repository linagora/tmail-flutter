import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

import '../base/base_scenario.dart';
import '../models/provisioning_email.dart';
import '../robots/search_robot.dart';
import '../robots/thread_robot.dart';
import '../utils/scenario_utils_mixin.dart';
import 'login_with_basic_auth_scenario.dart';

class SearchResultHighlightsScenario extends BaseScenario with ScenarioUtilsMixin {
  SearchResultHighlightsScenario(
    super.$, {
    required this.loginWithBasicAuthScenario,
    required this.keyword,
    required this.longEmailContents,
  });

  final LoginWithBasicAuthScenario loginWithBasicAuthScenario;
  final String keyword;
  final List<String> longEmailContents;

  @override
  Future<void> execute() async {
    // Robots
    final threadRobot = ThreadRobot($);
    final searchRobot = SearchRobot($);

    // Login
    await loginWithBasicAuthScenario.execute();

    // Prepare attachment file
    final file = await preparingTxtFile(keyword);

    // Provisioning some emails
    await provisionEmail(longEmailContents
      .map(
        (emailContent) => ProvisioningEmail(
          toEmail: loginWithBasicAuthScenario.email,
          subject: keyword,
          content: emailContent,
          attachmentPaths: emailContent == longEmailContents.first
            ? [file.path]
            : [],
        ),
      )
      .toList());
    await $.pumpAndSettle();

    // Search
    await threadRobot.tapOnSearchField();
    await searchRobot.enterKeyword(keyword);
    await searchRobot.tapOnShowAllResultsText();
    await $.pump(const Duration(seconds: 5));
    expect($(RichTextBuilder).$(keyword).hitTestable().evaluate().length, 6);
  }
}