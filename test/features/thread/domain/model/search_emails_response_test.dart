import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/search_snippet/search_snippet.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_email.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_emails_response.dart';

void main() {
  group('search emails response test:', () {
    test(
      'should return list of search emails '
      'when toSearchEmails is called',
    () {
      // arrange
      final emailId = EmailId(Id('someId'));
      const searchSnippetSubject = 'search-snippet-subject';
      const searchSnippetPreview = 'search-snippet-preview';
      final email = Email(id: emailId);
      final searchSnippet = SearchSnippet(
        emailId: emailId,
        subject: searchSnippetSubject,
        preview: searchSnippetPreview,
      );
      final searchEmailsResponse = SearchEmailsResponse(
        emailList: [email],
        searchSnippets: [searchSnippet],
      );
      
      // act
      final result = searchEmailsResponse.toSearchEmails;
      
      // assert
      expect(
        result,
        [SearchEmail(
          id: emailId,
          searchSnippetSubject: searchSnippetSubject,
          searchSnippetPreview: searchSnippetPreview)]
      );
    });

    test(
      'should map list of search emails according to emailId '
      'when toSearchEmails is called',
    () {
      // arrange
      final emailId1 = EmailId(Id('someId1'));
      final emailId2 = EmailId(Id('someId2'));
      const searchSnippetSubject1 = 'search-snippet-subject-1';
      const searchSnippetPreview1 = 'search-snippet-preview-1';
      const searchSnippetSubject2 = 'search-snippet-subject-2';
      const searchSnippetPreview2 = 'search-snippet-preview-2';
      final email1 = Email(id: emailId1, subject: 'subject-1');
      final searchSnippet1 = SearchSnippet(
        emailId: emailId1,
        subject: searchSnippetSubject1,
        preview: searchSnippetPreview1,
      );
      final email2 = Email(id: emailId2, subject: 'subject-2');
      final searchSnippet2 = SearchSnippet(
        emailId: emailId2,
        subject: searchSnippetSubject2,
        preview: searchSnippetPreview2,
      );
      final searchEmailsResponse = SearchEmailsResponse(
        emailList: [email1, email2],
        searchSnippets: [searchSnippet1, searchSnippet2],
      );
      
      // act
      final result = searchEmailsResponse.toSearchEmails;
      
      // assert
      expect(
        result,
        [
          SearchEmail(
            id: emailId1,
            subject: email1.subject,
            searchSnippetSubject: searchSnippetSubject1,
            searchSnippetPreview: searchSnippetPreview1,
          ),
          SearchEmail(
            id: emailId2,
            subject: email2.subject,
            searchSnippetSubject: searchSnippetSubject2,
            searchSnippetPreview: searchSnippetPreview2,
          ),
        ]
      );
    });
  });
}