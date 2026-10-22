import 'package:model/email/presentation_email.dart';

/// Where a folder load-more request resumes after the listed emails.
class LoadMoreCursor {
  /// Number of listed rows the next page skips, when paging by offset.
  final int? position;

  /// Listed email whose `receivedAt` bounds the next page, when paging by date.
  final PresentationEmail? oldestEmail;

  const LoadMoreCursor._({this.position, this.oldestEmail});

  /// A collapsed row stands for a whole thread whose emails have different
  /// `receivedAt`, so a date cursor from the oldest row would match earlier
  /// emails of threads already listed. Collapsed lists page by offset instead.
  /// Other lists page by date, which new emails arriving on top cannot shift.
  factory LoadMoreCursor.after(
    List<PresentationEmail> listedEmails, {
    required bool collapseThreads,
    int positionBias = 0,
  }) {
    if (collapseThreads) {
      return LoadMoreCursor._(position: listedEmails.length + positionBias);
    }
    return LoadMoreCursor._(oldestEmail: listedEmails.lastOrNull);
  }

  /// Whether a collapsed load-more page came back full but held only rows
  /// already listed. An offset assumes the listed rows are still the first
  /// rows on the server; new threads added above them since they were loaded
  /// shift the server rows down, so the page repeats the listed ones.
  static bool isOverlappingCollapsedPage({
    required bool collapseThreads,
    required int serverEmailCount,
    required int appendableEmailCount,
    required int pageSize,
  }) {
    return collapseThreads &&
        appendableEmailCount == 0 &&
        serverEmailCount >= pageSize;
  }
}
