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
  final String refreshingText;
  final String pullingText;
  final String releaseToText;
  final String pullFurtherForText;
  final String pullHarderForText;
  final Icon? normalRefreshIcon;
  final Icon? deepRefreshIcon;

  const PullToRefreshWidget({
    Key? key,
    required this.child,
    required this.onNormalRefresh,
    required this.onDeepRefresh,
    this.deepRefreshThreshold = 200.0,
    this.normalRefreshText = 'Refresh',
    this.deepRefreshText = 'Deep refresh',
    this.pullDownToRefreshText = 'Pull down to refresh',
    this.refreshingText = 'Refreshing',
    this.pullingText = 'Pulling',
    this.releaseToText = 'Release to',
    this.pullFurtherForText = 'Pull further for',
    this.pullHarderForText = 'Pull harder for',
    this.normalRefreshIcon = const Icon(Icons.refresh, size: 20),
    this.deepRefreshIcon = const Icon(Icons.autorenew, size: 20),
  }) : super(key: key);

  @override
  State<PullToRefreshWidget> createState() => _PullToRefreshWidgetState();
}

class _PullToRefreshWidgetState extends State<PullToRefreshWidget> {
  final RefreshController _refreshController = RefreshController();
  double _scrollOffset = 0.0;
  String? _lastAction;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          setState(() {
            _scrollOffset = notification.metrics.pixels;
          });
        }
        return false;
      },
      child: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        enablePullUp: false,
        header: CustomHeader(
          builder: (context, mode) {
            String statusText;
            Icon? leadingIcon;

            if (mode == RefreshStatus.idle) {
              statusText = widget.pullDownToRefreshText;
              leadingIcon = widget.normalRefreshIcon;
            } else if (mode == RefreshStatus.canRefresh) {
              if (_scrollOffset.abs() > widget.deepRefreshThreshold) {
                statusText = '${widget.releaseToText} ${widget.deepRefreshText}';
                leadingIcon = widget.deepRefreshIcon;
              } else {
                statusText = '${widget.releaseToText} ${widget.normalRefreshText}';
                leadingIcon = widget.normalRefreshIcon;
              }
            } else if (mode == RefreshStatus.refreshing || mode == RefreshStatus.completed) {
              statusText = '${widget.refreshingText}...';
              leadingIcon = _lastAction == widget.deepRefreshText
                  ? widget.deepRefreshIcon
                  : widget.normalRefreshIcon;
            } else {
              statusText = '${widget.pullingText}...';
              leadingIcon = widget.normalRefreshIcon;
            }

            return SizedBox(
              height: clampDouble(_scrollOffset.abs(), 60, widget.deepRefreshThreshold),
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
                              statusText,
                              style: ThemeUtils.textStyleBodyBody1(color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (mode == RefreshStatus.canRefresh)
                      Padding(
                        padding: const EdgeInsetsDirectional.only(top: 4, start: 8, end: 8),
                        child: Text(
                          _scrollOffset.abs() > widget.deepRefreshThreshold
                              ? '${widget.pullFurtherForText} ${widget.deepRefreshText.toLowerCase()}'
                              : '${widget.pullHarderForText} ${widget.deepRefreshText.toLowerCase()}',
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
          if (_scrollOffset.abs() > widget.deepRefreshThreshold) {
            _lastAction = widget.deepRefreshText;
            widget.onDeepRefresh();
          } else {
            _lastAction = widget.normalRefreshText;
            widget.onNormalRefresh();
          }
          _refreshController.refreshCompleted();
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