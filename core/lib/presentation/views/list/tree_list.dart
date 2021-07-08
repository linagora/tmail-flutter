// LinShare is an open source filesharing software, part of the LinPKI software
// suite, developed by Linagora.
//
// Copyright (C) 2020 LINAGORA
//
// This program is free software: you can redistribute it and/or modify it under the
// terms of the GNU Affero General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later version,
// provided you comply with the Additional Terms applicable for LinShare software by
// Linagora pursuant to Section 7 of the GNU Affero General Public License,
// subsections (b), (c), and (e), pursuant to which you must notably (i) retain the
// display in the interface of the “LinShare™” trademark/logo, the "Libre & Free" mention,
// the words “You are using the Free and Open Source version of LinShare™, powered by
// Linagora © 2009–2020. Contribute to Linshare R&D by subscribing to an Enterprise
// offer!”. You must also retain the latter notice in all asynchronous messages such as
// e-mails sent with the Program, (ii) retain all hypertext links between LinShare and
// http://www.linshare.org, between linagora.com and Linagora, and (iii) refrain from
// infringing Linagora intellectual property rights over its trademarks and commercial
// brands. Other Additional Terms apply, see
// <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf>
// for more details.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for
// more details.
// You should have received a copy of the GNU Affero General Public License and its
// applicable Additional Terms for LinShare along with this program. If not, see
// <http://www.gnu.org/licenses/> for the GNU Affero General Public License version
//  3 and <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf> for
//  the Additional Terms applicable to LinShare software.

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