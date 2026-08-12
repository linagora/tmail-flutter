import 'dart:convert';
import 'dart:io';

import 'package:core/utils/html/html_template.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linagora_design_flutter/style/linagora_text_theme.dart';

/// HTML content (email viewer, composer, print, EML preview) is rendered
/// outside Flutter, so its font is referenced by URL instead of through the
/// theme. Nothing links the two, and a missing file only shows up as a 404 at
/// runtime — these tests are the link.
void main() {
  final fontUrls = RegExp(r'url\("([^"]+)"\)')
      .allMatches(HtmlTemplate.fontFaceStyle)
      .map((match) => match.group(1)!)
      .toList();

  test('font-face rules are declared', () {
    expect(fontUrls, isNotEmpty);
  });

  test('uses the same font family as the Flutter theme', () {
    final themeFamily = LinagoraTextTheme.material().bodyMedium?.fontFamily;
    expect(themeFamily, isNotNull);
    // The theme family is package qualified: packages/<package>/<family>.
    expect(themeFamily, endsWith('/${HtmlTemplate.fontFamilyApp}'));

    final package = themeFamily!.split('/')[1];
    for (final url in fontUrls) {
      expect(url, startsWith('assets/packages/$package/'),
          reason: '$url does not come from the design system package');
    }
  });

  test('every referenced font file is actually shipped', () {
    final packageRoot = _resolvePackageRoot('linagora_design_flutter');
    final packagePubspec =
        File.fromUri(packageRoot.resolve('pubspec.yaml')).readAsStringSync();

    for (final url in fontUrls) {
      // assets/packages/<package>/<pathInsidePackage>
      final pathInsidePackage = url.split('/').skip(3).join('/');
      final file = File.fromUri(packageRoot.resolve(pathInsidePackage));
      expect(file.existsSync(), isTrue, reason: '$url points at a missing file');
      // A file that is not declared under `flutter: fonts:` is not bundled.
      expect(
        _isDeclaredAsFlutterFont(packagePubspec, pathInsidePackage),
        isTrue,
        reason: '$pathInsidePackage is not declared as a font',
      );
    }
  });

  test('does not point at app-local font assets', () {
    // The app no longer ships its own font files; the design system does.
    for (final url in fontUrls) {
      expect(url, isNot(startsWith('assets/fonts/')),
          reason: '$url expects a font the app no longer bundles');
    }
  });
}

/// True when [pathInsidePackage] (or a parent directory) is declared under
/// `flutter: fonts:` — Flutter only bundles declared fonts.
bool _isDeclaredAsFlutterFont(String packagePubspec, String pathInsidePackage) {
  final candidates = <String>[pathInsidePackage];
  var remaining = pathInsidePackage;
  while (remaining.contains('/')) {
    remaining = remaining.substring(0, remaining.lastIndexOf('/'));
    candidates
      ..add('$remaining/')
      ..add(remaining);
  }
  return candidates.any(packagePubspec.contains);
}

Uri _resolvePackageRoot(String packageName) {
  // `core` has no package config of its own; it shares the workspace root one.
  var directory = Directory.current.absolute;
  File? configFile;
  while (configFile == null) {
    final candidate =
        File.fromUri(directory.uri.resolve('.dart_tool/package_config.json'));
    if (candidate.existsSync()) {
      configFile = candidate;
      break;
    }
    final parent = directory.parent;
    if (parent.path == directory.path) {
      fail('no .dart_tool/package_config.json found; run `flutter pub get`');
    }
    directory = parent;
  }

  final packages = (jsonDecode(configFile.readAsStringSync())
      as Map<String, dynamic>)['packages'] as List<dynamic>;
  final package = packages.cast<Map<String, dynamic>>().firstWhere(
        (entry) => entry['name'] == packageName,
        orElse: () => throw StateError('$packageName is not a dependency'),
      );

  final rootUri = package['rootUri'] as String;
  return configFile.absolute.uri
      .resolve(rootUri.endsWith('/') ? rootUri : '$rootUri/');
}
