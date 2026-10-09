import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view_web.dart';

ComposerController? findWebComposerController(PatrolIntegrationTester $) {
  final widgets = $.tester
      .widgetList<ComposerView>(find.byType(ComposerView))
      .toList();
  if (widgets.isEmpty) return null;
  return widgets.first.controller;
}
