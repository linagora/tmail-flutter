import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:labels/model/label.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/presentation_label_mailbox.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/navigation_router.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';

/// Asserts the route, address and subject of a parsed mailto map, so tests read
/// in domain terms instead of repeating `expect`s. [address]/[subject] default
/// to being absent.
void expectParsedMailto(
  Map<String, dynamic> result, {
  Object? address = isNull,
  Object? subject = isNull,
}) {
  expect(result[RouteUtils.paramRouteName], AppRoutes.mailtoURL);
  expect(result[RouteUtils.paramMailtoAddress], address);
  expect(result[RouteUtils.paramSubject], subject);
}

/// Asserts every equivalent mailto form parses to the same map.
void expectSameParsing(Iterable<Map<String, dynamic>> results) {
  for (final result in results.skip(1)) {
    expect(result, equals(results.first));
  }
}

void main() {
  group('dashboardRouterForMailboxOrSearch test', () {
    final mailboxId = MailboxId(Id('mailbox-1'));
    final regularMailbox = PresentationMailbox(mailboxId);
    final labelMailbox = PresentationLabelMailbox(
      MailboxId(Id('label-1')),
      Label(id: Id('label-1'), displayName: 'Work'),
    );
    final query = SearchQuery('hello');

    NavigationRouter buildRouter({
      required bool isSearchRunning,
      PresentationMailbox? selectedMailbox,
      EmailId? emailId,
    }) {
      return RouteUtils.dashboardRouterForMailboxOrSearch(
        isSearchRunning: isSearchRunning,
        emailId: emailId,
        selectedMailbox: selectedMailbox,
        searchQuery: query,
      );
    }

    // NavigationRouter is an Equatable, so one expectation over the whole
    // router covers mailboxId, labelId, searchQuery and dashboardType at once.
    final searchRouter = NavigationRouter(
      dashboardType: DashboardType.search,
      searchQuery: query,
    );

    test('keeps the folder context off search', () {
      expect(
        buildRouter(isSearchRunning: false, selectedMailbox: regularMailbox),
        NavigationRouter(mailboxId: mailboxId),
      );
    });

    test('keeps the label context off search', () {
      expect(
        buildRouter(isSearchRunning: false, selectedMailbox: labelMailbox),
        NavigationRouter(labelId: labelMailbox.labelId),
      );
    });

    test('drops the folder context during search', () {
      expect(
        buildRouter(isSearchRunning: true, selectedMailbox: regularMailbox),
        searchRouter,
      );
    });

    test('drops the label context during search', () {
      expect(
        buildRouter(isSearchRunning: true, selectedMailbox: labelMailbox),
        searchRouter,
      );
    });

    test('keeps the open email regardless of search state', () {
      final emailId = EmailId(Id('email-1'));
      for (final isSearchRunning in [true, false]) {
        expect(
          buildRouter(
            isSearchRunning: isSearchRunning,
            selectedMailbox: regularMailbox,
            emailId: emailId,
          ).emailId,
          emailId,
        );
      }
    });
  });

  group('dashboardBrowserRouteTitle test', () {
    final mailbox = PresentationMailbox(
      MailboxId(Id('mailbox-1')),
      name: MailboxName('Inbox'),
    );

    test('uses the selected email before search and mailbox', () {
      expect(
        RouteUtils.dashboardBrowserRouteTitle(
          isSearchRunning: true,
          selectedEmailId: EmailId(Id('email-1')),
          selectedMailbox: mailbox,
        ),
        'Email-email-1',
      );
    });

    test('uses search while search is running', () {
      expect(
        RouteUtils.dashboardBrowserRouteTitle(
          isSearchRunning: true,
          selectedMailbox: mailbox,
        ),
        'SearchEmail',
      );
    });

    test('uses the selected mailbox outside search', () {
      expect(
        RouteUtils.dashboardBrowserRouteTitle(
          isSearchRunning: false,
          selectedMailbox: mailbox,
        ),
        mailbox.browserRouteTitle,
      );
    });

    test('uses an empty title without a selected mailbox', () {
      expect(
        RouteUtils.dashboardBrowserRouteTitle(isSearchRunning: false),
        isEmpty,
      );
    });
  });

  group('parseMapMailtoFromUri test', () {
    // Shared fixture for the "every possible parameters" cases.
    const to1 = 'to1@example.com';
    const to2 = 'to2@example.com';
    const to3 = 'to3@example.com';
    const cc1 = 'cc1@example.com';
    const cc2 = 'cc2@example.com';
    const bcc1 = 'bcc1@example.com';
    const bcc2 = 'bcc2@example.com';
    const subject = 'Hello';
    const body = 'Bye';
    const mailtoSchemeUri = 'mailto:$to1,$to2'
        '?to=$to2,$to3'
        '&cc=$cc1,$cc2'
        '&bcc=$bcc1,$bcc2'
        '&subject=$subject'
        '&body=$body';
    const mailtoPathUri = 'https://example.com/mailto'
        '?uri=$to1,$to2'
        '&to=$to2,$to3'
        '&cc=$cc1,$cc2'
        '&bcc=$bcc1,$bcc2'
        '&subject=$subject'
        '&body=$body';
    const mailtoPathWithNestedMailtoUri = 'https://example.com/mailto/'
        '?uri=mailto:$to1,$to2'
        '&to=$to2,$to3'
        '&cc=$cc1,$cc2'
        '&bcc=$bcc1,$bcc2'
        '&subject=$subject'
        '&body=$body';

    // Asserts a fully-populated mailto: the shared cc/bcc/subject/body fixture
    // plus the recipients described by [address].
    void expectFullyParsedMailto(Map<String, dynamic> result, Object address) {
      expectParsedMailto(result, address: address, subject: subject);
      expect(result[RouteUtils.paramCc], containsAll([cc1, cc2]));
      expect(result[RouteUtils.paramBcc], containsAll([bcc1, bcc2]));
      expect(result[RouteUtils.paramBody], body);
    }

    // Parses the scheme/path/nested URI forms (via [transform]) and asserts they
    // agree and carry every parameter.
    void expectAllUriFormsMatch(String Function(String uri) transform) {
      final results = [
        mailtoSchemeUri,
        mailtoPathUri,
        mailtoPathWithNestedMailtoUri,
      ].map((uri) => RouteUtils.parseMapMailtoFromUri(transform(uri))).toList();

      expectSameParsing(results);
      expectFullyParsedMailto(results.first, containsAll([to1, to2, to3]));
    }

    test('should parse a valid mailto URI', () {
      final result = RouteUtils.parseMapMailtoFromUri(
        'mailto:test@example.com?subject=Hello');

      expectParsedMailto(result, address: 'test@example.com', subject: 'Hello');
    });

    // RFC 6068: a reserved character inside a header value is percent-encoded
    // once, and `+` is a literal plus (not a space). The URI must be decoded
    // once only, otherwise `%2B` becomes a space and `%26` splits the value.
    test('should keep a percent-encoded plus sign in the body', () {
      final result = RouteUtils.parseMapMailtoFromUri(
        'mailto:test@example.com?body=1%2B1%3D2');

      expect(result[RouteUtils.paramBody], '1+1=2');
    });

    test('should keep a percent-encoded ampersand in the subject and body', () {
      final result = RouteUtils.parseMapMailtoFromUri(
        'mailto:test@example.com?subject=Q%26A&body=salt%20%26%20pepper');

      expect(result[RouteUtils.paramSubject], 'Q&A');
      expect(result[RouteUtils.paramBody], 'salt & pepper');
    });

    test('should decode an encoded address followed by a query', () {
      final result = RouteUtils.parseMapMailtoFromUri(
        'mailto:test%40example.com?subject=Hello');

      expectParsedMailto(result, address: 'test@example.com', subject: 'Hello');
    });

    // The browser mailto handler (`/mailto/?uri=%s`) percent-encodes the
    // whole mailto URL once more: header values arrive encoded twice and must
    // still be decoded once into the value the sender wrote.
    test('should decode header values once in a mailto URL from the browser handler', () {
      final result = RouteUtils.parseMapMailtoFromUri(
        'https://example.com/mailto/?uri=mailto%3Atest%40example.com'
        '%3Fsubject%3D1%252B1%26body%3Dsalt%2520%2526%2520pepper');

      expectParsedMailto(result, address: 'test@example.com', subject: '1+1');
      expect(result[RouteUtils.paramBody], 'salt & pepper');
    });

    test('should parse a valid mailto URI encoded', () {
      final result = RouteUtils.parseMapMailtoFromUri(
        'mailto:test%40example.com%3Fsubject=Hello');

      expectParsedMailto(result, address: 'test@example.com', subject: 'Hello');
    });

    test('should handle a mailto URI without subject', () {
      final result = RouteUtils.parseMapMailtoFromUri('mailto:test@example.com');

      expectParsedMailto(result, address: 'test@example.com');
    });

    test('should handle a mailto URI without subject encoded', () {
      final result = RouteUtils.parseMapMailtoFromUri('mailto:test%40example.com');

      expectParsedMailto(result, address: 'test@example.com');
    });

    test('should handle a non-mailto URI', () {
      final result = RouteUtils.parseMapMailtoFromUri('test@example.com');

      expectParsedMailto(result, address: 'test@example.com');
    });

    test('should handle a non-mailto URI encoded', () {
      final result = RouteUtils.parseMapMailtoFromUri('test%40example.com');

      expectParsedMailto(result, address: 'test@example.com');
    });

    test('should handle null input', () {
      final result = RouteUtils.parseMapMailtoFromUri(null);

      expectParsedMailto(result);
    });

    test('should parse multiple recipients from encoded and plain mailto URIs', () {
      final results = [
        'mailto:test%40example.com%2Ctest2%40example.com'
            '%2Ctest3%40example.com%3Fsubject=Hello',
        'mailto:test@example.com,test2@example.com,test3@example.com?subject=Hello',
      ].map(RouteUtils.parseMapMailtoFromUri).toList();

      expectSameParsing(results);
      expectParsedMailto(
        results.first,
        address: containsAll(
          ['test@example.com', 'test2@example.com', 'test3@example.com']),
        subject: 'Hello',
      );
    });

    test('should parse every possible parameter from encoded and plain URIs', () {
      expectAllUriFormsMatch(Uri.encodeFull);
      expectAllUriFormsMatch((uri) => uri);
    });

    test(
      'should parse url with mailto uri '
      'when the query parameter belongs to the mailto uri',
    () {
      const to = 'to@example.com';
      const mailtoUri = 'https://example.com/mailto/'
        '?uri=mailto:$to'
        '?subject=$subject'
        '&cc=$cc1,$cc2'
        '&bcc=$bcc1,$bcc2'
        '&body=$body';

      final result = RouteUtils.parseMapMailtoFromUri(mailtoUri);

      expectFullyParsedMailto(result, to);
    });
  });

  group('getRootDomain', () {
    test('should return null when hostname is empty', () {
      expect(RouteUtils.getRootDomain(hostname: ''), isNull);
    });

    test('should return null when hostname is empty', () {
      expect(RouteUtils.getRootDomain(hostname: ''), isNull);
    });

    test('should return root domain for simple domain', () {
      expect(RouteUtils.getRootDomain(hostname: 'example.com'), 'example.com');
    });

    test('should return root domain and remove subdomains', () {
      expect(RouteUtils.getRootDomain(hostname: 'mail.dev.example.com'), 'example.com');
    });

    test('should return root domain and remove www subdomain', () {
      expect(RouteUtils.getRootDomain(hostname: 'www.google.com'), 'google.com');
    });

    test('should return localhost as is', () {
      expect(RouteUtils.getRootDomain(hostname: 'localhost'), 'localhost');
    });

    test('should handle multi-level tld like co.uk (not fully accurate)', () {
      expect(RouteUtils.getRootDomain(hostname: 'service.example.co.uk'), 'co.uk');
    });
  });

  // A mailto link clicked in an email opens the composer through
  // generateNavigationRouterFromMailtoLink. RFC 6068 percent-encodes
  // reserved characters in header values exactly once: the composer must
  // receive them as written by the sender.
  group('generateNavigationRouterFromMailtoLink header values (RFC 6068)', () {
    NavigationRouter open(String query) =>
        RouteUtils.generateNavigationRouterFromMailtoLink('mailto:alice@example.com?$query');

    test('should keep a plus sign in the body', () {
      expect(open('body=1%2B1%3D2').body, '1+1=2');
    });

    test('should keep an ampersand in the subject', () {
      expect(open('subject=Q%26A&body=x').subject, 'Q&A');
    });

    test('should keep the text after an ampersand in the body', () {
      expect(open('body=salt%20%26%20pepper').body, 'salt & pepper');
    });

    test('should keep a percent sign in the body', () {
      expect(open('body=100%25%20done').body, '100% done');
    });

    test('should keep an equals sign and a question mark in the body', () {
      expect(open('body=a%3Db%3Fc').body, 'a=b?c');
    });

    test('should keep line breaks in the body', () {
      expect(open('body=line1%0D%0Aline2').body, 'line1\r\nline2');
    });

    test('should keep the recipient when the body holds an encoded ampersand', () {
      final router = open('body=a%26to%3Deve%40example.com');

      expect(
        router.listEmailAddress?.map((address) => address.email),
        ['alice@example.com'],
      );
      expect(router.body, 'a&to=eve@example.com');
    });

    test('should not add a bcc recipient from an encoded ampersand in the body', () {
      final router = open('body=hi%26bcc%3Deve%40example.com');

      expect(router.bcc ?? [], isEmpty);
      expect(router.body, 'hi&bcc=eve@example.com');
    });
  });
}
