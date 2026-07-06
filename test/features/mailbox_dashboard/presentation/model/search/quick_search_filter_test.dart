import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';

void main() {
  const me = 'me@example.com';

  // isSelected is pure logic but requires a BuildContext, so capture one.
  Future<bool> isFromMeSelected(
    WidgetTester tester,
    SearchEmailFilter filter, {
    String? currentUserEmail = me,
  }) async {
    late bool result;
    await tester.pumpWidget(Builder(
      builder: (context) {
        result = QuickSearchFilter.fromMe.isSelected(
          context,
          filter,
          EmailSortOrderType.relevance,
          currentUserEmail,
        );
        return const SizedBox.shrink();
      },
    ));
    return result;
  }

  group('QuickSearchFilter.fromMe.isSelected::test', () {
    testWidgets('SHOULD be selected WHEN from holds only the current user',
        (tester) async {
      final selected = await isFromMeSelected(
        tester,
        SearchEmailFilter(from: {me}),
      );

      expect(selected, isTrue);
    });

    testWidgets('SHOULD NOT be selected WHEN from holds the user plus others',
        (tester) async {
      final selected = await isFromMeSelected(
        tester,
        SearchEmailFilter(from: {me, 'other@example.com'}),
      );

      expect(selected, isFalse);
    });

    testWidgets('SHOULD NOT be selected WHEN from is empty', (tester) async {
      final selected = await isFromMeSelected(
        tester,
        SearchEmailFilter.initial(),
      );

      expect(selected, isFalse);
    });

    testWidgets('SHOULD NOT be selected WHEN the current user email is null',
        (tester) async {
      final selected = await isFromMeSelected(
        tester,
        SearchEmailFilter(from: {me}),
        currentUserEmail: null,
      );

      expect(selected, isFalse);
    });
  });
}
