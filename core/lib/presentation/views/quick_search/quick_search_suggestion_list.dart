import 'dart:async';
import 'dart:math';

import 'package:core/presentation/views/quick_search/quick_search_action_define.dart';
import 'package:core/presentation/views/quick_search/quick_search_suggestion_box.dart';
import 'package:core/presentation/views/quick_search/quick_search_suggestion_box_decoration.dart';
import 'package:core/utils/app_logger.dart';
import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

class QuickSearchSuggestionList<T, P, R> extends StatefulWidget {
  final QuickSearchSuggestionsBox? suggestionsBox;
  final TextEditingController? controller;
  final bool getImmediateSuggestions;
  final SuggestionSelectionCallback<T>? onSuggestionSelected;
  final SuggestionsCallback<T>? suggestionsCallback;
  final ItemBuilder<T>? itemBuilder;
  final ScrollController? scrollController;
  final QuickSearchSuggestionsBoxDecoration? decoration;
  final Duration? debounceDuration;
  final WidgetBuilder? loadingBuilder;
  final WidgetBuilder? noItemsFoundBuilder;
  final ErrorBuilder? errorBuilder;
  final AnimationTransitionBuilder? transitionBuilder;
  final Duration? animationDuration;
  final double? animationStart;
  final AxisDirection? direction;
  final bool? hideOnLoading;
  final bool? hideOnEmpty;
  final bool? hideOnError;
  final bool? keepSuggestionsOnLoading;
  final int? minCharsForSuggestions;
  final List<dynamic>? listActionButton;
  final ButtonActionBuilder? actionButtonBuilder;
  final ButtonActionCallback? buttonActionCallback;
  final ButtonActionBuilder? buttonShowAllResult;
  final Widget? titleHeaderRecent;
  final ItemBuilder<R>? itemRecentBuilder;
  final FetchRecentActionCallback<R>? fetchRecentActionCallback;
  final RecentSelectionCallback<R>? onRecentSelected;
  final EdgeInsets? listActionPadding;
  final bool hideSuggestionsBox;
  final bool isDirectionRTL;
  final int? minInputLengthAutocomplete;
  final ItemBuilder<P>? contactSuggestionBuilder;
  final SuggestionsCallback<P>? contactSuggestionCallback;
  final SuggestionSelectionCallback<P>? onContactSuggestionSelected;

  const QuickSearchSuggestionList({
    super.key,
    required this.suggestionsBox,
    this.controller,
    this.getImmediateSuggestions = false,
    this.onSuggestionSelected,
    this.suggestionsCallback,
    this.itemBuilder,
    this.scrollController,
    this.decoration,
    this.debounceDuration,
    this.loadingBuilder,
    this.noItemsFoundBuilder,
    this.errorBuilder,
    this.transitionBuilder,
    this.animationDuration,
    this.animationStart,
    this.direction,
    this.hideOnLoading,
    this.hideOnEmpty,
    this.hideOnError,
    this.keepSuggestionsOnLoading,
    this.minCharsForSuggestions,
    this.listActionButton,
    this.actionButtonBuilder,
    this.buttonActionCallback,
    this.buttonShowAllResult,
    this.titleHeaderRecent,
    this.itemRecentBuilder,
    this.fetchRecentActionCallback,
    this.onRecentSelected,
    this.listActionPadding,
    this.hideSuggestionsBox = false,
    this.isDirectionRTL = false,
    this.minInputLengthAutocomplete,
    this.contactSuggestionBuilder,
    this.contactSuggestionCallback,
    this.onContactSuggestionSelected,
  });

  @override
  QuickSearchSuggestionListState<T, P, R> createState() =>
      QuickSearchSuggestionListState<T, P, R>();
}

