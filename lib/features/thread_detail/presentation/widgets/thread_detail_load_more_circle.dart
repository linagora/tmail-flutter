import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/loading/cupertino_loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/instance_manager.dart';
import 'package:get/state_manager.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_emails_by_ids_state.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';

class ThreadDetailLoadMoreCircle extends StatefulWidget {
  const ThreadDetailLoadMoreCircle({
    super.key,
    required this.count,
    required this.onTap,
    required this.imagePaths,
    required this.loadingIndex,
  });

  final int count;
  final VoidCallback onTap;
  final ImagePaths imagePaths;
  final int loadingIndex;

  @override
  State<ThreadDetailLoadMoreCircle> createState() => _ThreadDetailLoadMoreCircleState();
}

class _ThreadDetailLoadMoreCircleState extends State<ThreadDetailLoadMoreCircle> {
  final _isHover = ValueNotifier(false);
  final threadDetailController = Get.find<ThreadDetailController>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();

  @override
  void dispose() {
    _isHover.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobileResponsive = _responsiveUtils.isMobile(context);

    return Container(
      padding: EdgeInsets.symmetric(vertical: isMobileResponsive ? 12 : 16),
      color: Colors.white,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Container(
            height: 8,
            decoration: const BoxDecoration(
              border: Border.symmetric(horizontal: BorderSide(
                color: AppColor.colorDividerEmailView,
                width: 0.5,
              )),
            ),
          ),
          InkWell(
            onTap: widget.onTap,
            onHover: (value) => _isHover.value = value,
            child: Container(
              margin: EdgeInsetsDirectional.only(
                start: isMobileResponsive ? 12 : 16,
              ),
              width: isMobileResponsive ? 44 : 32,
              height: isMobileResponsive ? 44 : 32,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColor.colorDividerEmailView,
                  width: 0.5,
                ),
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              alignment: Alignment.center,
              child: ValueListenableBuilder(
                valueListenable: _isHover,
                builder: (context, isHover, child) {
                  return Obx(() {
                    final isLoading = threadDetailController.viewState.value.fold(
                      (failure) => false,
                      (success) => success is GettingEmailsByIds &&
                        success.loadingIndex == widget.loadingIndex,
                    );

                    if (isLoading) {
                      return SizedBox(
                        width: isMobileResponsive ? 24 : 16,
                        height: isMobileResponsive ? 24 : 16,
                        child: const CupertinoLoadingWidget(),
                      );
                    }

                    if (isHover) {
                      return child ?? const SizedBox.shrink();
                    }

                    return Text(
                      '${widget.count}',
                      style: ThemeUtils.textStyleBodyBody3().copyWith(
                        color: Colors.black,
                        fontSize: isMobileResponsive ? 14 : 13,
                        height: isMobileResponsive ? 18 / 14 : 16 / 13,
                      ),
                    );
                  });
                },
                child: SvgPicture.asset(
                  widget.imagePaths.icExpandArrows,
                  width: isMobileResponsive ? 20 : 16,
                  height: isMobileResponsive ? 20 : 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}