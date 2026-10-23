import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/thread/domain/constants/thread_constants.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/folder_load_more.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/loading_more_status.dart';

void main() {
  const pageSize = ThreadConstants.maxCountEmails;

  group('FolderLoadMore', () {
    test('starts idle with more to load', () {
      final loadMore = FolderLoadMore();

      expect(loadMore.state, isA<FolderLoadMoreIdle>());
      expect(loadMore.status, LoadingMoreStatus.idle);
      expect(loadMore.hasMore, isTrue);
    });

    group('begin', () {
      test('from idle returns a token and runs', () {
        final loadMore = FolderLoadMore();

        final token = loadMore.begin();

        expect(token, isNotNull);
        expect(loadMore.state, isA<FolderLoadMoreInFlight>());
        expect(loadMore.status, LoadingMoreStatus.running);
        expect(loadMore.accepts(token!), isTrue);
      });

      test('from idle with nothing more returns null', () {
        final loadMore = FolderLoadMore()..hasMore = false;

        expect(loadMore.begin(), isNull);
        expect(loadMore.status, LoadingMoreStatus.idle);
      });

      test('while running returns null and keeps the running token', () {
        final loadMore = FolderLoadMore();
        final token = loadMore.begin()!;

        expect(loadMore.begin(), isNull);
        expect(loadMore.accepts(token), isTrue);
      });

      test('while held returns null and records the request', () {
        final loadMore = FolderLoadMore()..holdForRefresh();

        expect(loadMore.begin(), isNull);
        expect(loadMore.releaseAfterRefresh(), isTrue);
      });

      test('gives each request its own token', () {
        final loadMore = FolderLoadMore();
        final first = loadMore.begin()!;
        loadMore.pageLoaded(serverCount: pageSize, appendedCount: pageSize);

        final second = loadMore.begin()!;

        expect(loadMore.accepts(first), isFalse);
        expect(loadMore.accepts(second), isTrue);
      });
    });

    group('pageLoaded', () {
      test('a full page with new emails completes with more to load', () {
        final loadMore = FolderLoadMore()..begin();

        loadMore.pageLoaded(serverCount: pageSize, appendedCount: pageSize);

        expect(loadMore.status, LoadingMoreStatus.completed);
        expect(loadMore.hasMore, isTrue);
      });

      test('a short page ends the folder', () {
        final loadMore = FolderLoadMore()..begin();

        loadMore.pageLoaded(serverCount: pageSize - 1, appendedCount: pageSize - 1);

        expect(loadMore.hasMore, isFalse);
      });

      test('a full page without new emails ends the folder', () {
        final loadMore = FolderLoadMore()..begin();

        loadMore.pageLoaded(serverCount: pageSize, appendedCount: 0);

        expect(loadMore.hasMore, isFalse);
      });

      test('drops the running token', () {
        final loadMore = FolderLoadMore();
        final token = loadMore.begin()!;

        loadMore.pageLoaded(serverCount: pageSize, appendedCount: pageSize);

        expect(loadMore.accepts(token), isFalse);
      });
    });

    test('pageFailed completes and allows a retry', () {
      final loadMore = FolderLoadMore()
        ..hasMore = false
        ..begin();

      loadMore.pageFailed();

      expect(loadMore.status, LoadingMoreStatus.completed);
      expect(loadMore.hasMore, isTrue);
    });

    group('abort', () {
      test('stops a running request and drops its token', () {
        final loadMore = FolderLoadMore();
        final token = loadMore.begin()!;

        loadMore.abort();

        expect(loadMore.status, LoadingMoreStatus.idle);
        expect(loadMore.accepts(token), isFalse);
      });

      test('keeps a completed status', () {
        final loadMore = FolderLoadMore()..begin();
        loadMore.pageLoaded(serverCount: pageSize, appendedCount: pageSize);

        loadMore.abort();

        expect(loadMore.status, LoadingMoreStatus.completed);
      });

      test('keeps a hold', () {
        final loadMore = FolderLoadMore()..holdForRefresh();

        loadMore.abort();

        expect(loadMore.state, isA<FolderLoadMoreDeferred>());
      });
    });

    test('resetList drops the running token and goes idle, keeping hasMore', () {
      final loadMore = FolderLoadMore()..hasMore = true;
      final token = loadMore.begin()!;
      loadMore.hasMore = false;

      loadMore.resetList();

      expect(loadMore.status, LoadingMoreStatus.idle);
      expect(loadMore.accepts(token), isFalse);
      expect(loadMore.hasMore, isFalse);
    });

    group('holdForRefresh', () {
      test('from idle holds with nothing pending', () {
        final loadMore = FolderLoadMore()..holdForRefresh();

        expect(loadMore.status, LoadingMoreStatus.idle);
        expect(loadMore.releaseAfterRefresh(), isFalse);
      });

      test('while running drops the token and records the dropped request', () {
        final loadMore = FolderLoadMore();
        final token = loadMore.begin()!;

        loadMore.holdForRefresh();

        expect(loadMore.accepts(token), isFalse);
        expect(loadMore.releaseAfterRefresh(), isTrue);
      });

      test('a second hold keeps what the first recorded', () {
        final loadMore = FolderLoadMore()..begin();
        loadMore.holdForRefresh();

        loadMore.holdForRefresh();

        expect(loadMore.releaseAfterRefresh(), isTrue);
      });
    });

    group('releaseAfterRefresh', () {
      test('goes idle and allows a new request', () {
        final loadMore = FolderLoadMore()..holdForRefresh();

        loadMore.releaseAfterRefresh();

        expect(loadMore.status, LoadingMoreStatus.idle);
        expect(loadMore.begin(), isNotNull);
      });

      test('without a hold changes nothing', () {
        final loadMore = FolderLoadMore();
        final token = loadMore.begin()!;

        expect(loadMore.releaseAfterRefresh(), isFalse);
        expect(loadMore.accepts(token), isTrue);
      });
    });
  });
}
