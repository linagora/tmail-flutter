import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class TreeView extends InheritedWidget {
  final List<Widget> children;

  TreeView({
    Key? key,
    required List<Widget> children,
  }) : this.children = children,
        super(
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
    if (oldWidget.children == this.children) {
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
      shrinkWrap: true,
      primary: false,
      itemCount: children.length,
      itemBuilder: (context, index) {
        return children.elementAt(index);
      },
    );
  }
}

class TreeViewChild extends StatefulWidget {
  final bool? startExpanded;
  final Widget parent;
  final List<Widget> children;
  final VoidCallback? onTap;

  TreeViewChild({
    required this.parent,
    required this.children,
    this.startExpanded,
    this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  TreeViewChildState createState() => TreeViewChildState();

  TreeViewChild copyWith(
      TreeViewChild source, {
        bool? startExpanded,
        Widget? parent,
        List<Widget>? children,
        VoidCallback? onTap,
      }) {
    return TreeViewChild(
      parent: parent ?? source.parent,
      children: children ?? source.children,
      startExpanded: startExpanded ?? source.startExpanded,
      onTap: onTap ?? source.onTap,
    );
  }
}

class TreeViewChildState extends State<TreeViewChild> {
  bool? isExpanded;

  @override
  void initState() {
    super.initState();
    isExpanded = widget.startExpanded;
  }

  @override
  void didChangeDependencies() {
    isExpanded = widget.startExpanded;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    isExpanded = widget.startExpanded;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        GestureDetector(
          child: widget.parent,
          onTap: () => toggleExpanded(),
        ),
        AnimatedContainer(
          duration: Duration(milliseconds: 100),
          child: widget.startExpanded!
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: widget.children)
            : Offstage(),
        ),
      ],
    );
  }

  void toggleExpanded() {
    setState(() {
      this.isExpanded = !this.isExpanded!;
    });
  }
}