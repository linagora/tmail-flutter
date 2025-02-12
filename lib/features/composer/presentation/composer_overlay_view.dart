
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view_web.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/composer_manager.dart';

class ComposerOverlayView extends StatefulWidget {
  const ComposerOverlayView({super.key});

  @override
  State<ComposerOverlayView> createState() => _ComposerOverlayViewState();
}

class _ComposerOverlayViewState extends State<ComposerOverlayView> {

  final ComposerManager _composerManager = Get.find<ComposerManager>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_composerManager.composers.isEmpty) return const SizedBox.shrink();

      return ComposerView(composerId: _composerManager.singleComposerId);
    });
  }
}
