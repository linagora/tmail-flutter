import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/search_execution_context.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/search_execution_intent.dart';
import 'package:tmail_ui_user/features/search/email/domain/execution/search_request_spec.dart';
import 'package:tmail_ui_user/features/thread/domain/constants/thread_constants.dart';

void main() {
  final committed = SearchEmailFilter(sortOrderType: EmailSortOrderType.oldest);

  test('base() seeds filter from committed, default limit, no position', () {
    final ctx = SearchExecutionContext(
      intent: const NewSearchIntent(),
      committed: committed,
      collapseThreads: false,
    );

    final spec = SearchRequestSpec.base(ctx);

    expect(spec.filter, committed);
    expect(spec.limit, ThreadConstants.defaultLimit);
    expect(spec.position, isNull);
  });

  group('copyWith positionOption (set / keep / clear)', () {
    final base = SearchRequestSpec(
      filter: committed,
      position: 10,
      limit: ThreadConstants.defaultLimit,
    );

    test('null option keeps the current position', () {
      expect(base.copyWith().position, 10);
    });

    test('Some sets the position', () {
      expect(base.copyWith(positionOption: const Some(20)).position, 20);
    });

    test('None clears the position', () {
      expect(base.copyWith(positionOption: const None()).position, isNull);
    });

    test('changing position leaves filter and limit untouched', () {
      final updated = base.copyWith(positionOption: const Some(5));

      expect(updated.filter, committed);
      expect(updated.limit, ThreadConstants.defaultLimit);
    });
  });
}
