@TestOn('vm')

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_config.dart';
import 'package:tmail_ui_user/features/caching/email_cache_client.dart';
import 'package:tmail_ui_user/features/thread/data/extensions/email_extension.dart';

import '../../fixtures/email_fixtures.dart';

void main() {

  late EmailCacheClient _emailCacheClient;

  setUpAll(() {
    HiveCacheConfig().setUp(cachePath: Directory.current.path);
  });

  setUp(() {
    _emailCacheClient = EmailCacheClient();
  });

  group('[delete]', () {
    test('cache should delete item successfully when cache empty', () async {
      await _emailCacheClient.deleteItem(EmailFixtures.email1.id.toString());

      final remainingItems = await _emailCacheClient.getAll();

      expect(remainingItems.length, equals(0));
    });

    test('cache should not delete item which not in the list', () async {
      await _emailCacheClient.insertItem(
          EmailFixtures.email1.id.toString(),
          EmailFixtures.email1.toEmailCache());

      await _emailCacheClient.insertItem(
          EmailFixtures.email2.id.toString(),
          EmailFixtures.email2.toEmailCache());

      await _emailCacheClient.deleteItem(EmailFixtures.email3.id.toString());

      final remainingItems = await _emailCacheClient.getAll();

      expect(remainingItems.length, equals(2));
      expect(
        remainingItems,
        containsAll({
          EmailFixtures.email1.toEmailCache(),
          EmailFixtures.email2.toEmailCache()
        }));
    });

    test('cache should delete item successfully', () async {
      await _emailCacheClient.insertItem(
        EmailFixtures.email1.id.toString(),
        EmailFixtures.email1.toEmailCache());

      await _emailCacheClient.insertItem(
        EmailFixtures.email2.id.toString(),
        EmailFixtures.email2.toEmailCache());

      await _emailCacheClient.deleteItem(EmailFixtures.email1.id.toString());

      final remainingItems = await _emailCacheClient.getAll();

      expect(remainingItems.length, equals(1));
      expect(remainingItems.first, equals(EmailFixtures.email2.toEmailCache()));
    });

    test('cache should not delete item twice', () async {
      await _emailCacheClient.insertItem(
          EmailFixtures.email1.id.toString(),
          EmailFixtures.email1.toEmailCache());

      await _emailCacheClient.insertItem(
          EmailFixtures.email2.id.toString(),
          EmailFixtures.email2.toEmailCache());

      await _emailCacheClient.deleteItem(EmailFixtures.email1.id.toString());
      await _emailCacheClient.deleteItem(EmailFixtures.email1.id.toString());

      final remainingItems = await _emailCacheClient.getAll();

      expect(remainingItems.length, equals(1));
      expect(remainingItems.first, equals(EmailFixtures.email2.toEmailCache()));
    });
  });

  group('[add]', () {
    test('cache should add item when cache empty', () async {
      await _emailCacheClient.insertItem(
          EmailFixtures.email1.id.toString(),
          EmailFixtures.email1.toEmailCache());

      final remainingItems = await _emailCacheClient.getAll();

      expect(remainingItems.length, equals(1));
      expect(remainingItems.first, equals(EmailFixtures.email1.toEmailCache()));
    });

    test('cache should add item when cache not empty', () async {
      await _emailCacheClient.insertItem(
          EmailFixtures.email1.id.toString(),
          EmailFixtures.email1.toEmailCache());

      await _emailCacheClient.insertItem(
          EmailFixtures.email2.id.toString(),
          EmailFixtures.email2.toEmailCache());

      final remainingItems = await _emailCacheClient.getAll();

      expect(remainingItems.length, equals(2));
      expect(
        remainingItems,
        containsAll({
          EmailFixtures.email1.toEmailCache(),
          EmailFixtures.email2.toEmailCache()
        }));
    });

    test('cache should not add item twice', () async {
      await _emailCacheClient.insertItem(
          EmailFixtures.email1.id.toString(),
          EmailFixtures.email1.toEmailCache());

      await _emailCacheClient.insertItem(
          EmailFixtures.email1.id.toString(),
          EmailFixtures.email1.toEmailCache());

      final remainingItems = await _emailCacheClient.getAll();

      expect(remainingItems.length, equals(1));
      expect(
        remainingItems,
        containsAll({
          EmailFixtures.email1.toEmailCache(),
        }));
    });
  });

  group('[update]', () {
    test('cache should update item when update to iem which not in cache', () async {
      await _emailCacheClient.updateItem(
          EmailFixtures.email1.id.toString(),
          EmailFixtures.email1.toEmailCache());

      final remainingItems = await _emailCacheClient.getAll();

      expect(remainingItems.length, equals(1));
      expect(remainingItems.first, equals(EmailFixtures.email1.toEmailCache()));
    });

    test('cache should update correctly item', () async {
      await _emailCacheClient.insertItem(
          EmailFixtures.email1.id.toString(),
          EmailFixtures.email1.toEmailCache());

      await _emailCacheClient.insertItem(
          EmailFixtures.email2.id.toString(),
          EmailFixtures.email2.toEmailCache());

      await _emailCacheClient.updateItem(
          EmailFixtures.email1.id.toString(),
          EmailFixtures.email3.toEmailCache());

      final remainingItems = await _emailCacheClient.getAll();

      expect(remainingItems.length, equals(2));
      expect(
        remainingItems,
        containsAll({
          EmailFixtures.email2.toEmailCache(),
          EmailFixtures.email3.toEmailCache()
        }));
    });
  });

  tearDown(() async {
    await _emailCacheClient.deleteBox();
  });
}