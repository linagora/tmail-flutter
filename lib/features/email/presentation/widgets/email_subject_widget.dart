import 'package:flutter/material.dart';
import 'package:labels/model/label.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/email_subject_styles.dart';
import 'package:tmail_ui_user/features/labels/presentation/widgets/label_widget.dart';

class EmailSubjectWidget extends StatelessWidget {
  final PresentationEmail presentationEmail;
  final bool isMobileResponsive;
  final bool isWebDesktop;
  final List<Label>? labels;

  const EmailSubjectWidget({
    super.key,
    required this.presentationEmail,
    this.isMobileResponsive = false,
    this.isWebDesktop = false,
    this.labels,
  });

  bool get _hasLabels => labels?.isNotEmpty == true;

  String get _title => presentationEmail.getEmailTitle();

  @override
  Widget build(BuildContext context) {
    final padding = isMobileResponsive
        ? EmailSubjectStyles.mobilePadding
        : EmailSubjectStyles.padding;

    if (_title.isEmpty) {
      return _hasLabels && isWebDesktop
          ? Padding(
              padding: padding,
              child: _buildLabelsOnly(),
            )
          : const SizedBox.shrink();
    }

    if (_hasLabels && isWebDesktop) {
      return Padding(
        padding: padding,
        child: _buildTitleWithLabels(),
      );
    }

    return Padding(
      padding: padding,
      child: _buildTitle(),
    );
  }

  Widget _buildTitle() {
    return Text(
      _title,
      style: EmailSubjectStyles.textStyle,
      maxLines: EmailSubjectStyles.maxLines,
    );
  }

  Widget _buildLabelsOnly() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: labels!.map(LabelWidget.create).toList(),
    );
  }

  Widget _buildTitleWithLabels() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _buildTitle(),
        ...labels!.map(LabelWidget.create),
      ],
    );
  }
}
