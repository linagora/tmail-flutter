import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/dialog/modal_list_action_button_widget.dart';
import 'package:flutter/material.dart';
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

  const ListLabelWithActionModal({
    super.key,
    required this.labels,
    required this.imagePaths,
    required this.onLabelAsToEmailsAction,
    required this.onCloseModal,
  });

  @override
  State<ListLabelWithActionModal> createState() =>
      _ListLabelWithActionModalState();
}

class _ListLabelWithActionModalState extends State<ListLabelWithActionModal> {
  final ValueNotifier<bool> _addLabelStateNotifier = ValueNotifier(false);
  final ValueNotifier<List<Label>> _selectedLabelStateNotifier =
      ValueNotifier([]);

  @override
  Widget build(BuildContext context) {
    final labelList = widget.labels;
    final appLocalizations = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListView.builder(
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
          ),
        ),
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
              onNegativeAction: widget.onCloseModal,
            );
          },
        ),
      ],
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

  @override
  void dispose() {
    _addLabelStateNotifier.dispose();
    _selectedLabelStateNotifier.dispose();
    super.dispose();
  }
}
