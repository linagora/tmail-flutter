import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/email/mark_star_action.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/email/read_actions.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/search_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/update_current_emails_flags_extension.dart';
import 'package:tmail_ui_user/features/search/email/presentation/notifier/search_email_presentation_notifier.dart';
import 'package:tmail_ui_user/main/providers/app_provider_container.dart';

import 'update_current_emails_flags_extension_test.mocks.dart';

class _DesktopResponsiveUtils extends ResponsiveUtils {
  @override
  bool isWebDesktop(BuildContext context) => true;
}

@GenerateNiceMocks([
  MockSpec<MailboxDashBoardController>(),
  MockSpec<SearchController>(),
])
void main() {
  const numberOfEmails = 3;
  late List<EmailId> emailIds;
  final mailboxDashBoardController = MockMailboxDashBoardController();
  final searchController = MockSearchController();

  setUp(() {
    emailIds = List.generate(
      numberOfEmails,
      (index) => EmailId(Id('email-id-$index')),
    );
    when(mailboxDashBoardController.searchController).thenReturn(searchController);
    when(searchController.isSearchEmailRunning).thenReturn(false);
    when(mailboxDashBoardController.updateEmailList(any)).thenAnswer(
      (invocation) => mailboxDashBoardController.emailsInCurrentMailbox.value =
          invocation.positionalArguments.first as List<PresentationEmail>,
    );
  });

  group('updateEmailFlagByEmailIds test:', () {
    test(
      'should mark emails as read',
    () {
      // arrange
      final readEmailIds = emailIds.sublist(1);
      when(mailboxDashBoardController.emailsInCurrentMailbox).thenReturn(
        emailIds.map((emailId) => PresentationEmail(
          id: emailId,
          keywords: {},
        )).toList().obs,
      );
      expect(
        mailboxDashBoardController.emailsInCurrentMailbox.every(
          (presentationEmail) => !presentationEmail.hasRead,
        ),
        true,
      );
      
      // act
      mailboxDashBoardController.updateEmailFlagByEmailIds(
        readEmailIds,
        readAction: ReadActions.markAsRead,
      );
      
      // assert
      expect(mailboxDashBoardController.emailsInCurrentMailbox[0].hasRead, false);
      expect(mailboxDashBoardController.emailsInCurrentMailbox[1].hasRead, true);
      expect(mailboxDashBoardController.emailsInCurrentMailbox[2].hasRead, true);
    });

    test(
      'should mark emails as unread',
    () {
      // arrange
      final unreadEmailIds = emailIds.sublist(1);
      when(mailboxDashBoardController.emailsInCurrentMailbox).thenReturn(
        emailIds.map((emailId) => PresentationEmail(
          id: emailId,
          keywords: {KeyWordIdentifier.emailSeen: true},
        )).toList().obs,
      );
      expect(
        mailboxDashBoardController.emailsInCurrentMailbox.every(
          (presentationEmail) => presentationEmail.hasRead,
        ),
        true,
      );
      
      // act
      mailboxDashBoardController.updateEmailFlagByEmailIds(
        unreadEmailIds,
        readAction: ReadActions.markAsUnread,
      );
      
      // assert
      expect(mailboxDashBoardController.emailsInCurrentMailbox[0].hasRead, true);
      expect(mailboxDashBoardController.emailsInCurrentMailbox[1].hasRead, false);
      expect(mailboxDashBoardController.emailsInCurrentMailbox[2].hasRead, false);
    });

    test(
      'should mark emails as starred',
    () {
      // arrange
      final starredEmailIds = emailIds.sublist(1);
      when(mailboxDashBoardController.emailsInCurrentMailbox).thenReturn(
        emailIds.map((emailId) => PresentationEmail(
          id: emailId,
          keywords: {},
        )).toList().obs,
      );
      expect(
        mailboxDashBoardController.emailsInCurrentMailbox.every(
          (presentationEmail) => !presentationEmail.hasStarred,
        ),
        true,
      );
      
      // act
      mailboxDashBoardController.updateEmailFlagByEmailIds(
        starredEmailIds,
        markStarAction: MarkStarAction.markStar,
      );
      
      // assert
      expect(mailboxDashBoardController.emailsInCurrentMailbox[0].hasStarred, false);
      expect(mailboxDashBoardController.emailsInCurrentMailbox[1].hasStarred, true);
      expect(mailboxDashBoardController.emailsInCurrentMailbox[2].hasStarred, true);
    });

    test(
      'should mark emails as unstarred',
    () {
      // arrange
      final unstarredEmailIds = emailIds.sublist(1);
      when(mailboxDashBoardController.emailsInCurrentMailbox).thenReturn(
        emailIds.map((emailId) => PresentationEmail(
          id: emailId,
          keywords: {KeyWordIdentifier.emailFlagged: true},
        )).toList().obs,
      );
      expect(
        mailboxDashBoardController.emailsInCurrentMailbox.every(
          (presentationEmail) => presentationEmail.hasStarred,
        ),
        true,
      );
      
      // act
      mailboxDashBoardController.updateEmailFlagByEmailIds(
        unstarredEmailIds,
        markStarAction: MarkStarAction.unMarkStar,
      );
      
      // assert
      expect(mailboxDashBoardController.emailsInCurrentMailbox[0].hasStarred, true);
      expect(mailboxDashBoardController.emailsInCurrentMailbox[1].hasStarred, false);
      expect(mailboxDashBoardController.emailsInCurrentMailbox[2].hasStarred, false);
    });
  });

  group('updateEmailFlagByEmailIds on the mobile search route:', () {
    setUp(() {
      appProviderContainer.invalidate(searchEmailPresentationProvider);
      when(searchController.isSearchEmailRunning).thenReturn(true);
      appProviderContainer
          .read(searchEmailPresentationProvider.notifier)
          .setSearchIsRunning(true);
      appProviderContainer
          .read(searchEmailPresentationProvider.notifier)
          .setResultSearches(
            emailIds
                .map((emailId) => PresentationEmail(id: emailId, keywords: {}))
                .toList(),
          );
    });

    tearDown(() =>
        appProviderContainer.invalidate(searchEmailPresentationProvider));

    test(
      'writes the flag change back into searchEmailPresentationProvider for a responsive search layout',
      () {
        // act
        mailboxDashBoardController.updateEmailFlagByEmailIds(
          emailIds.sublist(1),
          readAction: ReadActions.markAsRead,
        );

        // assert
        final result = appProviderContainer
            .read(searchEmailPresentationProvider)
            .listResultSearch;
        expect(result[0].hasRead, false);
        expect(result[1].hasRead, true);
        expect(result[2].hasRead, true);
      },
    );

    test(
      'creates keyword state for a keyword-less search result without mutating the original email',
      () {
        final keywordLessEmail = PresentationEmail(id: emailIds.first);
        appProviderContainer
            .read(searchEmailPresentationProvider.notifier)
            .setResultSearches([keywordLessEmail]);

        mailboxDashBoardController.updateEmailFlagByEmailIds(
          [emailIds.first],
          markStarAction: MarkStarAction.markStar,
          markAsAnswered: true,
        );

        final result = appProviderContainer
            .read(searchEmailPresentationProvider)
            .listResultSearch
            .single;
        expect(result.hasStarred, true);
        expect(result.isAnswered, true);
        expect(keywordLessEmail.keywords, isNull);
      },
    );

    testWidgets(
      'writes flags to Riverpod on a web mobile-width search layout',
      (tester) async {
        PlatformInfo.isTestingForWeb = true;
        addTearDown(() => PlatformInfo.isTestingForWeb = false);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.binding.setSurfaceSize(const Size(375, 800));
        when(mailboxDashBoardController.responsiveUtils)
            .thenReturn(ResponsiveUtils());
        await tester.pumpWidget(const GetMaterialApp(home: SizedBox()));

        mailboxDashBoardController.updateEmailFlagByEmailIds(
          [emailIds.first],
          readAction: ReadActions.markAsRead,
        );

        final result = appProviderContainer
            .read(searchEmailPresentationProvider)
            .listResultSearch;
        expect(result.first.hasRead, true);
      },
    );

    testWidgets(
      'writes flags to the mailbox list on a web desktop search layout',
      (tester) async {
        PlatformInfo.isTestingForWeb = true;
        addTearDown(() => PlatformInfo.isTestingForWeb = false);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.binding.setSurfaceSize(const Size(1200, 800));
        when(mailboxDashBoardController.responsiveUtils)
            .thenReturn(_DesktopResponsiveUtils());
        when(mailboxDashBoardController.emailsInCurrentMailbox).thenReturn(
          emailIds
              .map((emailId) => PresentationEmail(id: emailId, keywords: {}))
              .toList()
              .obs,
        );
        await tester.pumpWidget(const GetMaterialApp(home: SizedBox()));

        mailboxDashBoardController.updateEmailFlagByEmailIds(
          [emailIds.first],
          readAction: ReadActions.markAsRead,
        );

        final searchResults = appProviderContainer
            .read(searchEmailPresentationProvider)
            .listResultSearch;
        expect(searchResults.every((email) => !email.hasRead), isTrue);
        expect(
          mailboxDashBoardController.emailsInCurrentMailbox.first.hasRead,
          isTrue,
        );
        expect(
          mailboxDashBoardController.emailsInCurrentMailbox
              .skip(1)
              .every((email) => !email.hasRead),
          isTrue,
        );
      },
    );
  });
}
