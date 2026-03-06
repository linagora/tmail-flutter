import 'package:jmap_dart_client/jmap/mail/email/search_snippet/search_snippet.dart';
import 'package:jmap_dart_client/jmap/thread/thread.dart';
import 'package:tmail_ui_user/features/thread/domain/extensions/list_search_snippet_extension.dart';
import 'package:tmail_ui_user/features/thread/domain/extensions/list_thread_extension.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_response.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_email.dart';

class SearchEmailsResponse extends EmailsResponse {
  const SearchEmailsResponse({
    super.emailList,
    super.state,
    required this.searchSnippets,
    this.threadLists,
  });

  final List<SearchSnippet>? searchSnippets;
  final List<Thread>? threadLists;

  @override
  List<Object?> get props => [...super.props, searchSnippets, threadLists];

  List<SearchEmail> get toSearchEmails {
    final emails = emailList;
    if (emails == null || emails.isEmpty) return [];

    final snippetMap = searchSnippets.toSnippetMap();
    final threadMap = threadLists.toThreadEmailIdsMap();

    return emails.map((email) {
      final snippet = snippetMap[email.id];

      return SearchEmail.fromEmail(
        email,
        searchSnippetSubject: snippet?.subject,
        searchSnippetPreview: snippet?.preview,
        emailIdsInThread: threadMap[email.threadId],
      );
    }).toList();
  }
}
