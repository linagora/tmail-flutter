import 'dart:math' as math;

import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/default_close_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:labels/labels.dart';
import 'package:tmail_ui_user/features/labels/presentation/widgets/list_label_with_action_modal.dart';
import 'package:tmail_ui_user/features/labels/presentation/widgets/no_label_yet_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

typedef OnLabelAsToEmailsAction = Function(List<Label> labels);
typedef OnCreateALabelAction = Future<Label?> Function();

class ChooseLabelModal extends StatefulWidget {
  final List<Label> labels;
  final ImagePaths imagePaths;
  final OnLabelAsToEmailsAction onLabelAsToEmailsAction;
  final OnCreateALabelAction onCreateALabelAction;

  const ChooseLabelModal({
    super.key,
    required this.labels,
    required this.imagePaths,
    required this.onLabelAsToEmailsAction,
    required this.onCreateALabelAction,
  });

  @override
  State<ChooseLabelModal> createState() => _ChooseLabelModalState();
}

class _ChooseLabelModalState extends State<ChooseLabelModal> {
  late final ValueNotifier<List<Label>> _labelListNotifier;

  @override
  void initState() {
    super.initState();
    _labelListNotifier = ValueNotifier([...widget.labels]);
  }

  @override
  void dispose() {
    _labelListNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final width = math.min(constraints.maxWidth - 32, 536.0);
        final height = math.min(constraints.maxHeight - 100, 645.0);

        return Center(
          child: Container(
            width: width,
            height: height,
            decoration: _buildModalDecoration(),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                _buildBodyContent(),
                _buildCloseButton(),
              ],
            ),
          ),
        );
      },
    );
  }

  BoxDecoration _buildModalDecoration() {
    return BoxDecoration(
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
    );
  }

  Widget _buildBodyContent() {
    final appLocalizations = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(appLocalizations),
        const Divider(height: 1, color: Colors.black12),
        _buildSubtitle(appLocalizations),
        Expanded(child: _buildListOrEmptyState()),
      ],
    );
  }

  Widget _buildHeader(AppLocalizations appLocalizations) {
    return Container(
      height: 52,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Text(
        appLocalizations.chooseLabel,
        style: ThemeUtils.textStyleHeadingH6().copyWith(color: Colors.black),
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

  Widget _buildListOrEmptyState() {
    return ValueListenableBuilder<List<Label>>(
      valueListenable: _labelListNotifier,
      builder: (context, labels, _) {
        if (labels.isEmpty) {
          return Center(
            child: NoLabelYetWidget(
              imagePaths: widget.imagePaths,
              onCreateALabelAction: _onCreateNewLabel,
            ),
          );
        }

        return ListLabelWithActionModal(
          labels: labels,
          imagePaths: widget.imagePaths,
          onLabelAsToEmailsAction: widget.onLabelAsToEmailsAction,
          onCloseModal: _onCloseModal,
          onCreateALabelAction: _onCreateNewLabel,
        );
      },
    );
  }

  Widget _buildCloseButton() {
    return Positioned(
      top: 0,
      right: 0,
      child: DefaultCloseButtonWidget(
        iconClose: widget.imagePaths.icCloseDialog,
        isAlignTopEnd: false,
        onTapActionCallback: _onCloseModal,
      ),
    );
  }

  Future<void> _onCreateNewLabel() async {
    final newLabel = await widget.onCreateALabelAction();
    if (newLabel != null) {
      _labelListNotifier.value = [..._labelListNotifier.value, newLabel];
    }
  }

  void _onCloseModal() {
    if (mounted) {
      popBack();
    }
  }
}
