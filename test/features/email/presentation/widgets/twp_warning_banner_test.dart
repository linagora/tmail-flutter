import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/twp_warning_banner.dart';

import '../../../../fixtures/widget_fixtures.dart';

TwpWarning _warning({
  TwpWarningLevel level = TwpWarningLevel.warn,
  String? code,
  String fallbackText = 'A fallback warning message',
  int index = 0,
}) => TwpWarning(
  level: level,
  code: code,
  fallbackText: fallbackText,
  index: index,
);

Widget _makeWidget(
  TwpWarning value, {
  bool isDismissable = true,
  void Function(int)? onDismiss,
}) {
  return WidgetFixtures.makeTestableWidget(
    child: TwpWarningBanner(
      warning: value,
      isDismissable: isDismissable,
      imagePaths: ImagePaths(),
      onDismissAction: onDismiss ?? (_) {},
    ),
  );
}

Finder _dismissButton(int index) =>
    find.byKey(Key('${UiKeys.twpWarningDismissButtonPrefix}$index'));

void main() {
  group('TwpWarningBanner', () {
    _messageTests();
    _dismissButtonTests();
  });
}

void _messageTests() {
  testWidgets('renders the server fallback text when the code is unknown', (
    tester,
  ) async {
    await tester.pumpWidget(
      _makeWidget(
        _warning(code: 'totally-unknown-code', fallbackText: 'Raw server text'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Raw server text'), findsOneWidget);
  });

  testWidgets('renders the localized message for a known code', (tester) async {
    await tester.pumpWidget(
      _makeWidget(_warning(code: 'virus', fallbackText: 'Raw server fallback')),
    );
    await tester.pumpAndSettle();

    // A known code resolves to the localized string, not the raw fallback.
    expect(find.text('Raw server fallback'), findsNothing);
  });
}

void _dismissButtonTests() {
  testWidgets('shows the dismiss button when dismissable', (tester) async {
    await tester.pumpWidget(_makeWidget(_warning(), isDismissable: true));
    await tester.pumpAndSettle();

    expect(_dismissButton(0), findsOneWidget);
  });

  testWidgets('hides the dismiss button when not dismissable', (tester) async {
    await tester.pumpWidget(_makeWidget(_warning(), isDismissable: false));
    await tester.pumpAndSettle();

    expect(_dismissButton(0), findsNothing);
  });

  testWidgets('invokes onDismissAction with the warning index on tap', (
    tester,
  ) async {
    int? dismissedIndex;
    await tester.pumpWidget(
      _makeWidget(
        _warning(index: 3),
        onDismiss: (index) => dismissedIndex = index,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(_dismissButton(3));
    await tester.pumpAndSettle();

    expect(dismissedIndex, 3);
  });
}
