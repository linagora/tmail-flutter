import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:tmail_ui_user/features/offline_mode/hive_worker/hive_task_state.dart';

class HiveTask<A> with EquatableMixin {
  final String? id;
  final A? action;
  final Future<bool> Function()? conditionInvoked;
  final Future Function() runnable;

  HiveTask({
    required this.runnable,
    this.id,
    this.action,
    this.conditionInvoked,
  });

  Future execute() async {
    final resultCompleter = Completer();

    try {
      if (conditionInvoked != null) {
        final invoked = await conditionInvoked!.call();
        if (invoked) {
          final result = await runnable.call();
          resultCompleter.complete(TaskSuccess(result: result));
        } else {
          resultCompleter.completeError(TaskFailure());
        }
      } else {
        final result = await runnable.call();
        resultCompleter.complete(TaskSuccess(result: result));
      }
    } catch (e) {
      resultCompleter.completeError(TaskFailure(exception: e));
    }

    return resultCompleter.future;
  }

  @override
  List<Object?> get props => [runnable, id, action, conditionInvoked];
}