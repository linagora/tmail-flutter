import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/composer_manager.dart';
import 'package:tmail_ui_user/features/composer/presentation/utils/composer_utils.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/hidden_composer_list_view_overlay.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class ExpandComposerButton extends StatefulWidget {

  final int countComposerHidden;
  final OnRemoveHiddenComposerItem onRemoveHiddenComposerItem;
  final OnShowComposerAction onShowComposerAction;

  const ExpandComposerButton({
    super.key,
    required this.countComposerHidden,
    required this.onRemoveHiddenComposerItem,
    required this.onShowComposerAction,
  });

  @override
  State<ExpandComposerButton> createState() => _ExpandComposerButtonState();
}

class _ExpandComposerButtonState extends State<ExpandComposerButton> {

  late final ComposerManager _composerManager;
  late final ImagePaths _imagePaths;
  late final ResponsiveUtils _responsiveUtils;

  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _composerManager = Get.find<ComposerManager>();
    _imagePaths = Get.find<ImagePaths>();
    _responsiveUtils = Get.find<ResponsiveUtils>();
  }

  @override
  Widget build(BuildContext context) {
    final expandButton = PointerInterceptor(
      child: Card(
        elevation: 16,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12))
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => setState(() => _visible = !_visible),
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          child: Container(
            color: Colors.white,
            width: ComposerUtils.composerExpandMoreButtonMaxWidth,
            height: ComposerUtils.composerExpandMoreButtonMaxHeight,
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 8),
            child: Row(
              children: [
                SvgPicture.asset(
                  _visible
                    ? _imagePaths.icDoubleArrowDown
                    : _imagePaths.icDoubleArrowUp,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _visible
                      ? AppLocalizations.of(context).hideAll
                      : '+${widget.countComposerHidden} ${AppLocalizations.of(context).more.toLowerCase()}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ]
            )
          ),
        ),
      ),
    );

    return PortalTarget(
        visible: _visible,
        portalFollower: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _visible = false),
        ),
        child: PortalTarget(
          anchor: const Aligned(
            follower: Alignment.bottomLeft,
            target: Alignment.topLeft,
            offset:  Offset(0.0, 0.0),
          ),
          portalFollower: HiddenComposerListViewOverlay(
            composerManager: _composerManager,
            imagePaths: _imagePaths,
            responsiveUtils: _responsiveUtils,
            onRemoveHiddenComposerItem: (controller) {
              widget.onRemoveHiddenComposerItem(controller);
              setState(() => _visible = false);
            },
            onShowComposerAction: (composerId) {
              widget.onShowComposerAction(composerId);
              setState(() => _visible = false);
            }
          ),
          visible: _visible,
          child: expandButton,
        )
    );
  }
}