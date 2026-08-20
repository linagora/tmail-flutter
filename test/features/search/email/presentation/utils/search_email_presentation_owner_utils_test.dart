import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/search/email/presentation/utils/search_email_presentation_owner_utils.dart';

class _WebDesktopResponsiveUtils extends ResponsiveUtils {
  @override
  bool isWebDesktop(BuildContext context) => true;
}

void main() {
  Future<BuildContext> pumpContext(WidgetTester tester) async {
    late BuildContext context;
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (buildContext) {
          context = buildContext;
          return const SizedBox();
        },
      ),
    ));
    return context;
  }

  test('defaults to SearchEmailView ownership without a context', () {
    expect(
      isSearchEmailPresentationLayoutOwner(
        context: null,
        responsiveUtils: ResponsiveUtils(),
      ),
      isTrue,
    );
  });

  testWidgets('keeps SearchEmailView ownership outside web desktop',
      (tester) async {
    final context = await pumpContext(tester);

    expect(
      isSearchEmailPresentationLayoutOwner(
        context: context,
        responsiveUtils: ResponsiveUtils(),
      ),
      isTrue,
    );
  });

  testWidgets('keeps the thread list as owner on web desktop', (tester) async {
    final context = await pumpContext(tester);

    expect(
      isSearchEmailPresentationLayoutOwner(
        context: context,
        responsiveUtils: _WebDesktopResponsiveUtils(),
      ),
      isFalse,
    );
  });
}
