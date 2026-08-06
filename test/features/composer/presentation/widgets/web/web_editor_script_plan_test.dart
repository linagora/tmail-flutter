import 'package:core/utils/html/editor_script/quoted_reply_enter_handler_script.dart';
import 'package:core/utils/html/html_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/initial_scripts/web_editor_script_descriptor.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/initial_scripts/web_editor_script_group.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/web_editor_script_plan.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/web_editor_scripts_factory.dart';
import 'package:workplace/presentation/utils/workplace_scripts.dart';

const _maxHeight = 400.0;
const _selectionScriptName = 'selection';
const _driveCardRemoveLabel = 'Remove';
const _driveCardViewId = 'editor';

void main() {
  WebEditorScriptPlan buildPlan({WebScript? selectionChangeScript}) =>
      WebEditorScriptPlan(
        maxHeight: _maxHeight,
        selectionChangeScript: selectionChangeScript ??
            WebScript(name: _selectionScriptName, script: 'void 0;'),
        driveCardDeleteOverlayRemoveLabel: _driveCardRemoveLabel,
        driveCardDeleteOverlayViewId: _driveCardViewId,
      );

  WebEditorScriptDescriptor buildDescriptor(
    String name, {
    bool runOnInit = false,
  }) => WebEditorScriptDescriptor(
    script: WebScript(name: name, script: '$name();'),
    runOnInit: runOnInit,
  );

  test('registers the quoted reply Enter command once', () {
    const quotedReplyEnterHandler = QuotedReplyEnterHandlerScript();
    final scripts = buildPlan().initialScripts;

    final handlerScripts = scripts
        .where((script) => script.name == quotedReplyEnterHandler.name)
        .toList();

    expect(handlerScripts, hasLength(1));
    expect(handlerScripts.single.script, quotedReplyEnterHandler.script);
  });

  test('preserves the script initialization order', () {
    final selectionChangeScript = WebScript(
      name: _selectionScriptName,
      script: 'void 0;',
    );
    final scripts =
        buildPlan(selectionChangeScript: selectionChangeScript).initialScripts;

    expect(
      scripts.map((script) => script.name),
      orderedEquals([
        HtmlUtils.removeLineHeight1px.name,
        HtmlUtils.registerDropListener.name,
        HtmlUtils.unregisterDropListener.name,
        selectionChangeScript.name,
        HtmlUtils.collapseSelectionToEnd.name,
        HtmlUtils.deleteSelectionContent.name,
        HtmlUtils.saveSelection.name,
        HtmlUtils.restoreSelection.name,
        HtmlUtils.getSavedSelection.name,
        HtmlUtils.clearSavedSelection.name,
        HtmlUtils.recalculateEditorHeight(maxHeight: _maxHeight).name,
        HtmlUtils.registerFileLinkRowEnterKeyHandler(isWebPlatform: true).name,
        const QuotedReplyEnterHandlerScript().name,
        HtmlUtils.registerFileLinkCardClickHandler(isWebPlatform: true).name,
        WorkplaceScripts.registerDriveCardDeleteOverlay(
          _driveCardRemoveLabel,
          viewId: _driveCardViewId,
          isWebPlatform: true,
        ).name,
        WorkplaceScripts.unregisterDriveCardDeleteOverlay.name,
      ]),
    );
  });

  test('runs only init-flagged scripts at editor initialization', () {
    final plan = buildPlan();

    expect(plan.initializationScriptNames, orderedEquals([
      HtmlUtils.registerDropListener.name,
      _selectionScriptName,
      HtmlUtils.registerFileLinkRowEnterKeyHandler(isWebPlatform: true).name,
      const QuotedReplyEnterHandlerScript().name,
      HtmlUtils.registerFileLinkCardClickHandler(isWebPlatform: true).name,
      WorkplaceScripts.registerDriveCardDeleteOverlay(
        _driveCardRemoveLabel,
        viewId: _driveCardViewId,
        isWebPlatform: true,
      ).name,
    ]));
  });

  test('keeps the first descriptor when groups share a command name', () {
    final factory = WebEditorScriptsFactory(
      groups: [
        _ScriptGroup([
          buildDescriptor('first'),
          WebEditorScriptDescriptor(
            script: WebScript(name: 'shared', script: 'firstShared();'),
            runOnInit: true,
          ),
        ]),
        _ScriptGroup([
          WebEditorScriptDescriptor(
            script: WebScript(name: 'shared', script: 'secondShared();'),
          ),
          buildDescriptor('last', runOnInit: true),
        ]),
      ],
    );

    final scripts = factory.buildInitialScripts();
    expect(scripts.map((script) => script.name), orderedEquals([
      'first',
      'shared',
      'last',
    ]));
    expect(scripts[1].script, 'firstShared();');
    expect(
      factory.buildInitializationScriptNames(),
      orderedEquals(['shared', 'last']),
    );
  });

  test('excludes scripts without the init flag from runtime names', () {
    final factory = WebEditorScriptsFactory(
      groups: [
        _ScriptGroup([
          buildDescriptor('setupOnly'),
          buildDescriptor('runAtInit', runOnInit: true),
        ]),
      ],
    );

    expect(factory.buildInitializationScriptNames(), orderedEquals([
      'runAtInit',
    ]));
  });
}

final class _ScriptGroup implements WebEditorScriptGroup {
  const _ScriptGroup(this.descriptors);

  final List<WebEditorScriptDescriptor> descriptors;

  @override
  List<WebEditorScriptDescriptor> build() => descriptors;
}
