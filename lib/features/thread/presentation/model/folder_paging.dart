import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/thread/domain/constants/thread_constants.dart';

/// Where the next page of a folder list starts.
sealed class FolderPageCursor {
  const FolderPageCursor();

  /// Server rows to skip, when paging by position.
  int? get position => null;

  /// Listed email whose `receivedAt` bounds the page, when paging by date.
  PresentationEmail? get oldestEmail => null;
}

final class FolderPageByPosition extends FolderPageCursor {
  const FolderPageByPosition(this.position);

  @override
  final int position;
}

/// A null [oldestEmail] means nothing is listed, so the page has no bound.
final class FolderPageByDate extends FolderPageCursor {
  const FolderPageByDate(this.oldestEmail);

  @override
  final PresentationEmail? oldestEmail;
}

/// How a folder list pages: where the next page starts, when the folder ends,
/// and which server rows match listed rows.
sealed class FolderPaging {
  /// Whether pages start at a row count from the top. Reloading the list from
  /// the top shifts that count, so a page requested meanwhile must wait.
  bool get pagesByPosition;

  FolderPageCursor cursorAfter(List<PresentationEmail> listed);

  /// Records a loaded page and returns whether the folder may hold more.
  bool pageLoaded({required int serverCount, required int appendedCount});

  /// The list is loaded again from the top.
  void reset();

  /// Server rows with a listed key are duplicates of listed rows.
  Object? rowKey(PresentationEmail email);
}

/// Collapsed threads page by position. A collapsed row stands for a whole
/// thread whose emails have different dates, so a date cursor would match
/// older emails of listed threads.
///
/// `position` = listed rows + server rows skipped since the list was last
/// loaded from the top. A skipped row is a duplicate of a listed thread
/// (pushed down by new threads above it) or an email that does not belong in
/// the list; either way it took a server slot.
final class FolderPagingByPosition extends FolderPaging {
  int _skippedRows = 0;

  @override
  bool get pagesByPosition => true;

  @override
  FolderPageCursor cursorAfter(List<PresentationEmail> listed) =>
      FolderPageByPosition(listed.length + _skippedRows);

  @override
  bool pageLoaded({required int serverCount, required int appendedCount}) {
    // The offset moves past every server row, appended or not, so a page of
    // duplicates still makes progress.
    _skippedRows += serverCount - appendedCount;
    return serverCount >= ThreadConstants.maxCountEmails;
  }

  @override
  void reset() => _skippedRows = 0;

  /// A collapsed row stands for its whole thread, so rows match by thread.
  @override
  Object? rowKey(PresentationEmail email) => email.threadId ?? email.id;
}

/// Uncollapsed lists page by date, which new emails on top cannot shift.
final class FolderPagingByDate extends FolderPaging {
  @override
  bool get pagesByPosition => false;

  @override
  FolderPageCursor cursorAfter(List<PresentationEmail> listed) =>
      FolderPageByDate(listed.lastOrNull);

  @override
  bool pageLoaded({required int serverCount, required int appendedCount}) {
    // Without an appended email the date cursor does not move, so another
    // request would repeat the same page forever.
    return appendedCount > 0 && serverCount >= ThreadConstants.maxCountEmails;
  }

  @override
  void reset() {}

  @override
  Object? rowKey(PresentationEmail email) => email.id;
}
