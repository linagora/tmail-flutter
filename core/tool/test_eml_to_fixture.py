"""Tests for eml_to_fixture.py. Run from core/:

    python3 -m unittest discover -s tool -p 'test_*.py'
"""

import ast
import base64
import contextlib
import io
import json
import os
import re
import struct
import subprocess
import sys
import tempfile
import unittest
import zlib
from email.message import EmailMessage

import eml_to_fixture as converter


def _quiet_main(argv):
    with contextlib.redirect_stdout(io.StringIO()):
        return converter.main(argv)

HERE = os.path.dirname(os.path.abspath(__file__))


def _png(width, height):
    ihdr = struct.pack('>IIBBBBB', width, height, 8, 2, 0, 0, 0)
    chunk = b'IHDR' + ihdr
    return (b'\x89PNG\r\n\x1a\n' + struct.pack('>I', len(ihdr)) + chunk
            + struct.pack('>I', zlib.crc32(chunk)))


HTML = '''<html><head><style>.Hero{color:red}</style></head><body>
<p class="Hero">Hi, Alice Martin wrote from acme-corp.com</p>
<img src="cid:logo@acme" alt="logo">
<table width="640"><tr><td width="320"><img src="https://cdn.acme-corp.com/banner.png?u=8812345678"></td></tr></table>
<img src="https://cdn.acme-corp.com/x.png" width="200" height="50">
<img src="https://track.mailer.example/open.gif?id=998877665544" width="1" height="1">
<div style="width:300px"><img src="https://cdn.acme-corp.com/free.png" style="width:280px;height:70px"></div>
<img src="https://cdn.acme-corp.com/nosize.png">
<a href="https://click.mailer.example/c/abc?utm=secret-token">Read https://acme-corp.com/story/2026</a>
<a href="mailto:alice.martin@acme-corp.com">alice.martin@acme-corp.com</a>
<a href="tel:+33 1 23 45 67 89">call</a>
</body></html>'''

SECRETS = ('acme-corp.com', 'mailer.example', 'banner.png', 'secret-token',
           '8812345678', '998877665544', 'Alice Martin', 'alice.martin',
           'story/2026', '23 45 67 89')


def _eml(html=HTML, with_plain=True):
    message = EmailMessage()
    message['From'] = 'Alice Martin <alice.martin@acme-corp.com>'
    message['To'] = 'Bob Stone <bob@acme-corp.com>'
    message['Subject'] = 'Quarterly news'
    if with_plain:
        message.set_content('Plain alternative https://acme-corp.com/plain')
        message.add_alternative(html, subtype='html')
        html_part = message.get_payload()[1]
        html_part.add_related(_png(120, 40), 'image', 'png', cid='<logo@acme>')
    else:
        message.set_content('Only plain text from Alice Martin https://acme-corp.com/x')
    return message.as_bytes()


class ConvertTest(unittest.TestCase):

    def setUp(self):
        self.body, self.fields, self.report = converter.convert(_eml())

    def test_is_deterministic(self):
        self.assertEqual(converter.convert(_eml()), (self.body, self.fields, self.report))

    def test_no_source_host_path_or_address_left(self):
        for secret in SECRETS:
            self.assertNotIn(secret, self.body, secret)
        self.assertEqual(self.report['leftovers'],
                         {'hosts': [], 'emails': [], 'longDigits': [], 'phones': []})

    def test_cid_image_gets_exact_size(self):
        self.assertIn('src="https://fixture.invalid/cid/120x40"', self.body)

    def test_remote_image_size_chain(self):
        self.assertIn('src="https://fixture.invalid/img/320x160"', self.body)  # container td
        self.assertIn('src="https://fixture.invalid/img/200x50"', self.body)   # attr
        self.assertIn('src="https://fixture.invalid/img/1x1"', self.body)      # tracking pixel
        self.assertIn('src="https://fixture.invalid/img/280x70"', self.body)   # css
        self.assertIn('src="https://fixture.invalid/img/600x300"', self.body)  # default
        self.assertEqual(self.fields['imageSizes'],
                         {'cid': 1, 'data': 0, 'attr': 2, 'css': 1, 'container': 1, 'default': 1})

    def test_links_keep_scheme_count_and_length(self):
        self.assertEqual(self.body.count('<a '), 3)
        self.assertIn('href="mailto:user1', self.body)
        self.assertIn('href="tel:+1555', self.body)
        visible = 'https://acme-corp.com/story/2026'
        self.assertIn('Read https://link', self.body)
        start = self.body.index('Read ') + len('Read ')
        self.assertEqual(len(self.body[start:self.body.index('</a>', start)]), len(visible))

    def test_markup_is_kept(self):
        self.assertIn('<p class="Hero">Hi, ', self.body)
        self.assertIn('<style>.Hero{color:red}</style>', self.body)
        self.assertIn('<td width="320"><img src=', self.body)
        self.assertIn('style="width:280px;height:70px"', self.body)

    def test_names_keep_length(self):
        self.assertIn('Hi, PersonA', self.body)
        self.assertEqual(len(self.body.split('\n')[1]), len(HTML.split('\n')[1]))

    def test_markup_is_identical_outside_rewritten_values(self):
        def mask(text):
            text = re.sub(r'(src|href)="[^"]*"', r'\1=""', text)
            return re.sub(r'>[^<]*<', '><', text)
        self.assertEqual(mask(self.body).rstrip('\n'), mask(HTML))

    def test_plain_text_only_email(self):
        body, fields, _ = converter.convert(_eml(with_plain=False))
        self.assertEqual(fields['contentType'], 'text/plain')
        self.assertNotIn('acme-corp.com', body)
        self.assertNotIn('Alice Martin', body)


