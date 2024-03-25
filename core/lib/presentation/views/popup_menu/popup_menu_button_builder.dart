import 'package:core/presentation/action/popup_menu_action.dart';
import 'package:core/presentation/views/popup_menu/popup_menu_item_widget.dart';
import 'package:flutter/material.dart';

typedef PopupButtonBuilder = Widget Function(bool isSelected);

class PopupMenuButtonBuilder<T> extends StatefulWidget {

  final PopupButtonBuilder childBuilder;
  final List<PopupMenuAction<T>> listAction;
  final bool isSelectedHighlight;

  const PopupMenuButtonBuilder({
    super.key,
    required this.childBuilder,
    required this.listAction,
    this.isSelectedHighlight = true,
  });

  @override
  State<PopupMenuButtonBuilder<T>> createState() => _PopupMenuButtonBuilderState<T>();
}

class _PopupMenuButtonBuilderState<T> extends State<PopupMenuButtonBuilder<T>> {

  ValueNotifier<bool>? _buttonStateNotifier;

  @override
  void initState() {
    super.initState();
    if (widget.isSelectedHighlight) {
      _buttonStateNotifier = ValueNotifier(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      position: PopupMenuPosition.under,
      color: Colors.white,
      surfaceTintColor: Colors.white,
      padding: EdgeInsets.zero,
      onOpened: () {
        if (widget.isSelectedHighlight) {
          _buttonStateNotifier!.value = true;
        }
      },
      onCanceled: () {
        if (widget.isSelectedHighlight) {
          _buttonStateNotifier!.value = false;
        }
      },
      tooltip: '',
      constraints: const BoxConstraints(minWidth: 256),
      itemBuilder: (_) => widget.listAction
        .map((action) => _buildPopupMenuItem(context, action))
        .toList(),
      child: widget.isSelectedHighlight
        ? ValueListenableBuilder(
            valueListenable: _buttonStateNotifier!,
            builder: (context, value, child) => widget.childBuilder.call(value)
          )
        : widget.childBuilder.call(false),
    );
  }

  PopupMenuEntry<T> _buildPopupMenuItem(BuildContext context, PopupMenuAction<T> action) {
    return PopupMenuItem(
      padding: EdgeInsets.zero,
      height: 36,
      child: PopupMenuItemWidget(
        name: action.name,
        icon: action.icon,
        height: 36,
        iconColor: Colors.black87,
        onCallbackAction: () => action.onSelected(action.value)
      )
    );
  }

  @override
  void dispose() {
    if (widget.isSelectedHighlight) {
      _buttonStateNotifier!.dispose();
    }
    super.dispose();
  }
}