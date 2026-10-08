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
        self.assertIn('src="https://fixture.invalid/est/600x300"', self.body)  # default
        self.assertEqual(self.fields['imageSizes'],
                         {'cid': 1, 'data': 0, 'attr': 2, 'css': 1, 'container': 1, 'default': 1})

    def test_links_keep_scheme_count_and_length(self):
        self.assertEqual(self.body.count('<a '), 3)
        self.assertIn('href="mailto:user1', self.body)
        self.assertIn('href="tel:+1555', self.body)
        visible = 'https://acme-corp.com/story/2026'
        start = self.body.index('>', self.body.index('href="https://link')) + 1
        shown = self.body[start:self.body.index('</a>', start)]
        # The visible URL keeps its scheme and length, its words are replaced.
        self.assertRegex(shown, r'^\w{4} https://')
        self.assertEqual(len(shown), len('Read ' + visible))
        self.assertNotIn('acme', shown)

    def test_markup_is_kept(self):
        self.assertIn('<p class="Hero">', self.body)
        self.assertIn('<style>.Hero{color:red}</style>', self.body)
        self.assertIn('<td width="320"><img src=', self.body)
        self.assertIn('style="width:280px;height:70px"', self.body)

    def test_text_is_scrambled_keeping_length(self):
        line = self.body.split('\n')[1]
        self.assertEqual(len(line), len(HTML.split('\n')[1]))
        for word in ('Hi', 'Alice', 'Martin', 'wrote', 'from'):
            self.assertNotIn(word, line)
        self.assertGreater(self.report['scrambledChars'], 20)

    def test_markup_is_identical_outside_rewritten_values(self):
        def mask(text):
            text = re.sub(r'(src|href|alt)="[^"]*"', r'\1=""', text)
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


class ScramblerTest(unittest.TestCase):

    def test_replaces_words_with_real_words_of_the_same_length(self):
        import fixture_words
        scrambler = converter.TextScrambler('seed')
        source = ('Hello Alice, your ORDER is ready. Tiếng Việt 123 مرحبا 你好 😀 '
                  '&nbsp; https://link1.invalid/xx user1@example.invalid')
        out = scrambler.text(source)
        self.assertEqual(len(out), len(source))
        for word in ('Hello', 'Alice', 'ORDER', 'ready', 'Tiếng', 'Việt', '123', 'مرحبا', '你好'):
            self.assertNotIn(word, out)
        self.assertIn('😀 &nbsp; https://link1.invalid/xx user1@example.invalid', out)
        english = {w.lower() for group in fixture_words.ENGLISH_BY_LENGTH.values() for w in group}
        words = out.split()
        self.assertIn(words[0].lower(), english)              # Hello -> a real word
        self.assertTrue(words[0][0].isupper())                 # case kept
        self.assertTrue(words[3].isupper())                    # ORDER -> upper case
        vietnamese = {w.lower() for group in fixture_words.VIETNAMESE_BY_LENGTH.values() for w in group}
        self.assertIn(words[6].lower(), vietnamese)            # Tiếng -> a Vietnamese syllable

    def test_long_words_become_two_real_words(self):
        out = converter.TextScrambler('seed').text('internationalization')
        self.assertEqual(len(out), len('internationalization'))

    def test_is_deterministic_per_seed(self):
        self.assertEqual(converter.TextScrambler('a').text('Hello world'),
                         converter.TextScrambler('a').text('Hello world'))

    def test_comment_text_is_scrambled_but_markup_kept(self):
        body, _, _ = _convert_html('<!--[if mso]><table><tr><td>Secret plan</td></tr></table><![endif]--><p>x</p>')
        self.assertIn('<!--[if mso]><table><tr><td>', body)
        self.assertIn('</td></tr></table><![endif]-->', body)
        self.assertNotIn('Secret', body)

    def test_style_inside_a_conditional_comment_keeps_its_css(self):
        css = '<style>table{border-collapse:collapse} .x{font-size:12px !important}</style>'
        body, _, _ = _convert_html('<!--[if mso]>%s<p>Secret plan</p><![endif]--><p>x</p>' % css)
        self.assertIn(css, body)
        self.assertNotIn('Secret', body)

    def test_gt_inside_a_comment_tag_value_keeps_the_tag(self):
        body, _, _ = _convert_html('<!--[if mso]><v:rect fillcolor="a>b" stroke="f"></v:rect><![endif]-->')
        self.assertIn('fillcolor="a>b" stroke="f"', body)

    def test_style_and_script_are_not_scrambled(self):
        body, _, _ = _convert_html('<style>.Hero{font-family:Arial}</style><p>Hi</p>')
        self.assertIn('<style>.Hero{font-family:Arial}</style>', body)


