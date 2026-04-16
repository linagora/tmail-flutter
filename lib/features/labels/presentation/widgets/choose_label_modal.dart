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
  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return LayoutBuilder(builder: (_, constraints) {
      final currentScreenWidth = constraints.maxWidth;
      final currentScreenHeight = constraints.maxHeight;
      double height = math.min(currentScreenHeight - 100, 645);
      double width = math.min(currentScreenWidth - 32, 536);

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
        width: width,
        height: height,
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
                if (widget.labels.isNotEmpty)
                  Expanded(
                    child: ListLabelWithActionModal(
                      labels: widget.labels,
                      imagePaths: widget.imagePaths,
                      onLabelAsToEmailsAction: widget.onLabelAsToEmailsAction,
                      onCloseModal: _onCloseModal,
                    ),
                  )
                else
                  Expanded(
                    child: Center(
                      child: NoLabelYetWidget(imagePaths: widget.imagePaths),
                    ),
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

  void _onCloseModal() {
    popBack();
  }
}
