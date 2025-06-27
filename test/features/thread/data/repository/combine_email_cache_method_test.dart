import 'package:core/data/model/source_type/data_source_type.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/individual_header_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:mockito/mockito.dart';
import 'package:model/email/email_property.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource/state_datasource.dart';
import 'package:tmail_ui_user/features/thread/data/datasource/thread_datasource.dart';
import 'package:tmail_ui_user/features/thread/data/repository/thread_repository_impl.dart';
import 'package:tmail_ui_user/features/thread/domain/constants/thread_constants.dart';

class MockThreadDataSource extends Mock implements ThreadDataSource {}

class MockStateDataSource extends Mock implements StateDataSource {}

void main() {
  late ThreadRepositoryImpl repository;
  late Map<DataSourceType, ThreadDataSource> mockDataSources;
  late MockStateDataSource mockStateDataSource;

  Email createEmail({
    String? id,
    String? subject,
    Map<MailboxId, bool>? mailboxIds,
    Map<KeyWordIdentifier, bool>? keywords,
    Map<IndividualHeaderIdentifier, String?>? xPriorityHeader,
  }) {
    return Email(
      id: id != null ? EmailId(Id(id)) : null,
      subject: subject,
      mailboxIds: mailboxIds ?? {MailboxId(Id('inbox')): true},
      keywords: keywords ?? {KeyWordIdentifier.emailSeen: true},
      xPriorityHeader: xPriorityHeader,
    );
  }

  setUp(() {
    mockDataSources = {
      DataSourceType.network: MockThreadDataSource(),
      DataSourceType.local: MockThreadDataSource(),
    };
    mockStateDataSource = MockStateDataSource();
    repository = ThreadRepositoryImpl(mockDataSources, mockStateDataSource);
  });

  group('ThreadRepositoryImpl.combineEmailCache', () {
    final defaultProperties = ThreadConstants.propertiesDefault;
    final nonDefaultProperties =
        Properties({EmailProperty.id, EmailProperty.subject});

    final email1 = createEmail(
      id: '1',
      subject: 'Original 1',
      keywords: {KeyWordIdentifier.emailFlagged: true},
      mailboxIds: {MailboxId(Id('inbox')): true},
    );

    final email2 = createEmail(
      id: '2',
      subject: 'Original 2',
      keywords: {KeyWordIdentifier.emailSeen: true},
      mailboxIds: {MailboxId(Id('archive')): true},
    );

    final emailCacheList = [email1, email2];

    test('should return null for null emailUpdated', () async {
      expect(
        await repository.combineEmailCache(
          emailUpdated: null,
          updatedProperties: defaultProperties,
          emailCacheList: emailCacheList,
        ),
        isNull,
      );
    });

    test('should return empty list for empty emailUpdated', () async {
      expect(
        await repository.combineEmailCache(
          emailUpdated: [],
          updatedProperties: defaultProperties,
          emailCacheList: emailCacheList,
        ),
        isEmpty,
      );
    });

    test('should return null for null updatedProperties', () async {
      expect(
        await repository.combineEmailCache(
          emailUpdated: [createEmail(id: '1')],
          updatedProperties: null,
          emailCacheList: emailCacheList,
        ),
        isNull,
      );
    });

    test('should return identical list when properties are default', () async {
      final updated = [createEmail(id: '1', subject: 'Updated')];
      expect(
        await repository.combineEmailCache(
          emailUpdated: updated,
          updatedProperties: defaultProperties,
          emailCacheList: emailCacheList,
        ),
        equals(updated),
      );
    });

    test('should merge partial updates for non-default properties', () async {
      final updated = [createEmail(id: '1', subject: 'New Subject')];
      final result = await repository.combineEmailCache(
        emailUpdated: updated,
        updatedProperties: nonDefaultProperties,
        emailCacheList: emailCacheList,
      );

      expect(result, hasLength(1));
      expect(result![0].subject, 'New Subject'); // Updated
      expect(
        result[0].keywords,
        {KeyWordIdentifier.emailFlagged: true},
      ); // From cache
    });

    test('should skip emails not found in cache', () async {
      final result = await repository.combineEmailCache(
        emailUpdated: [createEmail(id: '99')],
        updatedProperties: nonDefaultProperties,
        emailCacheList: emailCacheList,
      );
      expect(result, isEmpty);
    });

    test('should handle empty cache list', () async {
      final result = await repository.combineEmailCache(
        emailUpdated: [createEmail(id: '1')],
        updatedProperties: nonDefaultProperties,
        emailCacheList: [],
      );
      expect(result, isEmpty);
    });

    test('should handle null cache list', () async {
      final result = await repository.combineEmailCache(
        emailUpdated: [createEmail(id: '1')],
        updatedProperties: nonDefaultProperties,
        emailCacheList: null,
      );
      expect(result, isEmpty);
    });

    test('should handle email with null ID', () async {
      final result = await repository.combineEmailCache(
        emailUpdated: [createEmail(id: null)],
        updatedProperties: nonDefaultProperties,
        emailCacheList: emailCacheList,
      );
      expect(result, isEmpty);
    });

    test('should preserve xPriorityHeader when not in updated properties',
        () async {
      final cached = createEmail(
        id: '1',
        xPriorityHeader: {
          IndividualHeaderIdentifier.xPriorityHeader: 'high',
        },
      );
      final updated = createEmail(id: '1', subject: 'Updated');

      final result = await repository.combineEmailCache(
        emailUpdated: [updated],
        updatedProperties: nonDefaultProperties,
        emailCacheList: [cached],
      );

      expect(result![0].xPriorityHeader, equals(cached.xPriorityHeader));
    });

    test('should update xPriorityHeader when in updated properties', () async {
      final newXPriorityHeader = {
        IndividualHeaderIdentifier.xPriorityHeader: 'low',
      };
      final updated = createEmail(
        id: '1',
        xPriorityHeader: newXPriorityHeader,
      );

      final result = await repository.combineEmailCache(
        emailUpdated: [updated],
        updatedProperties: Properties({
          EmailProperty.id,
          IndividualHeaderIdentifier.xPriorityHeader.value,
        }),
        emailCacheList: [createEmail(id: '1')],
      );

      expect(result![0].xPriorityHeader, equals(newXPriorityHeader));
    });

    test('should handle multiple emails update', () async {
      final updated = [
        createEmail(id: '1', subject: 'Updated 1'),
        createEmail(id: '2', subject: 'Updated 2'),
      ];

      final result = await repository.combineEmailCache(
        emailUpdated: updated,
        updatedProperties: nonDefaultProperties,
        emailCacheList: emailCacheList,
      );

      expect(result, hasLength(2));
      expect(result![0].subject, 'Updated 1');
      expect(result[1].subject, 'Updated 2');
    });

    test('should handle mix of cached and non-cached emails', () async {
      final updated = [
        createEmail(id: '1'), // Exists in cache
        createEmail(id: '99'), // Not in cache
        createEmail(id: '2'), // Exists in cache
      ];

      final result = await repository.combineEmailCache(
        emailUpdated: updated,
        updatedProperties: nonDefaultProperties,
        emailCacheList: emailCacheList,
      );

      expect(result, hasLength(2));
      expect(result!.map((e) => e.id?.id.value), containsAll(['1', '2']));
    });

    test('should handle empty properties set', () async {
      final result = await repository.combineEmailCache(
        emailUpdated: [createEmail(id: '1')],
        updatedProperties: Properties({}),
        emailCacheList: emailCacheList,
      );
      expect(result, hasLength(1));
      expect(result![0].subject, 'Original 1');
    });

    test('should handle properties with only non-existing fields', () async {
      final result = await repository.combineEmailCache(
        emailUpdated: [createEmail(id: '1')],
        updatedProperties: Properties({'non_existing_field'}),
        emailCacheList: emailCacheList,
      );
      expect(result, hasLength(1));
      expect(result![0].subject, 'Original 1');
    });
  });

  group('ThreadRepositoryImpl.combineUpdatedWithEmailInCache', () {
    final cache = [
      createEmail(id: '1'),
      createEmail(id: '2'),
    ];

    test('should find existing email in cache', () {
      final result = repository.combineUpdatedWithEmailInCache(
        createEmail(id: '1'),
        cache,
      );
      expect(result.oldEmail, isNotNull);
      expect(result.updatedEmail.id?.id.value, '1');
    });

    test('should return null for non-existing email', () {
      final result = repository.combineUpdatedWithEmailInCache(
        createEmail(id: '99'),
        cache,
      );
      expect(result.oldEmail, isNull);
    });

    test('should return null for null email ID', () {
      final result = repository.combineUpdatedWithEmailInCache(
        createEmail(id: null),
        cache,
      );
      expect(result.oldEmail, isNull);
    });

    test('should return null for empty cache', () {
      final result = repository.combineUpdatedWithEmailInCache(
        createEmail(id: '1'),
        [],
      );
      expect(result.oldEmail, isNull);
    });

    test('should return null for null cache', () {
      final result = repository.combineUpdatedWithEmailInCache(
        createEmail(id: '1'),
        null,
      );
      expect(result.oldEmail, isNull);
    });
  });
}
