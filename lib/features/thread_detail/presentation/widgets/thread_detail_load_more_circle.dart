import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ThreadDetailLoadMoreCircle extends StatefulWidget {
  const ThreadDetailLoadMoreCircle({
    super.key,
    required this.count,
    required this.onTap,
    required this.imagePaths,
    required this.isLoading,
  });

  final int count;
  final VoidCallback onTap;
  final ImagePaths imagePaths;
  final bool isLoading;

  @override
  State<ThreadDetailLoadMoreCircle> createState() => _ThreadDetailLoadMoreCircleState();
}

class _ThreadDetailLoadMoreCircleState extends State<ThreadDetailLoadMoreCircle> {
  final _isHover = ValueNotifier(false);

  @override
  void dispose() {
    _isHover.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Container(
            height: 8,
            decoration: const BoxDecoration(
              border: Border.symmetric(horizontal: BorderSide(
                color: AppColor.colorDividerEmailView,
              )),
            ),
          ),
          InkWell(
            onTap: widget.onTap,
            onHover: (value) => _isHover.value = value,
            child: Container(
              margin: const EdgeInsetsDirectional.only(start: 16),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColor.colorDividerEmailView,
                ),
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              alignment: Alignment.center,
              child: ValueListenableBuilder(
                valueListenable: _isHover,
                builder: (context, isHover, child) {
                  if (widget.isLoading) {
                    return const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: AppColor.lightIconTertiary,
                      ),
                    );
                  }

                  if (isHover) {
                    return child ?? const SizedBox.shrink();
                  }

                  return Text(
                    '${widget.count}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.normal,
                      height: 24 / 16,
                      letterSpacing: -0.1,
                    ),
                  );
                },
                child: SvgPicture.asset(widget.imagePaths.icExpandArrows),
              ),
            ),
          ),
        ],
      ),
    );
  }
}