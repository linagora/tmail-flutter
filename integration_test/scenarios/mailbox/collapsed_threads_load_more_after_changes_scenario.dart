import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';

import '../../base/base_test_scenario.dart';
import '../../mixin/collapsed_threads_scenario_mixin.dart';
import '../../models/provisioning_threads.dart';

enum CollapsedListChange {
  listedThreadsDeleted,
  newThreadsArrived,
  listedThreadsReadWithUnreadFilter,
  newThreadsArrivedDuringLoadMore,
  starredWebsocketRefresh,
}

class CollapsedThreadsLoadMoreAfterChangesScenario extends BaseTestScenario
    with CollapsedThreadsScenarioMixin {
  const CollapsedThreadsLoadMoreAfterChangesScenario(
    super.$,
    super.robots, {
    required this.change,
  });

  final CollapsedListChange change;

  static const _threadCount = 30;
  static const _changedThreads = [3, 7, 12];
  static const _newThreadCount = 20;
  static const _noiseThreads = [201, 202, 203];

  @override
  String get threadSubjectPrefix => switch (change) {
    CollapsedListChange.listedThreadsDeleted => 'ct-remote-delete',
    CollapsedListChange.newThreadsArrived => 'ct-new-on-top',
    CollapsedListChange.newThreadsArrivedDuringLoadMore => 'ct-new-during-load',
    CollapsedListChange.listedThreadsReadWithUnreadFilter =>
      'ct-read-unread-filter',
    CollapsedListChange.starredWebsocketRefresh => 'ct-starred-ws',
  };

  @override
  Future<void> runTestLogic() => runWithCollapsedThreads(() async {
    final newest = DateTime.now().toUtc().subtract(const Duration(days: 1));
    final threads = List.generate(_threadCount, (i) => i + 1);
    final created = await threadProvisioner.provision(
      ProvisioningThreads(
        subjectPrefix: threadSubjectPrefix,
        threadNumbers: threads,
        repliesPerThread: 2,
        newest: newest,
        seen: change != CollapsedListChange.listedThreadsReadWithUnreadFilter,
        starred: change == CollapsedListChange.starredWebsocketRefresh,
      ),
    );
    await waitForEmailState(created.state);

    if (change == CollapsedListChange.listedThreadsReadWithUnreadFilter) {
      threadController.filterMessagesAction(FilterMessageOption.unread);
    }
    await _openListedFolder(newest);
    await robots.threadRobot().assertion.expectListedThreadsArePrefixOf(
      threads,
      threadSubjectPrefix,
    );
    await robots.threadRobot().assertion.expectListedThreadCountBelow(
      _threadCount,
      threadSubjectPrefix,
    );

    final expected = await _changeFolder(created, newest: newest);
    await scrollUntilListStopsGrowing();

    await robots.threadRobot().assertion.expectThreadsListedOnce(
      expected,
      threadSubjectPrefix,
    );
  });

  Future<List<int>> _changeFolder(
    CreatedThreads created, {
    required DateTime newest,
  }) async {
    final threads = created.emailIds.keys.toList();
    final newThreads = List.generate(_newThreadCount, (i) => 101 + i);
    final aboveListed = newest.add(const Duration(hours: 1));

    switch (change) {
      case CollapsedListChange.listedThreadsDeleted:
        await waitForEmailState(
          await threadProvisioner.destroyEmails(_emailsOf(created)),
        );
        return threads.where((t) => !_changedThreads.contains(t)).toList();
      case CollapsedListChange.listedThreadsReadWithUnreadFilter:
        await waitForEmailState(
          await threadProvisioner.markEmailsAsRead(_emailsOf(created)),
        );
        return threads.where((t) => !_changedThreads.contains(t)).toList();
      case CollapsedListChange.newThreadsArrived:
        return _addNewThreads(
          threads,
          newest: aboveListed,
          repliesPerThread: 1,
        );
      case CollapsedListChange.starredWebsocketRefresh:
        return _addNewThreads(
          threads,
          newest: aboveListed,
          repliesPerThread: 2,
          starred: true,
        );
      case CollapsedListChange.newThreadsArrivedDuringLoadMore:
        final added = await threadProvisioner.provision(
          ProvisioningThreads(
            subjectPrefix: threadSubjectPrefix,
            threadNumbers: newThreads,
            repliesPerThread: 1,
            newest: aboveListed,
          ),
        );
        threadController.handleLoadMoreEmailsRequest();
        await waitForLoadMoreIdle();
        await waitForEmailState(added.state);
        return [...newThreads, ...threads];
    }
  }

  Iterable<EmailId> _emailsOf(CreatedThreads created) =>
      _changedThreads.expand((thread) => created.emailIds[thread]!);

  Future<void> _openListedFolder(DateTime newest) async {
    if (change != CollapsedListChange.starredWebsocketRefresh) {
      await reloadFolder();
      return;
    }
    await _provisionUnstarredNoise(newest);
    final flaggedCount = await threadProvisioner.countEmailsWithKeyword(
      KeyWordIdentifier.emailFlagged.value,
    );
    if (flaggedCount < 1) {
      fail(
        'Email/query hasKeyword:\$flagged without inMailbox returned no ids',
      );
    }
    await openStarredFolder();
  }

  Future<void> _provisionUnstarredNoise(DateTime newest) async {
    final noise = await threadProvisioner.provision(
      ProvisioningThreads(
        subjectPrefix: threadSubjectPrefix,
        threadNumbers: _noiseThreads,
        repliesPerThread: 2,
        newest: newest,
      ),
    );
    await waitForEmailState(noise.state);
  }

  Future<List<int>> _addNewThreads(
    List<int> threads, {
    required DateTime newest,
    required int repliesPerThread,
    bool starred = false,
  }) async {
    final newThreads = List.generate(_newThreadCount, (i) => 101 + i);
    final added = await threadProvisioner.provision(
      ProvisioningThreads(
        subjectPrefix: threadSubjectPrefix,
        threadNumbers: newThreads,
        repliesPerThread: repliesPerThread,
        newest: newest,
        starred: starred,
      ),
    );
    await waitForEmailState(added.state);
    return [...newThreads, ...threads];
  }
}
