import 'package:flutter/material.dart';
import 'package:labels/model/label.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/email_subject_styles.dart';
import 'package:tmail_ui_user/features/labels/presentation/widgets/label_widget.dart';

class EmailSubjectWidget extends StatelessWidget {
  final PresentationEmail presentationEmail;
  final bool isMobileResponsive;
  final List<Label>? labels;

  const EmailSubjectWidget({
    super.key,
    required this.presentationEmail,
    this.isMobileResponsive = false,
    this.labels,
  });

  String get _title => presentationEmail.getEmailTitle();

  bool get _hasLabels => labels?.isNotEmpty == true;

  @override
  Widget build(BuildContext context) {
    final padding = isMobileResponsive
        ? EmailSubjectStyles.mobilePadding
        : EmailSubjectStyles.padding;

    if (_title.isEmpty && !_hasLabels) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: padding,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    final hasTitle = _title.isNotEmpty;
    final hasLabels = _hasLabels;

    if (hasTitle && !hasLabels) {
      return _buildTitle();
    }

    if (!hasTitle && hasLabels) {
      return _buildLabels();
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _buildTitle(),
        ..._buildLabelWidgets(),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      _title,
      style: EmailSubjectStyles.textStyle,
      maxLines: EmailSubjectStyles.maxLines,
    );
  }

  Widget _buildLabels() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: _buildLabelWidgets(),
    );
  }

  List<Widget> _buildLabelWidgets() {
    return labels?.map(LabelWidget.create).toList() ?? const [];
  }
}
