import 'package:jmap_dart_client/jmap/mail/email/search_snippet/search_snippet.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_response.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_email.dart';

class SearchEmailsResponse extends EmailsResponse {
  const SearchEmailsResponse({
    super.emailList,
    super.state,
    required this.searchSnippets,
  });

  final List<SearchSnippet>? searchSnippets;

  @override
  List<Object?> get props => [...super.props, searchSnippets];

  List<SearchEmail>? get toSearchEmails {
    if (searchSnippets == null) {
      return emailList?.map(SearchEmail.fromEmail).toList();
    }

    final mapSearchSnippet = Map.fromEntries(
      searchSnippets!.map((searchSnippet) => MapEntry(
        searchSnippet.emailId,
        searchSnippet)));

    return emailList?.map((email) {
      final searchSnippet = mapSearchSnippet[email.id];
      return SearchEmail.fromEmail(
        email,
        searchSnippetSubject: searchSnippet?.subject,
        searchSnippetPreview: searchSnippet?.preview);
    }).toList();
  }
}