class QuickSearchSuggestionListState<T, P, R>
    extends State<QuickSearchSuggestionList<T, P, R>>
    with SingleTickerProviderStateMixin {
  Iterable<T>? _suggestions;
  Iterable<R>? _recentItems;
  Iterable<P>? _contacts;
  late bool _suggestionsValid;
  bool? _isLoading;
  AnimationController? _animationController;
  String? _lastTextValue;
  late final ScrollController _scrollController =
      widget.scrollController ?? ScrollController();
  late final Debouncer<String> _deBouncerSuggestion;
  late final StreamSubscription<String> _deBouncerSuggestionStreamSubscriptions;

  Future<Iterable<R>?> _getListRecent(String queryString) async {
    try {
      return widget.fetchRecentActionCallback?.call(queryString);
    } catch (e) {
      logError('SuggestionsListState::_getRecent:Exception = $e');
      return null;
    }
  }

  Future<Iterable<P>?> _getListContact(String queryString) async {
    try {
      return widget.contactSuggestionCallback?.call(queryString);
    } catch (e) {
      logError('SuggestionsListState::_getListContact:Exception = $e');
      return null;
    }
  }

  Future<Iterable<T>?> _getListSuggestion(String queryString) async {
    try {
      return widget.suggestionsCallback?.call(queryString);
    } catch (e) {
      logError('SuggestionsListState::_getListSuggestion:Exception = $e');
      return null;
    }
  }

  Future<void> _handleDebounceTimeListener(String queryString) async {
    log('QuickSearchSuggestionListState::_handleDebounceTimeListener:queryString = $queryString | minCharsForSuggestions = ${widget.minCharsForSuggestions}');
    if (!mounted) return;

    if (_isLoading == true) return;

    if (widget.minCharsForSuggestions != null &&
        queryString.length <= widget.minCharsForSuggestions!) {
      setState(() {
        _isLoading = true;
      });

      final recentItems = await _getListRecent(queryString);

      setState(() {
        _isLoading = false;
        _suggestions = null;
        _contacts = null;
        _recentItems = recentItems;
        _suggestionsValid = true;
      });
    } else {
      await invalidateSuggestions();
    }
  }

  Future<void> _textInputControllerListener() async {
    // If we came here because of a change in selected text, not because of
    // actual change in text
    final queryString = widget.controller!.text.trim();
    log('QuickSearchSuggestionListState::_textInputControllerListener:queryString = $queryString | _lastTextValue = $_lastTextValue');
    if (queryString == _lastTextValue) return;

    _lastTextValue = queryString;
    _deBouncerSuggestion.value = queryString;
  }

  @override
  void didUpdateWidget(QuickSearchSuggestionList<T, P, R> oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.controller!.addListener(_textInputControllerListener);
    _getSuggestions();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getSuggestions();
  }

  @override
  void initState() {
    super.initState();
    _deBouncerSuggestion = Debouncer(
      widget.debounceDuration ?? const Duration(milliseconds: 300),
      initialValue: '',
    );

    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _suggestionsValid = widget.minCharsForSuggestions! > 0 ? true : false;
    _isLoading = false;
    _lastTextValue = widget.controller!.text;

    if (widget.getImmediateSuggestions) {
      _getSuggestions();
    }

    widget.controller!.addListener(_textInputControllerListener);
    _deBouncerSuggestionStreamSubscriptions =
        _deBouncerSuggestion.values.listen(_handleDebounceTimeListener);
  }

  Future<void> invalidateSuggestions() async {
    if (widget.hideSuggestionsBox) return;
    _suggestionsValid = false;
    await _getSuggestions();
  }

  Future<void> _getSuggestions() async {
    if (_suggestionsValid || widget.hideSuggestionsBox) return;

    if (!mounted) return;

    _suggestionsValid = true;

    final queryString = widget.controller!.text.trim();

    setState(() {
      _animationController!.forward(from: 1.0);
      _isLoading = true;
    });

    if (queryString.isEmpty) {
      final recentItems = await _getListRecent(queryString);

      setState(() {
        _animationController!.forward(from: widget.animationStart);
        _isLoading = false;
        _suggestions = null;
        _recentItems = recentItems;
        _contacts = null;
      });
      return;
    }

    Iterable<T>? suggestions;
    Iterable<R>? recentItems;
    Iterable<P>? contacts;

    final tupleListItems = await Future.wait([
      _getListSuggestion(queryString),
      if (queryString.length >= (widget.minInputLengthAutocomplete ?? 0))
        _getListContact(queryString),
    ]);

    if (tupleListItems.isEmpty ||
        tupleListItems.every((item) => item == null || item.isEmpty)) {
      recentItems = await _getListRecent(queryString);
    } else {
      suggestions = tupleListItems[0] as Iterable<T>?;
      contacts =
          tupleListItems.length == 2 ? tupleListItems[1] as Iterable<P>? : null;
    }

    setState(() {
      final animationStart =
          suggestions?.isNotEmpty == true ? widget.animationStart : 1.0;
      _animationController!.forward(from: animationStart);
      _isLoading = false;
      _suggestions = suggestions;
      _recentItems = recentItems;
      _contacts = contacts;
    });
  }

  @override
  void dispose() {
    _animationController!.dispose();
    _deBouncerSuggestionStreamSubscriptions.cancel();
    _deBouncerSuggestion.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.hideSuggestionsBox) {
      return const SizedBox.shrink();
    }

    Widget child;

    if ((_suggestions?.isNotEmpty == true || _contacts?.isNotEmpty == true) &&
        widget.controller?.text.isNotEmpty == true) {
      child = createSuggestionsWidget();
    } else {
      child = createRecentWidget();
    }

    final animationChild = widget.transitionBuilder != null
        ? widget.transitionBuilder!(context, child, _animationController)
        : SizeTransition(
            axisAlignment: -1.0,
            sizeFactor: CurvedAnimation(
                parent: _animationController!, curve: Curves.fastOutSlowIn),
            child: child,
          );

    BoxConstraints constraints;
    if (widget.decoration!.constraints == null) {
      constraints = BoxConstraints(
        maxHeight: widget.suggestionsBox!.maxHeight,
      );
    } else {
      double maxHeight = min(widget.decoration!.constraints!.maxHeight,
          widget.suggestionsBox!.maxHeight);
      constraints = widget.decoration!.constraints!.copyWith(
        minHeight: min(widget.decoration!.constraints!.minHeight, maxHeight),
        maxHeight: maxHeight,
      );
    }

    var container = Material(
      elevation: widget.suggestionsBox?.isOpened == true
          ? 1
          : widget.decoration!.elevation,
      color: widget.decoration!.color,
      shape: widget.decoration!.shape,
      borderRadius: widget.suggestionsBox?.isOpened == true
          ? const BorderRadius.only(
              bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16))
          : widget.decoration!.borderRadius,
      shadowColor: widget.decoration!.shadowColor,
      clipBehavior: widget.decoration!.clipBehavior,
      child: ConstrainedBox(
        constraints: constraints,
        child: animationChild,
      ),
    );

    return PointerInterceptor(child: container);
  }

  Widget createSuggestionsWidget() {
    final listItemSuggestionWidget = _buildListViewSuggestionWidget();
    final loadingWidget = _buildLoadingBarWidget();
    final listActionWidget = _buildListActionWidget();
    final listItemContactWidget = _buildListViewContactWidget();

    Widget child = ListView(
      padding: EdgeInsets.zero,
      primary: false,
      shrinkWrap: true,
      controller: _scrollController,
      reverse:
          widget.suggestionsBox!.direction == AxisDirection.down ? false : true,
      // reverses the list to start at the bottom
      children: [
        if (listActionWidget != null) listActionWidget,
        if (widget.buttonShowAllResult != null &&
            widget.controller?.text.isNotEmpty == true)
          widget.buttonShowAllResult!(context, widget.controller?.text, this),
        if (loadingWidget != null) loadingWidget,
        if (listItemContactWidget.isNotEmpty) ...listItemContactWidget,
        if (listItemContactWidget.isNotEmpty &&
            listItemSuggestionWidget.isNotEmpty)
          const Divider(),
        if (listItemSuggestionWidget.isNotEmpty) ...[
          ...listItemSuggestionWidget,
          const SizedBox(height: 16)
        ],
      ],
    );

    if (widget.decoration!.hasScrollbar) {
      child = Scrollbar(
        controller: _scrollController,
        child: child,
      );
    }

    return child;
  }

  Widget createRecentWidget() {
    final listItemRecent = _buildListViewRecentWidget();
    final loadingWidget = _buildLoadingBarWidget();
    final listActionWidget = _buildListActionWidget();

    Widget child = ListView(
      padding: EdgeInsets.zero,
      primary: false,
      shrinkWrap: true,
      controller: _scrollController,
      reverse:
          widget.suggestionsBox!.direction == AxisDirection.down ? false : true,
      // reverses the list to start at the bottom
      children: [
        if (listActionWidget != null) listActionWidget,
        if (widget.buttonShowAllResult != null &&
            widget.controller?.text.isNotEmpty == true)
          widget.buttonShowAllResult!(context, widget.controller?.text, this),
        if (_recentItems?.isNotEmpty == true &&
            widget.itemRecentBuilder != null &&
            widget.titleHeaderRecent != null)
          widget.titleHeaderRecent!,
        if (listItemRecent.isNotEmpty) ...listItemRecent,
        if (loadingWidget != null)
          loadingWidget
        else if (listItemRecent.isNotEmpty)
          const SizedBox(height: 16)
      ],
    );

    if (widget.decoration!.hasScrollbar) {
      child = Scrollbar(
        controller: _scrollController,
        child: Container(child: child),
      );
    }

    return child;
  }

  Widget? _buildListActionWidget() {
    if (widget.listActionButton?.isNotEmpty != true ||
        widget.actionButtonBuilder == null) {
      return null;
    }

    final listActionWidget = Wrap(
        children: widget.listActionButton!.map((action) {
      if (widget.buttonActionCallback != null) {
        return Padding(
          padding: const EdgeInsetsDirectional.only(end: 8, bottom: 8),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              onTap: () {
                widget.buttonActionCallback?.call(action);
                invalidateSuggestions();
              },
              child: widget.actionButtonBuilder!(context, action, this),
            ),
          ),
        );
      } else {
        return Padding(
            padding: const EdgeInsetsDirectional.only(end: 8, bottom: 8),
            child: widget.actionButtonBuilder!(context, action, this));
      }
    }).toList());

    if (widget.listActionPadding != null) {
      return Padding(
          padding: widget.listActionPadding!, child: listActionWidget);
    } else {
      return listActionWidget;
    }
  }

  Widget? _buildLoadingBarWidget() {
    if (_isLoading != true ||
        widget.hideOnLoading != false ||
        widget.keepSuggestionsOnLoading != false) {
      return null;
    }

    if (widget.loadingBuilder != null) {
      return widget.loadingBuilder!(context);
    } else {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: CircularProgressIndicator(),
        ),
      );
    }
  }

  List<Widget> _buildListViewRecentWidget() {
    if (_recentItems?.isNotEmpty != true || widget.itemRecentBuilder == null) {
      return [];
    }

    return _recentItems!.map((recent) {
      if (widget.onRecentSelected != null) {
        return InkWell(
          child: widget.itemRecentBuilder!(context, recent),
          onTap: () => widget.onRecentSelected!(recent),
        );
      } else {
        return widget.itemRecentBuilder!(context, recent);
      }
    }).toList();
  }

  List<Widget> _buildListViewSuggestionWidget() {
    if (_suggestions?.isNotEmpty != true || widget.itemBuilder == null) {
      return [];
    }

    return _suggestions!.map((suggestion) {
      if (widget.onSuggestionSelected != null) {
        return InkWell(
          child: widget.itemBuilder!(context, suggestion),
          onTap: () => widget.onSuggestionSelected?.call(suggestion),
        );
      } else {
        return widget.itemBuilder!(context, suggestion);
      }
    }).toList();
  }

  List<Widget> _buildListViewContactWidget() {
    if (_contacts?.isNotEmpty != true ||
        widget.contactSuggestionBuilder == null) {
      return [];
    }

    return _contacts!.map((contact) {
      if (widget.onContactSuggestionSelected != null) {
        return InkWell(
          child: widget.contactSuggestionBuilder!(context, contact),
          onTap: () => widget.onContactSuggestionSelected?.call(contact),
        );
      } else {
        return widget.contactSuggestionBuilder!(context, contact);
      }
    }).toList();
  }
}
