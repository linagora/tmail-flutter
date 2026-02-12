import 'package:flutter/material.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/dialog/confirm_dialog_button.dart';
import 'package:core/presentation/views/dialog/modal_list_action_button_widget.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:labels/model/label.dart';
import 'package:tmail_ui_user/features/labels/presentation/widgets/choose_label_modal.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/labels/label_list_item.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class ListLabelWithActionModal extends StatefulWidget {
  final List<Label> labels;
  final ImagePaths imagePaths;
  final OnLabelAsToEmailsAction onLabelAsToEmailsAction;
  final VoidCallback onCloseModal;
  final VoidCallback onCreateALabelAction;

  const ListLabelWithActionModal({
    super.key,
    required this.labels,
    required this.imagePaths,
    required this.onLabelAsToEmailsAction,
    required this.onCloseModal,
    required this.onCreateALabelAction,
  });

  @override
  State<ListLabelWithActionModal> createState() =>
      _ListLabelWithActionModalState();
}

class _ListLabelWithActionModalState extends State<ListLabelWithActionModal> {
  final ValueNotifier<Set<Id>> _selectedIdsNotifier = ValueNotifier({});

  @override
  void dispose() {
    _selectedIdsNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _buildLabelListView()),
        _buildBottomActionButtons(),
      ],
    );
  }

  Widget _buildLabelListView() {
    return ListView.builder(
      itemCount: widget.labels.length + 1,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        if (index == widget.labels.length) {
          return _buildCreateLabelButton();
        }
        return _buildLabelItem(widget.labels[index]);
      },
    );
  }

  Widget _buildLabelItem(Label label) {
    return ValueListenableBuilder<Set<Id>>(
      valueListenable: _selectedIdsNotifier,
      builder: (_, selectedIds, __) {
        final isSelected = selectedIds.contains(label.id);
        return LabelListItem(
          label: label,
          imagePaths: widget.imagePaths,
          padding: const EdgeInsetsDirectional.only(start: 4, end: 16),
          enableSelectedIcon: true,
          isSelected: isSelected,
          onOpenLabelCallback: _onToggleLabel,
        );
      },
    );
  }

  Widget _buildCreateLabelButton() {
    return Container(
      height: 36,
      alignment: Alignment.centerLeft,
      margin:
          const EdgeInsetsDirectional.only(start: 4, end: 8, top: 4, bottom: 8),
      child: ConfirmDialogButton(
        label: AppLocalizations.of(context).createALabel,
        backgroundColor: Colors.transparent,
        textColor: AppColor.primaryMain,
        padding: const EdgeInsetsDirectional.only(start: 10, end: 16),
        icon: widget.imagePaths.icAddIdentity,
        onTapAction: widget.onCreateALabelAction,
      ),
    );
  }

  Widget _buildBottomActionButtons() {
    final localizations = AppLocalizations.of(context);
    return ValueListenableBuilder<Set<Id>>(
      valueListenable: _selectedIdsNotifier,
      builder: (_, selectedIds, __) {
        return ModalListActionButtonWidget(
          positiveLabel: localizations.addLabel,
          negativeLabel: localizations.cancel,
          padding: const EdgeInsets.all(25),
          isPositiveActionEnabled: selectedIds.isNotEmpty,
          onPositiveAction: _onConfirmAction,
          onNegativeAction: widget.onCloseModal,
        );
      },
    );
  }

  void _onToggleLabel(Label label) {
    final currentIds = Set<Id>.from(_selectedIdsNotifier.value);
    final labelId = label.id;
    if (labelId == null) return;
    if (currentIds.contains(labelId)) {
      currentIds.remove(labelId);
    } else {
      currentIds.add(labelId);
    }
    _selectedIdsNotifier.value = currentIds;
  }

  void _onConfirmAction() {
    final selectedLabels = widget.labels
        .where((label) => _selectedIdsNotifier.value.contains(label.id))
        .toList();

    widget.onLabelAsToEmailsAction(selectedLabels);
    popBack();
  }
}
