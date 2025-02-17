import 'package:core/utils/app_logger.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_bindings.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';

class ComposerManager extends GetxController {
  final RxMap<String, ComposerController> composers = <String, ComposerController>{}.obs;

  void addComposer(ComposerArguments composerArguments) {
    final String id = DateTime.now().millisecondsSinceEpoch.toString();
    log('ComposerManager::addComposer:ID = $id');
    ComposerBindings(
      composerId: id,
      composerArguments: composerArguments,
    ).dependencies();
    composers[id] = Get.find<ComposerController>(tag: id);
    log('ComposerManager::addComposer:Success');
  }

  void removeComposer(String id) {
    log('ComposerManager::removeComposer:ID = $id');
    if (composers.containsKey(id)) {
      ComposerBindings(composerId: id).dispose();
      composers.remove(id);
      log('ComposerManager::removeComposer:Success');
    }
  }

  bool get hasComposer => composers.isNotEmpty;

  List<String> get composerIds => composers.keys.toList();

  String get singleComposerId => composerIds.first;
}