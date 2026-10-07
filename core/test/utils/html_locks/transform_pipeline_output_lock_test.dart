@TestOn('vm')

import 'dart:convert';

import 'package:core/presentation/utils/html_transformer/html_transform.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter_test/flutter_test.dart';

import '../html_pipeline_registry.dart';
import '../html_transform_text_html_test.mocks.dart';
import 'html_lock_golden.dart';

/// One probe that touches every transformer, run through every pipeline.
/// The manifest lock says *that* a pipeline changed; this lock shows *what*
/// the change does to real HTML (an order swap that alters output, a
/// transformer that starts or stops rewriting something).
const _probe = '''
<html><head>
<style>.x{color:red;position:fixed} @media (max-width:600px){.col{display:block}}</style>
<meta http-equiv="refresh" content="0">
</head><body>
<script>alert(1)</script>
<p class="x" onclick="alert(1)" style="color:blue;line-height:0px">styled</p>
<div style="float:left;margin-left:-40px">negative margin float</div>
<a href="javascript:alert(1)">js link</a>
<a href="https://example.com/a?b=1">https link</a>
<a href="mailto:someone@example.com">mail link</a>
<p>bare url https://example.org/path here</p>
<img src="cid:img-1" alt="cid image">
<img src="https://example.com/i.png" style="max-width:600px" alt="remote image">
<img src="https://example.com/lazy.png" loading="lazy" alt="already lazy">
<div style="background-image:url('https://example.com/bg.png')">background</div>
<blockquote><p>quoted</p><blockquote><p>nested quote</p></blockquote></blockquote>
<pre><code>code()</code></pre>
<table><tr><td style="width:300px">cell https://example.com/very/long/path</td></tr></table>
<div class="tmail-signature" style="display: block;">
  <button class="tmail-signature-button">toggle</button>
  <div class="tmail-signature-content">Regards</div>
</div>
<a class="tmail-file-link-card" href="https://drive.example.com/f" contenteditable="false">file.pdf</a>
<div contenteditable="true">editable region</div>
<iframe src="https://evil.example"></iframe>
<form action="https://evil.example"><input name="p"></form>
<svg onload="alert(1)"><rect width="1" height="1"/></svg>
</body></html>
''';

void main() {
  late HtmlTransform htmlTransform;

  setUp(() {
    htmlTransform = HtmlTransform(MockDioClient(), const HtmlEscape());
  });

  tearDown(() {
    PlatformInfo.isTestingForWeb = false;
  });

  final rows = htmlPipelineRegistry();

  for (final row in rows) {
    test('${row.name} output for the probe is locked', () async {
      final output = await htmlTransform.transformToHtml(
        htmlContent: _probe,
        transformConfiguration: row.build(),
      );
      expectMatchesHtmlLock('pipeline_output/${row.name}.html', output);
    });
  }

  test('no output lock is left for a removed pipeline', () {
    expect(
      orphanHtmlLockFiles(
        'pipeline_output',
        rows.map((row) => '${row.name}.html').toSet(),
      ),
      isEmpty,
    );
  });
}
