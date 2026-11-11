import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/delegation/presentation/widgets/workplace_account_switcher.dart';

/// Cozy dashboard header: [search] at the start, then the account switcher chip
/// and [trailing] at the end.
class CozyHeaderRow extends StatelessWidget {
  const CozyHeaderRow({super.key, required this.search, required this.trailing});

  final Widget search;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        search,
        // Bound the chip so DS Flexible ellipsis can shrink long "Viewing …" labels.
        const Expanded(
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: WorkplaceAccountSwitcher(),
          ),
        ),
        trailing,
      ],
    );
  }
}
