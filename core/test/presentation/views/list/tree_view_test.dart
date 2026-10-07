import 'package:core/presentation/views/list/tree_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTree({required bool isExpanded}) => MaterialApp(
    home: Scaffold(
      body: TreeView(
        children: [
          TreeViewChild(
            isExpanded: isExpanded,
            parent: InkWell(
              onTap: () {},
              child: Row(
                children: [
                  const Text('Team'),
                  IconButton(
                    tooltip: 'Expand',
                    icon: const Icon(Icons.expand_more),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            children: [
              for (final name in ['Team inbox', 'Team sent'])
                InkWell(onTap: () {}, child: Text(name)),
            ],
          ).build(),
        ],
      ),
    ),
  );

  testWidgets(
    'keeps the semantics parent of a folder when its children are expanded',
    (tester) async {
      final semantics = tester.ensureSemantics();

      await tester.pumpWidget(buildTree(isExpanded: false));
      final collapsedParentId = tester.getSemantics(find.text('Team')).parent?.id;

      await tester.pumpWidget(buildTree(isExpanded: true));
      await tester.pumpAndSettle();
      final expandedParentId = tester.getSemantics(find.text('Team')).parent?.id;

      expect(find.text('Team inbox'), findsOneWidget);
      expect(expandedParentId, collapsedParentId);
      semantics.dispose();
    },
  );
}
