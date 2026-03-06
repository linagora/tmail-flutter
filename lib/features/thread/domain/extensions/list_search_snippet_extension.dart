import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/search_snippet/search_snippet.dart';

extension SearchSnippetExtension on List<SearchSnippet>? {
  Map<EmailId, SearchSnippet> toSnippetMap() {
    final snippets = this;
    if (snippets == null || snippets.isEmpty) return const {};
    return {for (final snippet in snippets) snippet.emailId: snippet};
  }
}
