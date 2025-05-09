import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/app_linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/app_dashboard/app_list_dashboard_item.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class AppGridView extends StatefulWidget {

  final List<AppLinagoraEcosystem> linagoraApps;

  const AppGridView({super.key, required this.linagoraApps});

  @override
  State<AppGridView> createState() => _AppGridViewState();
}

class _AppGridViewState extends State<AppGridView> {
  final ValueNotifier<bool> _isCollapsedNotifier = ValueNotifier<bool>(true);
  final _imagePaths = Get.find<ImagePaths>();

  @override
  void dispose() {
    _isCollapsedNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsetsDirectional.only(
          start: 26,
          end: 4,
          top: 4,
          bottom: 4,
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              _imagePaths.icAppDashboard,
              colorFilter: AppColor.primaryColor.asFilter(),
              width: 20,
              height: 20,
              fit: BoxFit.fill,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  AppLocalizations.of(context).appGridTittle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
                    color: AppColor.colorTextButton,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            ),
            ValueListenableBuilder(
              valueListenable: _isCollapsedNotifier,
              builder: (context, isCollapsed, child) {
                return TMailButtonWidget.fromIcon(
                  key: const Key('toggle_app_grid_button'),
                  icon: _getCollapseIcon(context, isCollapsed),
                  iconColor: isCollapsed
                    ? AppColor.colorIconUnSubscribedMailbox
                    : AppColor.primaryColor,
                  iconSize: 32,
                  padding: const EdgeInsets.all(3),
                  backgroundColor: Colors.transparent,
                  tooltipMessage: AppLocalizations.of(context).appGridTittle,
                  onTapActionCallback: _toggleAppGridDashboard,
                );
              },
            ),
          ],
        ),
      ),
      AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        child: ValueListenableBuilder(
          valueListenable: _isCollapsedNotifier,
          builder: (context, isCollapsed, child) {
            if (isCollapsed) {
              return const Offstage();
            } else {
              return child ?? const Offstage();
            }
          },
          child: ListView.builder(
            key: const Key('list_view_app_grid'),
            shrinkWrap: true,
            primary: false,
            padding: const EdgeInsetsDirectional.only(
              start: 16,
              end: 16,
              bottom: 8,
            ),
            itemCount: widget.linagoraApps.length,
            itemBuilder: (context, index) {
              return AppListDashboardItem(
                app: widget.linagoraApps[index],
                imagePaths: _imagePaths,
              );
            },
          ),
        ),
      ),
      const Divider(color: AppColor.colorDividerMailbox, height: 1)
    ]);
  }

  String _getCollapseIcon(BuildContext context, bool isCollapsed) {
    if (isCollapsed) {
      return DirectionUtils.isDirectionRTLByLanguage(context)
        ? _imagePaths.icArrowLeft
        : _imagePaths.icArrowRight;
    } else {
      return _imagePaths.icArrowBottom;
    }
  }

  void _toggleAppGridDashboard() {
    _isCollapsedNotifier.value = !_isCollapsedNotifier.value;
  }
}
