import 'dart:math' as math;

import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/default_close_button_widget.dart';
import 'package:core/presentation/views/dialog/modal_list_action_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:labels/labels.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/labels/label_list_item.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

typedef OnLabelAsToEmailsAction = Function(List<Label> labels);

class ChooseLabelModal extends StatefulWidget {
  final List<Label> labels;
  final ImagePaths imagePaths;
  final OnLabelAsToEmailsAction onLabelAsToEmailsAction;

  const ChooseLabelModal({
    super.key,
    required this.labels,
    required this.imagePaths,
    required this.onLabelAsToEmailsAction,
  });

  @override
  State<ChooseLabelModal> createState() => _ChooseLabelModalState();
}

class _ChooseLabelModalState extends State<ChooseLabelModal> {
  final ValueNotifier<bool> _addLabelStateNotifier = ValueNotifier(false);
  final ValueNotifier<List<Label>> _selectedLabelStateNotifier =
      ValueNotifier([]);

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return LayoutBuilder(builder: (_, constraints) {
      final currentScreenWidth = constraints.maxWidth;
      final currentScreenHeight = constraints.maxHeight;

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
        constraints: BoxConstraints(maxHeight: currentScreenHeight - 100),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitle(appLocalizations),
                const Divider(height: 1, color: Colors.black12),
                _buildSubtitle(appLocalizations),
                Flexible(child: _buildLabelListView()),
                ValueListenableBuilder(
                  valueListenable: _addLabelStateNotifier,
                  builder: (_, value, __) {
                    return ModalListActionButtonWidget(
                      positiveLabel: appLocalizations.addLabel,
                      negativeLabel: appLocalizations.cancel,
                      padding: const EdgeInsets.symmetric(
                        vertical: 25,
                        horizontal: 25,
                      ),
                      isPositiveActionEnabled: value,
                      onPositiveAction: _onAddLabel,
                      onNegativeAction: _onCloseModal,
                    );
                  },
                ),
              ],
            ),
            DefaultCloseButtonWidget(
              iconClose: widget.imagePaths.icCloseDialog,
              isAlignTopEnd: false,
              onTapActionCallback: _onCloseModal,
            ),
          ],
        ),
      );

      return Center(child: bodyWidget);
    });
  }

  Widget _buildTitle(AppLocalizations appLocalizations) {
    return Container(
      height: 52,
      alignment: Alignment.center,
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 32),
      child: Text(
        appLocalizations.chooseLabel,
        style: ThemeUtils.textStyleHeadingH6().copyWith(
          color: Colors.black,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildSubtitle(AppLocalizations appLocalizations) {
    return Container(
      height: 32,
      alignment: AlignmentDirectional.centerStart,
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
      child: Text(
        appLocalizations.selectLabel,
        style: ThemeUtils.textStyleInter400.copyWith(
          color: AppColor.steelGray400,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildLabelListView() {
    final labelList = widget.labels;
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: labelList.length,
      itemBuilder: (context, index) {
        final label = labelList[index];
        return ValueListenableBuilder(
          valueListenable: _selectedLabelStateNotifier,
          builder: (_, selectedLabels, __) {
            final isSelected = selectedLabels.contains(label);
            return LabelListItem(
              label: label,
              imagePaths: widget.imagePaths,
              padding: const EdgeInsetsDirectional.only(
                start: 4,
                end: 16,
              ),
              enableSelectedIcon: true,
              isSelected: isSelected,
              onOpenLabelCallback: _onToggleLabel,
            );
          },
        );
      },
    );
  }

  void _onToggleLabel(Label selectedLabel) {
    final currentLabels = _selectedLabelStateNotifier.value;

    if (currentLabels.contains(selectedLabel)) {
      _selectedLabelStateNotifier.value =
          currentLabels.where((label) => label.id != selectedLabel.id).toList();
    } else {
      _selectedLabelStateNotifier.value = [...currentLabels, selectedLabel];
    }

    _addLabelStateNotifier.value = _selectedLabelStateNotifier.value.isNotEmpty;
  }

  void _onAddLabel() {
    widget.onLabelAsToEmailsAction(_selectedLabelStateNotifier.value);

    popBack();
  }

  void _onCloseModal() {
    popBack();
  }

  @override
  void dispose() {
    _addLabelStateNotifier.dispose();
    _selectedLabelStateNotifier.dispose();
    super.dispose();
  }
}
