import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/collapsed_folder_pager.dart';

const _pageSize = 20;
const _cap = 500;

CollapsedOverlapDecision _overlapping(
  CollapsedFolderPager pager,
  int listedCount,
) {
  return pager.onOverlappingPage(listedCount, cap: _cap, pageSize: _pageSize);
}

void main() {
  _onOverlappingPageTests();
  _resyncFailureTests();
  _replaceTests();
  _onRowsAppendedTests();
}

void _onOverlappingPageTests() {
  group('CollapsedFolderPager.onOverlappingPage', () {
    test('GIVEN the pager is idle '
        'WHEN an overlapping page arrives below the cap '
        'THEN it SHOULD resync', () {
      final pager = CollapsedFolderPager();

      expect(_overlapping(pager, 20), CollapsedOverlapDecision.resync);
      expect(pager.policy, isA<CollapsedOverlapResynced>());
    });

    test('GIVEN the list was already resynced at this size '
        'WHEN another overlapping page arrives '
        'THEN it SHOULD stop', () {
      final pager = CollapsedFolderPager();
      _overlapping(pager, 20);

      expect(_overlapping(pager, 20), CollapsedOverlapDecision.stop);
    });

    test('GIVEN listed threads have reached the cap '
        'WHEN an overlapping page arrives '
        'THEN it SHOULD continue from a bumped offset', () {
      final pager = CollapsedFolderPager();

      expect(
        _overlapping(pager, _cap),
        CollapsedOverlapDecision.continueWithBias,
      );
      expect(pager.positionBias, _pageSize);
    });
  });
}

void _resyncFailureTests() {
  group('CollapsedFolderPager resync failure', () {
    test('GIVEN a resync failed once at this size '
        'WHEN another overlapping page arrives '
        'THEN it SHOULD retry', () {
      final pager = CollapsedFolderPager();
      _overlapping(pager, 20);
      pager.onResyncFailed(20);

      expect(pager.policy, const CollapsedOverlapFailedOnce(20));
      expect(_overlapping(pager, 20), CollapsedOverlapDecision.resync);
    });

    test('GIVEN a resync already failed once at this size '
        'WHEN it fails again '
        'THEN it SHOULD give up AND later overlapping pages SHOULD stop', () {
      final pager = CollapsedFolderPager();
      _overlapping(pager, 20);
      pager.onResyncFailed(20);
      _overlapping(pager, 20);
      pager.onResyncFailed(20);

      expect(pager.policy, isA<CollapsedOverlapGivenUp>());
      expect(_overlapping(pager, 20), CollapsedOverlapDecision.stop);
    });
  });
}

void _replaceTests() {
  group('CollapsedFolderPager.replace', () {
    test('GIVEN the pager has given up '
        'WHEN it is replaced keeping give-up '
        'THEN the new pager SHOULD keep give-up with a new token', () {
      final pager = CollapsedFolderPager();
      _overlapping(pager, 20);
      pager.onResyncFailed(20);
      _overlapping(pager, 20);
      pager.onResyncFailed(20);
      final token = pager.token;

      final next = pager.replace(keepGiveUp: true);

      expect(next.token, isNot(token));
      expect(pager.isCurrent(token), isTrue);
      expect(next.isCurrent(token), isFalse);
      expect(next.policy, isA<CollapsedOverlapGivenUp>());
      expect(next.positionBias, 0);
      expect(_overlapping(next, 20), CollapsedOverlapDecision.stop);
    });

    test('GIVEN the pager has given up '
        'WHEN it is replaced without keeping give-up '
        'THEN the new pager SHOULD resync again', () {
      final pager = CollapsedFolderPager();
      _overlapping(pager, 20);
      pager.onResyncFailed(20);
      _overlapping(pager, 20);
      pager.onResyncFailed(20);

      final next = pager.replace(keepGiveUp: false);

      expect(next.policy, isA<CollapsedOverlapIdle>());
      expect(_overlapping(next, 20), CollapsedOverlapDecision.resync);
    });

    test('GIVEN load-more was claimed '
        'WHEN the pager is replaced '
        'THEN the new pager SHOULD not own that load-more', () {
      final pager = CollapsedFolderPager();
      pager.claimLoadMore();

      final next = pager.replace(keepGiveUp: true);

      expect(pager.isLoadMoreOwner, isTrue);
      expect(next.isLoadMoreOwner, isFalse);
    });
  });
}

void _onRowsAppendedTests() {
  group('CollapsedFolderPager.onRowsAppended', () {
    test('GIVEN the list was resynced at this size '
        'WHEN rows are appended '
        'THEN an overlapping page at the new size SHOULD resync', () {
      final pager = CollapsedFolderPager();
      _overlapping(pager, 20);
      pager.onRowsAppended();

      expect(_overlapping(pager, 40), CollapsedOverlapDecision.resync);
    });
  });
}
