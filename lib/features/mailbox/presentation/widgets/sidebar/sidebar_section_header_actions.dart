import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/styles/sidebar_section_header_action_styles.dart';

/// Lays out the actions of a `LinagoraSidebarSectionHeader` on the design's
/// spacing, which is wider than the gap the header puts between its own
/// entries. Pass it as the single entry of `actions`.
class SidebarSectionHeaderActions extends StatelessWidget {

  final List<Widget> actions;

  const SidebarSectionHeaderActions({
    super.key,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: SidebarSectionHeaderActionStyles.actionSpacing,
      children: actions,
    );
  }
}
