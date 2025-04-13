import 'dart:ui';

import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PullToRefreshWidget extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onNormalRefresh;
  final Future<void> Function() onDeepRefresh;
  final double deepRefreshThreshold;
  final String normalRefreshText;
  final String deepRefreshText;
  final String pullDownToRefreshText;
  final String releaseToText;
  final String pullHarderForText;
  final Icon? pullDownToRefreshIcon;
  final Icon? normalRefreshIcon;
  final Icon? deepRefreshIcon;

  const PullToRefreshWidget({
    Key? key,
    required this.child,
    required this.onNormalRefresh,
    required this.onDeepRefresh,
    this.deepRefreshThreshold = 150.0,
    this.normalRefreshText = 'Refresh',
    this.deepRefreshText = 'Deep refresh',
    this.pullDownToRefreshText = 'Pull down to refresh',
    this.releaseToText = 'Release to',
    this.pullHarderForText = 'Pull harder for',
    this.pullDownToRefreshIcon = const Icon(Icons.arrow_downward, size: 20),
    this.normalRefreshIcon = const Icon(Icons.refresh, size: 20),
    this.deepRefreshIcon = const Icon(Icons.autorenew, size: 20),
  }) : super(key: key);

  @override
  State<PullToRefreshWidget> createState() => _PullToRefreshWidgetState();
}

class _PullToRefreshWidgetState extends State<PullToRefreshWidget> {
  final RefreshController _refreshController = RefreshController();
  double _scrollOffset = 0.0;
  bool _shouldDeepRefresh = false;

  bool get isReachDeepRefresh => _scrollOffset > widget.deepRefreshThreshold;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          final newOffset = notification.metrics.pixels.abs();
          final crossedThreshold =
              (_scrollOffset <= widget.deepRefreshThreshold && newOffset > widget.deepRefreshThreshold) ||
                  (isReachDeepRefresh && newOffset <= widget.deepRefreshThreshold);

          if (crossedThreshold || _scrollOffset != newOffset) {
            setState(() {
              _scrollOffset = newOffset;
              if (notification.dragDetails != null) {
                _shouldDeepRefresh = newOffset > widget.deepRefreshThreshold;
              }
            });
          }
        }
        return false;
      },
      child: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        enablePullUp: false,
        header: CustomHeader(
          builder: (context, mode) {
            if (mode != RefreshStatus.idle &&
                mode != RefreshStatus.canRefresh) {
              return const SizedBox.shrink();
            }

            String? statusText;
            Icon? leadingIcon;

            if (mode == RefreshStatus.idle) {
              statusText = widget.pullDownToRefreshText;
              leadingIcon = widget.pullDownToRefreshIcon;
            } else if (mode == RefreshStatus.canRefresh) {
              statusText = '${widget.releaseToText} ${isReachDeepRefresh ? widget.deepRefreshText : widget.normalRefreshText}';
              leadingIcon = isReachDeepRefresh ? widget.deepRefreshIcon :  widget.normalRefreshIcon;
            }

            return SizedBox(
              height: clampDouble(_scrollOffset, 60, widget.deepRefreshThreshold),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (leadingIcon != null) leadingIcon,
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              statusText ?? '',
                              style: ThemeUtils.textStyleBodyBody1(color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (mode == RefreshStatus.canRefresh && !isReachDeepRefresh)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(top: 4, start: 8, end: 8),
                        child: Text(
                          '${widget.pullHarderForText} ${widget.deepRefreshText.toLowerCase()}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColor.steelGray400,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
          height: widget.deepRefreshThreshold,
        ),
        onRefresh: () {
          if (_shouldDeepRefresh) {
            widget.onDeepRefresh();
          } else {
            widget.onNormalRefresh();
          }
          _refreshController.refreshToIdle();
        },
        child: widget.child,
      ),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}