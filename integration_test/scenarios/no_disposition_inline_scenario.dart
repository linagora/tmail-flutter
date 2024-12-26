import 'package:core/presentation/views/html_viewer/html_content_viewer_widget.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/email/presentation/email_view.dart';

import '../base/base_scenario.dart';
import '../robots/search_robot.dart';
import '../robots/thread_robot.dart';
import 'login_with_basic_auth_scenario.dart';

class NoDispositionInlineScenario extends BaseScenario {
  NoDispositionInlineScenario(
    super.$, {
    required this.loginWithBasicAuthScenario,
  });

  final LoginWithBasicAuthScenario loginWithBasicAuthScenario;

  @override
  Future<void> execute() async {
    final threadRobot = ThreadRobot($);
    final searchRobot = SearchRobot($);
    
    await loginWithBasicAuthScenario.execute();

    await threadRobot.openSearchView();
    await searchRobot.enterQueryString('Greeting Card');
    await $.pumpAndTrySettle();
    await threadRobot.openEmailWithSubject('Greeting');
    await $.pumpAndTrySettle();
    _expectEmailViewWithBase64Image(_base64);
  }

  void _expectEmailViewWithBase64Image(String base64) {
    expect(
      $(EmailView)
        .$(HtmlContentViewer)
        .which<HtmlContentViewer>((view) => view.contentHtml.contains(base64)),
      findsOneWidget,
    );
  }

  static const _base64 = '''/9j/4AAQSkZJRgABAQAAAQABAAD/4gIoSUNDX1BST0ZJTEUAAQEAAAIYAAAAAAQwAABtbnRyUkdCIFhZWiAAAAAAAAAAAAAAAABhY3NwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAA9tYAAQAAAADTLQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAlkZXNjAAAA8AAAAHRyWFlaAAABZAAAABRnWFlaAAABeAAAABRiWFlaAAABjAAAABRyVFJDAAABoAAAAChnVFJDAAABoAAAAChiVFJDAAABoAAAACh3dHB0AAAByAAAABRjcHJ0AAAB3AAAADxtbHVjAAAAAAAAAAEAAAAMZW5VUwAAAFgAAAAcAHMAUgBHAEIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAFhZWiAAAAAAAABvogAAOPUAAAOQWFlaIAAAAAAAAGKZAAC3hQAAGNpYWVogAAAAAAAAJKAAAA+EAAC2z3BhcmEAAAAAAAQAAAACZmYAAPKnAAANWQAAE9AAAApbAAAAAAAAAABYWVogAAAAAAAA9tYAAQAAAADTLW1sdWMAAAAAAAAAAQAAAAxlblVTAAAAIAAAABwARwBvAG8AZwBsAGUAIABJAG4AYwAuACAAMgAwADEANv/bAEMAEAsMDgwKEA4NDhIREBM''';
}