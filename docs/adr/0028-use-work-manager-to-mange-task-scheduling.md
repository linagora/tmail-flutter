# 28. Use WorkManager to manage task scheduling

Date: 2023-05-23

## Status

Accepted

## Context

- To automatically manage and schedule tasks. 
- For example, automatically add email sending when network outage to `Queue` and automatically sending when network is back.

## Decision

- Use library `workmanager` on [pub.dev](https://pub.dev/packages/workmanager)

### 1. Configuration

- Add to `pubspec.yaml`
```
dependencies:
  workmanager: ^0.5.1
```

- Setup on Android: [ANDROID_SETUP.md](https://github.com/fluttercommunity/flutter_workmanager/blob/main/ANDROID_SETUP.md)

- Setup on iOS: [IOS_SETUP.md](https://github.com/fluttercommunity/flutter_workmanager/blob/main/IOS_SETUP.md)

### 2. Implement

- Initialize the WorkManager

```
await WorkManagerConfig().initialize();
```

- Create new `Worker`
```
final worker = Worker(
  id: String // Task identifier
  type: String // Job type, used to group jobs with the same purpose (Like Insert, Delete, Sent)
  data: Map<String, dynamic> // Input parameters. Valid value types are: int, bool, double, String and their list
);
```

- Create new `WorkRequest`

+ For non-repeating work: 
```
final workReuest = OneTimeWorkRequest(
  worker
  Duration? initialDelay,
  Duration? backoffPolicyDelay,
  ExistingWorkPolicy? existingWorkPolicy,
  BackoffPolicy? backoffPolicy,
  OutOfQuotaPolicy? outOfQuotaPolicy,
  Constraints? constraints
);
```
+ For repeating work:
```
final workReuest = PeriodicWorkRequest(
  worker
  Duration? frequency,
  Duration? initialDelay,
  Duration? backoffPolicyDelay,
  ExistingWorkPolicy? existingWorkPolicy,
  BackoffPolicy? backoffPolicy,
  OutOfQuotaPolicy? outOfQuotaPolicy,
  Constraints? constraints
);
```

- Add to `enqueue`

```
await WorkSchedulerController().enqueue(workReuest);
```

- Handle task in `handleBackgroundTask` method
- To cancel task in WorkManager
```
await WorkSchedulerController().cancelByWorkType(workType);

await WorkSchedulerController().cancelByUniqueId(uniqueId);

await WorkSchedulerController().cancelAll();
```


## Consequences

- The correct `mailbox` and `email` lists are obtained for each account
