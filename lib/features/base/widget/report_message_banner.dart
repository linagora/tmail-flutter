import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ReportMessageBanner extends StatelessWidget {
  final ImagePaths imagePaths;
  final String message;
  final String positiveName;
  final VoidCallback onPositiveAction;
  final VoidCallback onNegativeAction;
  final bool isDesktop;
  final EdgeInsetsGeometry? margin;

  const ReportMessageBanner({
    super.key,
    required this.imagePaths,
    required this.message,
    required this.positiveName,
    required this.onNegativeAction,
    required this.onPositiveAction,
    this.isDesktop = true,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final closeButton = TMailButtonWidget.fromIcon(
      icon: imagePaths.icCloseDialog,
      iconSize: 24,
      iconColor: AppColor.m3Tertiary,
      padding: const EdgeInsets.all(5),
      backgroundColor: Colors.transparent,
      onTapActionCallback: onNegativeAction,
    );

    late Widget bodyBanner;

    if (isDesktop) {
      bodyBanner = Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 40),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    imagePaths.icInfoCircleOutline,
                    width: 20,
                    height: 20,
                    fit: BoxFit.fill,
                    colorFilter: AppColor.steelGray200.asFilter(),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      message,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: AppColor.steelGray400,
                          ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  TMailButtonWidget.fromText(
                    text: positiveName,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    backgroundColor: Colors.transparent,
                    textStyle: ThemeUtils.textStyleInter700(
                      color: AppColor.blue700,
                      fontSize: 14,
                    ),
                    onTapActionCallback: onPositiveAction,
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: closeButton,
          ),
        ],
      );
    } else {
      bodyBanner = Row(
        children: [
          SvgPicture.asset(
            imagePaths.icInfoCircleOutline,
            width: 20,
            height: 20,
            fit: BoxFit.fill,
            colorFilter: AppColor.steelGray200.asFilter(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: AppColor.steelGray400,
                        ),
                  ),
                ),
                const SizedBox(width: 4),
                TMailButtonWidget.fromText(
                  text: positiveName,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  backgroundColor: Colors.transparent,
                  textStyle: ThemeUtils.textStyleInter700(
                    color: AppColor.blue700,
                    fontSize: 14,
                  ),
                  onTapActionCallback: onPositiveAction,
                )
              ],
            ),
          ),
          const SizedBox(width: 12),
          closeButton,
        ],
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      padding: const EdgeInsetsDirectional.only(start: 16, end: 12),
      margin: margin,
      height: _bannerHeight,
      child: bodyBanner,
    );
  }

  Color get _backgroundColor => isDesktop
      ? AppColor.lightGrayEAEDF2
      : AppColor.m3LayerDarkOutline.withOpacity(0.08);

  double get _bannerHeight => isDesktop ? 44 : 52;
}
