import 'dart:collection';

import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_bindings.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view_web.dart';
import 'package:tmail_ui_user/features/composer/presentation/utils/composer_utils.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';

class ComposerManager extends GetxController {
  final RxMap<String, ComposerView> composers = <String, ComposerView>{}.obs;
  final Queue<String> composerIdsQueue = Queue<String>();

  void addComposer(ComposerArguments composerArguments) {
    final String id = DateTime.now().millisecondsSinceEpoch.toString();
    log('ComposerManager::addComposer:ID = $id');
    ComposerBindings(
      composerId: id,
      composerArguments: composerArguments,
    ).dependencies();
    composerIdsQueue.add(id);
    composers[id] = ComposerView(
      key: Key(id),
      composerId: id,
    );
    log('ComposerManager::addComposer:Success');
  }

  void removeComposer(String id) {
    log('ComposerManager::removeComposer:ID = $id');
    if (composers.containsKey(id)) {
      composerIdsQueue.remove(id);
      composers.remove(id);
      ComposerBindings(composerId: id).dispose();
      log('ComposerManager::removeComposer:Success');
    }
  }

  ({
    String? previousTargetId,
    String? targetId,
    String? nextTargetId,
  }) findSurroundingComposerIds(String targetId) =>
      ComposerUtils.findSurroundingElements(composerIdsQueue, targetId);

  bool get hasComposer => composerIdsQueue.isNotEmpty;

  List<String> get composerIds => composerIdsQueue.toList();

  String get singleComposerId => composerIdsQueue.first;

  ComposerView getComposerView(String id) => composers[id]!;
}