class RegressionTest(unittest.TestCase):

    def test_hex_colours_and_css_functions_are_not_renamed(self):
        body, _, _ = _convert_html(
            '<style>#cafe {color:#cafe00} .b{background:linear-gradient(#cafe,#fff)}</style>'
            '<p class="cafe">Hi</p>', sender='Linear Cafe <x@cafe.example>')
        self.assertIn('color:#cafe00', body)
        self.assertIn('linear-gradient(#cafe,', body)
        self.assertNotIn('#cafe {', body)
        self.assertNotIn('class="cafe"', body)

    def test_meta_data_and_aria_values_are_anonymized(self):
        body, _, _ = _convert_html(
            '<meta name="contact" content="bob@corp.example +1 415 555 0134">'
            '<div data-user="Bob Smith" aria-description="Bob Smith">x</div>',
            sender='Bob Smith <bob@corp.example>')
        self.assertNotIn('bob@corp.example', body)
        self.assertNotIn('415 555', body)
        self.assertNotIn('Bob Smith', body)

    def test_leftovers_scan_unquoted_values_and_gt_in_quotes(self):
        _, _, report = _convert_html('<div title="a>b" lang=crm.acme-shop.shop>x</div>')
        self.assertIn('crm.acme-shop.shop', report['leftovers']['hosts'])

    def test_src_inside_an_earlier_attribute_value_is_not_rewritten(self):
        body, _, _ = _convert_html(
            '<img alt="see src=x" src="https://h.example/i.png" width="5" height="5">')
        self.assertRegex(body, r'<img alt="[a-z]{3} [a-z]{3}=[a-z]" src="https://fixture.invalid/img/5x5" width="5"')

    def test_visible_hosts_and_numbers_are_scrambled(self):
        body, _, _ = _convert_html(
            '<a href="https://acme-corp.com/x">secret.acme-shop.shop</a><b>12345678901</b>')
        self.assertNotIn('acme-shop', body)
        self.assertNotIn('12345678901', body)

    def test_markup_leftovers_are_reported(self):
        _, _, report = _convert_html(
            '<div id="12345678901" title="x" lang="crm.acme-shop.shop">x</div>')
        self.assertIn('12345678901', report['leftovers']['longDigits'])
        self.assertIn('crm.acme-shop.shop', report['leftovers']['hosts'])

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

    def test_other_scheme_values_are_replaced(self):
        body, _, _ = _convert_html(
            '<a href="sms:+84901234567">s</a><a href="geo:21.0285,105.8542">g</a>'
            '<a href="zoommtg://zoom.us/join?confno=98765432101">z</a>'
            '<a href="webcal://calendar.acme-shop.xyz/team.ics">w</a>')
        for secret in ('84901234567', '21.0285', '105.8542', 'zoom.us', '98765432101', 'acme-shop'):
            self.assertNotIn(secret, body, secret)
        for scheme in ('sms:', 'geo:', 'zoommtg:', 'webcal:'):
            self.assertIn('href="' + scheme, body)

    def test_rendering_metadata_and_namespaces_are_kept(self):
        body, _, _ = _convert_html(
            '<html xmlns="http://www.w3.org/1999/xhtml"><head>'
            '<meta name="viewport" content="width=device-width, initial-scale=1">'
            '<meta name="format-detection" content="telephone=no">'
            '<meta name="author" content="Alice Martin"></head>'
            '<body><div itemscope itemtype="http://schema.org/EmailMessage">Hi</div></body></html>')
        self.assertIn('xmlns="http://www.w3.org/1999/xhtml"', body)
        self.assertIn('content="width=device-width, initial-scale=1"', body)
        self.assertIn('content="telephone=no"', body)
        self.assertIn('itemtype="http://schema.org/EmailMessage"', body)
        self.assertNotIn('Alice', body)

    def test_css_identifiers_are_never_renamed(self):
        body, _, _ = _convert_html(
            '<style><!-- /* Font Definitions */ p{-webkit-text-size-adjust:100%}'
            '.Adjust-email{font-family:"Adjust Sans"} --></style><p>Hi</p>',
            sender='Adjust <adjust@x.example>')
        self.assertIn('<!-- /* Font Definitions */ p{-webkit-text-size-adjust:100%}'
                      '.Adjust-email{font-family:"Adjust Sans"} --></style>', body)

    def test_gt_inside_an_attribute_value_keeps_the_attribute_names(self):
        body, _, _ = _convert_html('<article title="a > b" class="turn" data-turn-id="t1">Hi</article>')
        self.assertRegex(body, r'<article title="[^"]*" class="turn" data-turn-id="x0">')

    def test_unquoted_css_url_keeps_the_following_properties(self):
        body, _, _ = _convert_html(
            '<div style="background-image:url(https://cdn.acme-shop.xyz/b.png);'
            'background-position:-1% -1%;background-repeat:no-repeat">x</div>')
        self.assertRegex(body, r'background-image:url\([^)]*\);background-position:-1% -1%;'
                               r'background-repeat:no-repeat')
        self.assertNotIn('acme-shop', body)

    def test_mailto_query_is_replaced(self):
        body, _, _ = _convert_html(
            '<a href="mailto:a@b.example?subject=Order%2012345&amp;body=Hi%20Bob">m</a>')
        self.assertNotIn('Order', body)
        self.assertNotIn('Bob', body)
        self.assertIn('href="mailto:user1@example.invalid', body)

    def test_sender_name_in_css_identifiers_is_renamed_consistently(self):
        body, _, _ = _convert_html(
            '<style>.Hero-logo{color:red} #Hero-top{margin:0}</style>'
            '<p class="Hero-logo" id="Hero-top" style="font-family:Hero Sans">Hero</p>',
            sender='Hero <hero@hero-mail.example>')
        self.assertNotIn('Hero', body)
        fake = re.search(r'class="(\w+)-logo"', body).group(1)
        self.assertEqual(len(fake), 4)
        self.assertIn('.%s-logo{color:red} #%s-top{margin:0}' % (fake, fake), body)
        self.assertIn('id="%s-top" style="font-family:%s Sans"' % (fake, fake), body)

    def test_css_vocabulary_is_never_renamed(self):
        body, _, _ = _convert_html(
            '<p style="text-align:center;font-family:Arial" class="block">x</p>',
            sender='Center Block <a@b.example>')
        self.assertIn('style="text-align:center;font-family:Arial" class="block"', body)

    def test_urls_inside_mso_conditional_comments_are_replaced(self):
        body, _, _ = _convert_html(
            '<!--[if mso]><v:roundrect href="https://acme-shop.xyz/offer?id=88123456" '
            'style="width:200px"><center>Buy now</center></v:roundrect><![endif]--><p>x</p>')
        self.assertNotIn('acme-shop', body)
        self.assertNotIn('88123456', body)
        self.assertIn('style="width:200px"', body)

    def test_url_named_and_data_attributes_are_anonymized(self):
        body, _, _ = _convert_html(
            '<a href="/x" data-hovercard-url="/users/alice.martin/hovercard" '
            'data-id="12345678901"><img src="https://x.example/a.png" public-asset-id="ab12-9f3c"></a>')
        self.assertNotIn('alice', body)
        self.assertIn('data-id="00000000000"', body)
        self.assertIn('public-asset-id="xx00-0x0x"', body)

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
