import 'package:flutter/material.dart';

class TreeView extends InheritedWidget {
  final List<Widget> children;
  final bool startExpanded;

  TreeView({
    Key? key,
    required List<Widget> children,
    bool startExpanded = false,
  }) : this.children = children, this.startExpanded = startExpanded, super (
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
    if (oldWidget.children == this.children &&
        oldWidget.startExpanded == this.startExpanded) {
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
      key: PageStorageKey('tree_view'),
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

  TreeViewChild(
    this.context,
    {
      required this.parent,
      required this.children,
      this.isExpanded,
      this.onTap,
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
          duration: Duration(milliseconds: 400),
          child: isExpanded!
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: children.map((child) => Padding(padding: EdgeInsets.only(left: 20), child: child)).toList())
            : Offstage(),
        ),
      ],
    );
  }
}