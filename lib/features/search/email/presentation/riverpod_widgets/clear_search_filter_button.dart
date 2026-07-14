import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tmail_ui_user/features/search/email/domain/notifier/search_filter_notifier.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

/// Clear-filter button shown only when a filter is applied.
class ClearSearchFilterButton extends ConsumerWidget {
  const ClearSearchFilterButton({super.key, required this.onClearFilter});

  final VoidCallback onClearFilter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isApplied = ref.watch(
      searchFilterProvider.select((filter) => filter.isApplied),
    );
    if (!isApplied) return const SizedBox.shrink();

    return TMailButtonWidget.fromText(
      text: AppLocalizations.of(context).clearFilter,
      backgroundColor: Colors.transparent,
      margin: const EdgeInsetsDirectional.only(start: 8, top: 6, end: 8),
      borderRadius: 10,
      textStyle: ThemeUtils.defaultTextStyleInterFont.copyWith(
        color: AppColor.primaryColor,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      onTapActionCallback: onClearFilter,
    );
  }
}
