import 'package:flutter/material.dart';

class TreeView extends InheritedWidget {
  final List<Widget> children;
  final bool startExpanded;

  TreeView({
    Key? key,
    required this.children,
    this.startExpanded = false,
  }) : super (
    key: key,
    child: _TreeViewData(
      children: children,
    ),
  );

  static TreeView of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TreeView>()!;
  }

  @override
  bool updateShouldNotify(TreeView oldWidget) {
    if (oldWidget.children == children &&
        oldWidget.startExpanded == startExpanded) {
      return false;
    }
    return true;
  }
}

class _TreeViewData extends StatelessWidget {
  final List<Widget> children;

  const _TreeViewData({
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      key: const PageStorageKey('tree_view'),
      shrinkWrap: true,
      primary: false,
      padding: EdgeInsets.zero,
      itemCount: children.length,
      itemBuilder: (context, index) {
        return children.elementAt(index);
      },
    );
  }
}

class TreeViewChild {
  final BuildContext context;
  final bool? isExpanded;
  final Widget parent;
  final List<Widget> children;
  final VoidCallback? onTap;
  final EdgeInsets? paddingChild;
  final bool isDirectionRTL;

  TreeViewChild(
    this.context,
    {
      required this.parent,
      required this.children,
      this.isExpanded,
      this.onTap,
      this.paddingChild,
      this.isDirectionRTL = false,
      Key? key,
    }
  );

  Widget build() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        GestureDetector(
          child: parent,
          onTap: () {
            if (onTap != null) {
              onTap!();
            }
          },
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          child: isExpanded!
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: children
                  .map((child) => Padding(
                    padding: paddingChild ?? EdgeInsets.only(
                      left: isDirectionRTL ? 0 : 20,
                      right: isDirectionRTL ? 20 : 0,
                    ),
                    child: child
                  ))
                  .toList()
              )
            : const Offstage(),
        ),
      ],
    );
  }
}