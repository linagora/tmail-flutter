import 'package:core/utils/app_logger.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_bindings.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';

class ComposerManager extends GetxController {
  final RxMap<String, ComposerController> composers = <String, ComposerController>{}.obs;

  String addComposer() {
    final String id = DateTime.now().millisecondsSinceEpoch.toString();
    log('ComposerManager::addComposer:ID = $id');
    ComposerBindings(composerId: id).dependencies();
    final ComposerController controller = Get.find<ComposerController>(tag: id);
    composers[id] = controller;
    return id;
  }

  void removeComposer(String id) {
    if (composers.containsKey(id)) {
      ComposerBindings(composerId: id).dispose();
      composers.remove(id);
    }
  }

  List<String> get composerIds => composers.keys.toList();

  ComposerController? getComposer(String id) => composers[id];
}