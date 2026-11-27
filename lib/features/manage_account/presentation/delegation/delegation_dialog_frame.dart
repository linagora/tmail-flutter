import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

/// The modal shell of the Settings › Delegation dialogs: title, close, scrollable content and a fixed footer.
/// While [isBusy], nothing can dismiss it.
class DelegationDialogFrame extends StatelessWidget {
  static final LinagoraDialogStyle tokens = LinagoraDialogStyle.material();
  static const EdgeInsetsGeometry _headerPadding = EdgeInsetsDirectional.symmetric(horizontal: 32, vertical: 16);

  final String title;
  final bool isBusy;
  final Widget content;
  final Widget footer;

  const DelegationDialogFrame({
    super.key,
    required this.title,
    required this.isBusy,
    required this.content,
    required this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isBusy,
      child: Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(tokens.surfaceRadius)),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: tokens.maxWidth),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(AppLocalizations.of(context)),
              Flexible(
                child: SingleChildScrollView(padding: tokens.contentPadding, child: content),
              ),
              Divider(height: 1, color: tokens.dividerColor),
              footer,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Padding(
      padding: _headerPadding,
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: tokens.titleTextStyle),
          ),
          IconButton(
            tooltip: l10n.close,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints.tight(Size.square(tokens.iconButtonSize)),
            style: const ButtonStyle(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            onPressed: isBusy ? null : popBack,
            icon: SvgPicture.asset(Get.find<ImagePaths>().icCloseDialog, width: 24, height: 24),
          ),
        ],
      ),
    );
  }
}
