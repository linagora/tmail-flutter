import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/shown_account_input_block_notifier.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/widgets/shown_account_input_blocker.dart';

const _buttonKey = Key('shown-mailbox-button');

class _Taps {
  int count = 0;

  void record() => count++;
}

Widget _dashboard(ProviderContainer container, VoidCallback onTap, {bool showsBlocker = true}) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      home: showsBlocker
          ? ShownAccountInputBlocker(
              child: TextButton(key: _buttonKey, onPressed: onTap, child: const Text('Open')),
            )
          : const SizedBox.shrink(),
    ),
  );
}

void main() {
  late ProviderContainer container;
  late _Taps taps;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
    taps = _Taps();
  });

  testWidgets('lets taps through while no switch blocks them', (tester) async {
    await tester.pumpWidget(_dashboard(container, taps.record));

    await tester.tap(find.byKey(_buttonKey));

    expect(taps.count, 1);
  });

  testWidgets('absorbs taps while a switch blocks them', (tester) async {
    await tester.pumpWidget(_dashboard(container, taps.record));
    container.read(shownAccountInputBlockProvider.notifier).block();
    await tester.pump();

    await tester.tap(find.byKey(_buttonKey), warnIfMissed: false);

    expect(taps.count, 0);
  });

  testWidgets('lets taps through again once the switch unblocks them', (tester) async {
    await tester.pumpWidget(_dashboard(container, taps.record));
    container.read(shownAccountInputBlockProvider.notifier).block();
    await tester.pump();
    container.read(shownAccountInputBlockProvider.notifier).unblock();
    await tester.pump();

    await tester.tap(find.byKey(_buttonKey));

    expect(taps.count, 1);
  });

  testWidgets('a block left by a session ended during a switch is gone for the next dashboard',
      (tester) async {
    await tester.pumpWidget(_dashboard(container, taps.record));
    container.read(shownAccountInputBlockProvider.notifier).block();
    await tester.pump();

    await tester.pumpWidget(_dashboard(container, taps.record, showsBlocker: false));
    await tester.pump();
    await tester.pumpWidget(_dashboard(container, taps.record));
    await tester.tap(find.byKey(_buttonKey));

    expect(taps.count, 1);
  });
}
