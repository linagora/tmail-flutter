import 'dart:math' as math;

import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/default_close_button_widget.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:labels/labels.dart';
import 'package:tmail_ui_user/features/labels/presentation/widgets/label_item_context_menu.dart';
import 'package:tmail_ui_user/features/labels/presentation/widgets/label_list_context_menu.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

typedef OnAddLabelToEmailsCallback = void Function(
  List<EmailId> emailIds,
  Label label,
  bool isSelected,
);

class AddLabelToEmailModal extends StatefulWidget {
  final List<Label> labels;
  final List<Label> emailLabels;
  final List<EmailId> emailIds;
  final OnAddLabelToEmailsCallback onAddLabelToEmailsCallback;
  final OnCreateANewLabelAction onCreateANewLabelAction;

  const AddLabelToEmailModal({
    super.key,
    required this.labels,
    required this.emailLabels,
    required this.emailIds,
    required this.onAddLabelToEmailsCallback,
    required this.onCreateANewLabelAction,
  });

  @override
  State<AddLabelToEmailModal> createState() => _AddLabelToEmailModalState();
}

class _AddLabelToEmailModalState extends State<AddLabelToEmailModal> {
  final ImagePaths _imagePaths = Get.find<ImagePaths>();

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return LayoutBuilder(builder: (_, constraints) {
      final currentScreenWidth = constraints.maxWidth;
      final currentScreenHeight = constraints.maxHeight;
      final maxHeight = math.min(currentScreenHeight, 450).toDouble();

      Widget bodyWidget = Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 2),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 2,
            ),
          ],
        ),
        width: math.min(
          currentScreenWidth - 32,
          554,
        ),
        constraints: BoxConstraints(maxHeight: maxHeight),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 64,
                  alignment: Alignment.center,
                  padding: const EdgeInsetsDirectional.only(
                    start: 32,
                    end: 32,
                    top: 16,
                    bottom: 16,
                  ),
                  child: Text(
                    appLocalizations.addLabel,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: AppColor.m3SurfaceBackground,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (widget.labels.isNotEmpty)
                  Flexible(
                    child: Container(
                      padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: 22,
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: widget.labels.length,
                        itemBuilder: (context, index) {
                          final label = widget.labels[index];
                          final isSelected = widget.emailLabels.contains(label);
                          return LabelItemContextMenu(
                            label: label,
                            imagePaths: _imagePaths,
                            isSelected: isSelected,
                            onSelectLabelAction: _onSelectLabel,
                          );
                        },
                      ),
                    ),
                  ),
                TMailButtonWidget(
                  text: appLocalizations.createANewLabel,
                  icon: _imagePaths.icAddNewFolder,
                  iconColor: AppColor.primaryMain,
                  iconSize: 18,
                  backgroundColor: Colors.transparent,
                  height: 48,
                  flexibleText: true,
                  mainAxisSize: MainAxisSize.min,
                  margin: const EdgeInsetsDirectional.only(
                    bottom: 16,
                    start: 22,
                  ),
                  textStyle: ThemeUtils.textStyleM3LabelLarge(
                    color: AppColor.primaryMain,
                  ),
                  onTapActionCallback: () {
                    popBack();
                    widget.onCreateANewLabelAction();
                  },
                ),
              ],
            ),
            DefaultCloseButtonWidget(
              iconClose: _imagePaths.icCloseDialog,
              onTapActionCallback: _onCloseModal,
            ),
          ],
        ),
      );

      bodyWidget = Center(child: bodyWidget);

      if (PlatformInfo.isMobile) {
        bodyWidget = GestureDetector(
          onTap: _onCloseModal,
          child: Scaffold(
            backgroundColor: AppColor.blackAlpha20,
            body: bodyWidget,
          ),
        );
      }

      return bodyWidget;
    });
  }

  void _onSelectLabel(Label label, bool isSelected) {
    widget.onAddLabelToEmailsCallback(widget.emailIds, label, isSelected);
    popBack();
  }

  void _onCloseModal() {
    popBack();
  }
}
