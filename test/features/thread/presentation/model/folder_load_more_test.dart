import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/email/presentation_email.dart';
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

        final token = loadMore.begin(const [], collapseThreads: false);

        expect(token, isNotNull);
        expect(loadMore.state, isA<FolderLoadMoreInFlight>());
        expect(loadMore.status, LoadingMoreStatus.running);
        expect(loadMore.accepts(token!.token), isTrue);
      });

      test('from idle with nothing more returns null', () {
        final loadMore = FolderLoadMore()..hasMore = false;

        expect(loadMore.begin(const [], collapseThreads: false), isNull);
        expect(loadMore.status, LoadingMoreStatus.idle);
      });

      test('while running returns null and keeps the running token', () {
        final loadMore = FolderLoadMore();
        final token = loadMore.begin(const [], collapseThreads: false)!.token;

        expect(loadMore.begin(const [], collapseThreads: false), isNull);
        expect(loadMore.accepts(token), isTrue);
      });

      test('while held returns null and records the request', () {
        final loadMore = FolderLoadMore()..holdForRefresh();

        expect(loadMore.begin(const [], collapseThreads: false), isNull);
        expect(loadMore.releaseAfterRefresh(), isTrue);
      });

      test('gives each request its own token', () {
        final loadMore = FolderLoadMore();
        final first = loadMore.begin(const [], collapseThreads: false)!.token;
        loadMore.pageLoaded(serverCount: pageSize, appendedCount: pageSize, collapseThreads: false);

        final second = loadMore.begin(const [], collapseThreads: false)!.token;

        expect(loadMore.accepts(first), isFalse);
        expect(loadMore.accepts(second), isTrue);
      });
    });

    group('pageLoaded', () {
      test('a full page with new emails completes with more to load', () {
        final loadMore = FolderLoadMore()..begin(const [], collapseThreads: false);

        loadMore.pageLoaded(serverCount: pageSize, appendedCount: pageSize, collapseThreads: false);

        expect(loadMore.status, LoadingMoreStatus.completed);
        expect(loadMore.hasMore, isTrue);
      });

      test('a short page ends the folder', () {
        final loadMore = FolderLoadMore()..begin(const [], collapseThreads: false);

        loadMore.pageLoaded(serverCount: pageSize - 1, appendedCount: pageSize - 1, collapseThreads: false);

        expect(loadMore.hasMore, isFalse);
      });

      test('a full page without new emails ends the folder', () {
        final loadMore = FolderLoadMore()..begin(const [], collapseThreads: false);

        loadMore.pageLoaded(serverCount: pageSize, appendedCount: 0, collapseThreads: false);

        expect(loadMore.hasMore, isFalse);
      });

      test('drops the running token', () {
        final loadMore = FolderLoadMore();
        final token = loadMore.begin(const [], collapseThreads: false)!.token;

        loadMore.pageLoaded(serverCount: pageSize, appendedCount: pageSize, collapseThreads: false);

        expect(loadMore.accepts(token), isFalse);
      });
    });

    test('pageFailed completes and allows a retry', () {
      final loadMore = FolderLoadMore()
        ..hasMore = false
        ..begin(const [], collapseThreads: false);

      loadMore.pageFailed();

      expect(loadMore.status, LoadingMoreStatus.completed);
      expect(loadMore.hasMore, isTrue);
    });

    group('abort', () {
      test('stops a running request and drops its token', () {
        final loadMore = FolderLoadMore();
        final token = loadMore.begin(const [], collapseThreads: false)!.token;

        loadMore.abort();

        expect(loadMore.status, LoadingMoreStatus.idle);
        expect(loadMore.accepts(token), isFalse);
      });

      test('keeps a completed status', () {
        final loadMore = FolderLoadMore()..begin(const [], collapseThreads: false);
        loadMore.pageLoaded(serverCount: pageSize, appendedCount: pageSize, collapseThreads: false);

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
      final token = loadMore.begin(const [], collapseThreads: false)!.token;
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
        final token = loadMore.begin(const [], collapseThreads: false)!.token;

        loadMore.holdForRefresh();

        expect(loadMore.accepts(token), isFalse);
        expect(loadMore.releaseAfterRefresh(), isTrue);
      });

      test('a second hold keeps what the first recorded', () {
        final loadMore = FolderLoadMore()..begin(const [], collapseThreads: false);
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
        expect(loadMore.begin(const [], collapseThreads: false), isNotNull);
      });

      test('without a hold changes nothing', () {
        final loadMore = FolderLoadMore();
        final token = loadMore.begin(const [], collapseThreads: false)!.token;

        expect(loadMore.releaseAfterRefresh(), isFalse);
        expect(loadMore.accepts(token), isTrue);
      });
    });

    group('paging', () {
      List<PresentationEmail> listed(int count) => List.generate(
            count,
            (i) => PresentationEmail(id: EmailId(Id('e$i'))),
          );

      test('by date starts after the oldest listed email', () {
        final emails = listed(3);

        final request = FolderLoadMore().begin(emails, collapseThreads: false)!;

        expect(request.oldestEmail, emails.last);
        expect(request.position, isNull);
      });

      test('by date with nothing listed has no bound', () {
        final request = FolderLoadMore().begin(const [], collapseThreads: false)!;

        expect(request.oldestEmail, isNull);
        expect(request.position, isNull);
      });

      test('collapsed starts after the listed rows', () {
        final request = FolderLoadMore().begin(listed(pageSize), collapseThreads: true)!;

        expect(request.position, pageSize);
        expect(request.oldestEmail, isNull);
      });

      test('collapsed moves past rows of a page that were not appended', () {
        final loadMore = FolderLoadMore()
          ..begin(listed(pageSize), collapseThreads: true);
        loadMore.pageLoaded(serverCount: pageSize, appendedCount: 15, collapseThreads: true);

        final request = loadMore.begin(listed(pageSize + 15), collapseThreads: true)!;

        expect(request.position, 2 * pageSize);
      });

      /// A collapsed list of one page whose next page held only listed rows.
      FolderLoadMore afterPageOfDuplicates() {
        return FolderLoadMore()
          ..begin(listed(pageSize), collapseThreads: true)
          ..pageLoaded(serverCount: pageSize, appendedCount: 0, collapseThreads: true);
      }

      int? nextPosition(FolderLoadMore loadMore) =>
          loadMore.begin(listed(pageSize), collapseThreads: true)!.position;

      test('collapsed keeps going after a page of duplicates only', () {
        final loadMore = afterPageOfDuplicates();

        expect(loadMore.hasMore, isTrue);
        expect(nextPosition(loadMore), 2 * pageSize);
      });

      test('collapsed ends on a short page', () {
        final loadMore = FolderLoadMore()
          ..begin(listed(pageSize), collapseThreads: true);

        loadMore.pageLoaded(serverCount: pageSize - 1, appendedCount: 0, collapseThreads: true);

        expect(loadMore.hasMore, isFalse);
      });

      test('collapsed counts from the listed rows again after a reset', () {
        final loadMore = afterPageOfDuplicates()..resetList();

        expect(nextPosition(loadMore), pageSize);
      });

      test('collapsed counts from the listed rows again after a refresh', () {
        final loadMore = afterPageOfDuplicates()
          ..holdForRefresh()
          ..releaseAfterRefresh();

        expect(nextPosition(loadMore), pageSize);
      });

      test('collapsed counts from the listed rows again once the list is loaded from the top', () {
        final loadMore = afterPageOfDuplicates()..listLoadedFromTop();

        expect(nextPosition(loadMore), pageSize);
      });

      test('a list loaded from the top keeps a refresh hold', () {
        final loadMore = FolderLoadMore()
          ..begin(listed(pageSize), collapseThreads: true)
          ..holdForRefresh();

        loadMore.listLoadedFromTop();

        expect(loadMore.state, isA<FolderLoadMoreDeferred>());
        expect(loadMore.releaseAfterRefresh(), isTrue);
      });

      test('a failed collapsed page does not move the offset', () {
        final loadMore = FolderLoadMore()
          ..begin(listed(pageSize), collapseThreads: true);

        loadMore.pageFailed();

        expect(
          loadMore.begin(listed(pageSize), collapseThreads: true)!.position,
          pageSize,
        );
      });
    });
  });
}