def _convert_html(html, sender='Alice Martin <alice.martin@acme-corp.com>'):
    message = EmailMessage()
    message['From'] = sender
    message['To'] = 'Bob Stone <bob@acme-corp.com>'
    message.set_content(html, subtype='html')
    return converter.convert(message.as_bytes())


class RegressionTest(unittest.TestCase):

    def test_src_inside_an_earlier_attribute_value_is_not_rewritten(self):
        body, _, _ = _convert_html(
            '<img alt="see src=x" src="https://h.example/i.png" width="5" height="5">')
        self.assertIn('<img alt="see src=x" src="https://fixture.invalid/img/5x5" width="5"', body)

    def test_leftover_next_to_a_placeholder_is_reported(self):
        _, _, report = _convert_html(
            '<a href="https://acme-corp.com/x">secret.acme-shop.shop</a><b>12345678901</b>')
        self.assertIn('secret.acme-shop.shop', report['leftovers']['hosts'])
        self.assertIn('12345678901', report['leftovers']['longDigits'])

    def test_names_first_name_case_entity_comment_and_title(self):
        body, _, _ = _convert_html(
            '<!-- Prepared for Alice Martin --><p title="Alice">Hi Alice, ALICE MARTIN, '
            'Alice&nbsp;Martin</p>')
        self.assertNotRegex(body, '(?i)alice|martin')

    def test_names_in_quoted_reply_headers(self):
        body, _, _ = _convert_html(
            '<blockquote>From: Carol Doe &lt;carol@doe-mail.org&gt;<br>'
            'On Mon, Dave Roe &lt;dave@doe-mail.org&gt; wrote:</blockquote>')
        self.assertNotRegex(body, 'Carol|Dave|Doe|Roe|doe-mail')

    def test_relative_protocol_relative_and_source_urls(self):
        body, _, report = _convert_html(
            '<a href="//tracker.acme-shop.xyz/p/1234?u=bob">t</a>'
            '<a href="/unsubscribe?email=bob%40x&id=A1B2C3">u</a>'
            '<td background="images/bob-photo.jpg"></td>'
            '<picture><source srcset="/img/bob.webp 2x"></picture>'
            '<div style="background:url(//cdn.acme-shop.xyz/bg.jpg)"></div>'
            '<p>https://h.example/a(b)/c?id=998877</p>')
        for secret in ('tracker', 'acme-shop', 'unsubscribe', 'A1B2C3', 'bob', '998877'):
            self.assertNotIn(secret, body, secret)
        self.assertEqual(report['leftovers']['hosts'], [])

    def test_mailto_query_is_replaced(self):
        body, _, _ = _convert_html(
            '<a href="mailto:a@b.example?subject=Order%2012345&amp;body=Hi%20Bob">m</a>')
        self.assertNotIn('Order', body)
        self.assertNotIn('Bob', body)
        self.assertIn('href="mailto:user1@example.invalid', body)

    def test_attribute_names_and_classes_are_kept(self):
        body, _, _ = _convert_html(
            '<p class="Hero" id="Hero-top" style="font-family:Hero">Hero</p>',
            sender='Hero <hero@x.example>')
        self.assertIn('<p class="Hero" id="Hero-top" style="font-family:Hero">', body)
        self.assertNotIn('>Hero<', body)

    def test_data_uri_image_is_measured_and_replaced(self):
        uri = 'data:image/png;base64,' + base64.b64encode(_png(64, 32)).decode()
        body, fields, _ = _convert_html('<img src="%s">' % uri)
        self.assertIn('src="https://fixture.invalid/img/64x32"', body)
        self.assertEqual(fields['imageSizes']['data'], 1)


