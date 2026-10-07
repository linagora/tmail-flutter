import 'dart:convert';
import 'dart:io';

import '../test/fixtures/html_emails/html_email_corpus_fixture.dart';

void main() {
  final source = buildHtmlEmailCorpusDart();
  File('${htmlEmailCorpusDirectory().path}/html_email_corpus.g.dart')
      .writeAsStringSync(source);
  stdout.writeln(
    'Wrote ${RegExp(r'HtmlEmailCorpusFixture\(').allMatches(source).length} fixtures',
  );
}

Directory corePackageRoot() {
  final cwd = Directory.current;
  final here = File(
    '${cwd.path}/lib/presentation/utils/html_transformer/transform_configuration.dart',
  );
  if (here.existsSync()) return cwd;
  final nested = Directory('${cwd.path}/core');
  final nestedFile = File(
    '${nested.path}/lib/presentation/utils/html_transformer/transform_configuration.dart',
  );
  if (nestedFile.existsSync()) return nested;
  throw StateError('Cannot find core package from ${cwd.path}');
}

Directory htmlEmailCorpusDirectory() =>
    Directory('${corePackageRoot().path}/test/fixtures/html_emails');

String buildHtmlEmailCorpusDart([Directory? directory]) {
  final emailsDir = directory ?? htmlEmailCorpusDirectory();
  if (!emailsDir.existsSync()) {
    throw StateError('Missing ${emailsDir.path}');
  }

  final rootPrefix = emailsDir.path.endsWith('/')
      ? emailsDir.path
      : '${emailsDir.path}/';
  final fixtures = <_Parsed>[];
  for (final entity in emailsDir.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.html')) continue;
    fixtures.add(_parse(entity, rootPrefix));
  }
  fixtures.sort((a, b) {
    final byCategory = a.category.compareTo(b.category);
    return byCategory != 0 ? byCategory : a.name.compareTo(b.name);
  });

  final buffer = StringBuffer()
    ..writeln('// GENERATED — run: dart run tool/generate_html_email_corpus.dart')
    ..writeln("import 'html_email_corpus_fixture.dart';")
    ..writeln()
    ..writeln('const htmlEmailCorpus = <HtmlEmailCorpusFixture>[');

  for (final fixture in fixtures) {
    final sidecar = fixture.sidecar;
    buffer
      ..writeln('  HtmlEmailCorpusFixture(')
      ..writeln('    name: ${_dartString(fixture.name)},')
      ..writeln('    category: ${_dartString(fixture.category)},')
      ..writeln('    html: ${_dartString(fixture.html)},')
      ..writeln('    expectQuote: ${sidecar.expectQuote},')
      ..writeln('    rtl: ${sidecar.rtl},')
      ..writeln('    minPreservation: ${sidecar.minPreservation},')
      ..writeln('    source: ${_dartString(sidecar.source)},')
      ..writeln('    allowEmptyBody: ${sidecar.allowEmptyBody},')
      ..writeln('    purpose: ${_dartString(sidecar.purpose)},')
      ..writeln('    contentType: ${_dartString(sidecar.contentType)},')
      ..writeln(
        '    expect: [${sidecar.expect.map((e) => 'HtmlEmailExpect.$e').join(', ')}],',
      )
      ..writeln('  ),');
  }
  buffer.writeln('];');
  return buffer.toString();
}

/// A Dart string literal: JSON escaping plus `$`, which Dart would read as
/// interpolation (real emails contain prices like `$19.99`).
String _dartString(String value) => jsonEncode(value).replaceAll(r'$', r'\$');

class _Parsed {
  _Parsed({
    required this.name,
    required this.category,
    required this.html,
    required this.sidecar,
  });

  final String name;
  final String category;
  final String html;
  final _Sidecar sidecar;
}

final _expectNames = HtmlEmailExpect.values.map((e) => e.name).toSet();

const _contentTypes = {'text/html', 'text/plain'};

/// The `<name>.json` next to a fixture. Missing fields take their defaults;
/// a wrong type or an unknown `contentType`/`expect` value is a
/// [FormatException] naming the file.
class _Sidecar {
  const _Sidecar({
    this.expectQuote = false,
    this.rtl = false,
    this.minPreservation = 0.95,
    this.source = '',
    this.allowEmptyBody = false,
    this.purpose = '',
    this.contentType = 'text/html',
    this.expect = const [],
  });

  factory _Sidecar.fromJson(Map<String, dynamic> json, String path) {
    T read<T>(String key, T fallback) {
      final value = json[key];
      if (value == null) return fallback;
      if (value is! T) {
        throw FormatException('$path: "$key" must be a $T, got $value');
      }
      return value;
    }

    final expect = read<List<dynamic>>('expect', const []);
    final unknown = expect.where((e) => e is! String || !_expectNames.contains(e));
    if (unknown.isNotEmpty) {
      throw FormatException('$path: unknown expect $unknown');
    }
    final contentType = read<String>('contentType', 'text/html');
    if (!_contentTypes.contains(contentType)) {
      throw FormatException('$path: unknown contentType "$contentType"');
    }
    return _Sidecar(
      expectQuote: read<bool>('expectQuote', false),
      rtl: read<bool>('rtl', false),
      minPreservation: read<num>('minPreservation', 0.95).toDouble(),
      source: read<String>('source', ''),
      allowEmptyBody: read<bool>('allowEmptyBody', false),
      purpose: read<String>('purpose', ''),
      contentType: contentType,
      expect: expect.cast<String>().toList(),
    );
  }

  final bool expectQuote;
  final bool rtl;
  final double minPreservation;
  final String source;
  final bool allowEmptyBody;
  final String purpose;
  final String contentType;
  final List<String> expect;
}

_Parsed _parse(File htmlFile, String rootPrefix) {
  final relative = htmlFile.path.substring(rootPrefix.length);
  final parts = relative.split('/');
  final sidecarPath = htmlFile.path.replaceFirst(RegExp(r'\.html$'), '.json');
  final sidecarFile = File(sidecarPath);
  return _Parsed(
    name: htmlFile.uri.pathSegments.last.replaceAll('.html', ''),
    category: parts.length > 1 ? parts.first : 'uncategorized',
    html: htmlFile.readAsStringSync(),
    sidecar: sidecarFile.existsSync()
        ? _Sidecar.fromJson(
            jsonDecode(sidecarFile.readAsStringSync()) as Map<String, dynamic>,
            sidecarPath,
          )
        : const _Sidecar(),
  );
}
