import 'dart:math' as math;

import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/default_close_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:labels/labels.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/labels/label_list_item.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

typedef OnLabelAsToEmailsAction = Function(Label label);

class ChooseLabelModal extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return LayoutBuilder(builder: (_, constraints) {
      final currentScreenWidth = constraints.maxWidth;
      final currentScreenHeight = constraints.maxHeight;
      final isMobile = currentScreenWidth < ResponsiveUtils.minTabletWidth;

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
                _buildTitle(appLocalizations, isMobile, theme),
                Flexible(child: _buildLabelListView()),
              ],
            ),
            DefaultCloseButtonWidget(
              iconClose: imagePaths.icCloseDialog,
              isAlignTopEnd: false,
              onTapActionCallback: _onCloseModal,
            ),
          ],
        ),
      );

      return Center(child: bodyWidget);
    });
  }

  Widget _buildTitle(
    AppLocalizations appLocalizations,
    bool isMobile,
    ThemeData theme,
  ) {
    return Container(
      height: 64,
      alignment: Alignment.center,
      padding: EdgeInsetsDirectional.only(
        start: 32,
        end: 32,
        top: 16,
        bottom: isMobile ? 0 : 16,
      ),
      child: Text(
        appLocalizations.chooseLabel,
        style: theme.textTheme.headlineSmall?.copyWith(
          color: AppColor.m3SurfaceBackground,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildLabelListView() {
    final labelList = labels;
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: labelList.length,
      itemBuilder: (context, index) {
        final label = labelList[index];
        return LabelListItem(
          label: label,
          imagePaths: imagePaths,
          onOpenLabelCallback: onLabelAsToEmailsAction,
        );
      },
    );
  }

  void _onCloseModal() {
    popBack();
  }
}