class CliTest(unittest.TestCase):

    def test_identical_bytes_across_processes_and_hash_seeds(self):
        names = 'Anna Lee <a@aaaa.example>, Bert Kim <b@bbbb.example>, Cleo Ray <c@cccc.example>'
        message = EmailMessage()
        message['From'] = 'Dana Fox <d@dddd.example>'
        message['To'] = names
        message.set_content('<p>Anna Lee, Bert Kim, Cleo Ray, Dana Fox at aaaa.example '
                            'bbbb.example cccc.example</p>', subtype='html')
        with tempfile.TemporaryDirectory() as tmp:
            eml_path = os.path.join(tmp, 'mail-7.eml')
            with open(eml_path, 'wb') as handle:
                handle.write(message.as_bytes())
            outputs = set()
            for seed in ('1', '2', '3', '4'):
                out = os.path.join(tmp, seed)
                subprocess.run(
                    [sys.executable, converter.__file__, eml_path, '--id', '7',
                     '--name', 'seeded', '--out', out],
                    check=True, capture_output=True,
                    env=dict(os.environ, PYTHONHASHSEED=seed))
                with open(os.path.join(out, 'real', 'seeded.html'), 'rb') as handle:
                    outputs.add(handle.read())
            self.assertEqual(len(outputs), 1)

    def test_rejects_bad_id_and_name(self):
        with tempfile.TemporaryDirectory() as tmp:
            eml_path = os.path.join(tmp, 'mail-5.eml')
            with open(eml_path, 'wb') as handle:
                handle.write(_eml())
            for argv in (['--id', 'Quarterly news'], ['--id', '5', '--name', '../x']):
                with self.assertRaises(SystemExit):
                    with contextlib.redirect_stderr(io.StringIO()):
                        converter.main([eml_path, '--dry-run'] + argv)

    def test_writes_identical_files_twice(self):
        with tempfile.TemporaryDirectory() as tmp:
            eml_path = os.path.join(tmp, 'mail-12.eml')
            with open(eml_path, 'wb') as handle:
                handle.write(_eml())
            outputs = []
            for run in ('a', 'b'):
                out = os.path.join(tmp, run)
                _quiet_main([eml_path, '--id', '12', '--category', 'real',
                                '--name', 'news', '--purpose', 'test',
                                '--expect', 'fullDisplay,lazyImages', '--out', out])
                files = {}
                for name in ('news.html', 'news.json'):
                    with open(os.path.join(out, 'real', name), 'rb') as handle:
                        files[name] = handle.read()
                outputs.append(files)
            self.assertEqual(outputs[0], outputs[1])
            sidecar = json.loads(outputs[0]['news.json'])
            self.assertEqual(sidecar['source'], 'eml #12, anonymized')
            self.assertEqual(sidecar['contentType'], 'text/html')
            self.assertEqual(sidecar['expect'], ['fullDisplay', 'lazyImages'])
            self.assertEqual(sidecar['minPreservation'], 0.95)

    def test_dry_run_writes_nothing(self):
        with tempfile.TemporaryDirectory() as tmp:
            eml_path = os.path.join(tmp, 'mail-3.eml')
            with open(eml_path, 'wb') as handle:
                handle.write(_eml())
            out = os.path.join(tmp, 'out')
            _quiet_main([eml_path, '--id', '3', '--dry-run', '--out', out])
            self.assertFalse(os.path.exists(out))

    def test_refuses_eml_inside_the_repo(self):
        with self.assertRaises(SystemExit):
            converter.main([os.path.join(HERE, 'inside.eml'), '--id', '1', '--dry-run'])

    def test_rejects_unknown_expect(self):
        with tempfile.TemporaryDirectory() as tmp:
            eml_path = os.path.join(tmp, 'mail-4.eml')
            with open(eml_path, 'wb') as handle:
                handle.write(_eml())
            with self.assertRaises(SystemExit):
                _quiet_main([eml_path, '--id', '4', '--expect', 'fullDisplai', '--dry-run'])


class OfflineTest(unittest.TestCase):

    def test_imports_no_network_module(self):
        with open(converter.__file__, encoding='utf-8') as handle:
            tree = ast.parse(handle.read())
        imported = set()
        for node in ast.walk(tree):
            if isinstance(node, ast.Import):
                imported.update(alias.name.split('.')[0] for alias in node.names)
            elif isinstance(node, ast.ImportFrom) and node.module:
                imported.add(node.module.split('.')[0])
        network = {'urllib', 'http', 'socket', 'ssl', 'ftplib', 'requests',
                   'smtplib', 'asyncio', 'subprocess'}
        self.assertEqual(imported & network, set())


if __name__ == '__main__':
    unittest.main()
