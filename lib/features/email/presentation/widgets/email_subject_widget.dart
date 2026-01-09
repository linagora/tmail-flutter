import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:labels/model/label.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/email_subject_styles.dart';
import 'package:tmail_ui_user/features/labels/presentation/widgets/label_widget.dart';

typedef OnDeleteLabelAction = void Function(Label label);

class EmailSubjectWidget extends StatefulWidget {
  final PresentationEmail presentationEmail;
  final ImagePaths imagePaths;
  final bool isMobileResponsive;
  final List<Label>? labels;
  final OnDeleteLabelAction? onDeleteLabelAction;

  const EmailSubjectWidget({
    super.key,
    required this.presentationEmail,
    required this.imagePaths,
    this.isMobileResponsive = false,
    this.labels,
    this.onDeleteLabelAction,
  });

  @override
  State<EmailSubjectWidget> createState() => _EmailSubjectWidgetState();
}

class _EmailSubjectWidgetState extends State<EmailSubjectWidget> {
  String get _title => widget.presentationEmail.getEmailTitle();

  bool get _hasLabels => _currentLabels?.isNotEmpty == true;

  List<Label>? _currentLabels;

  @override
  void initState() {
    super.initState();
    _currentLabels = widget.labels;
  }

  @override
  Widget build(BuildContext context) {
    final padding = widget.isMobileResponsive
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
    return _currentLabels
            ?.map((label) => LabelWidget.create(
                  label: label,
                  removeLabelAction: _buildRemoveLabelWidget(label),
                  padding: const EdgeInsetsDirectional.only(start: 4, end: 2),
                ))
            .toList() ??
        const [];
  }

  Widget _buildRemoveLabelWidget(Label label) {
    return TMailButtonWidget.fromIcon(
      icon: widget.imagePaths.icDeleteSelection,
      iconSize: 8,
      iconColor: Colors.white,
      padding: const EdgeInsets.all(6),
      backgroundColor: Colors.transparent,
      onTapActionCallback: () => _onDeleteLabelAction(label),
    );
  }

  void _onDeleteLabelAction(Label labelRemoved) {
    if (mounted) {
      setState(() {
        _currentLabels = _currentLabels
            ?.where((label) => label.id != labelRemoved.id)
            .toList();
      });
      widget.onDeleteLabelAction?.call(labelRemoved);
    }
  }
}
