#!/usr/bin/env python3
"""Convert a real .eml file into an anonymized HTML email display fixture.

Local dev tool, never run on CI. Python stdlib only, and fully offline: it
never imports a network module and never fetches a remote image. See
core/tool/README-html-email-fixtures.md.

    python3 tool/eml_to_fixture.py <path/outside/repo/x.eml> \
        --id 12 --category newsletter_builders --name promo_two_columns \
        --purpose "two-column promo that must stack on phones"

Writes <category>/<name>.html and <name>.json under
core/test/fixtures/html_emails/ and prints a privacy report. The same EML
always produces byte-identical output, in any process.
"""

import argparse
import base64
import binascii
import email
import email.policy
import email.utils
import html as html_lib
import json
import os
import re
import struct
import sys
from html.parser import HTMLParser

FIXTURE_HOST = 'https://fixture.invalid'
DEFAULT_IMAGE_SIZE = (600, 300)
EXPECT_VALUES = ('fullDisplay', 'lazyImages', 'autoScale', 'noScale', 'quoteToggle',
                 'noQuoteToggle')
SIZE_SOURCES = ('cid', 'data', 'attr', 'css', 'container', 'default')

# Absolute (http/https/ftp) or protocol-relative URL.
_URL_RE = re.compile(
    r'''(?i)(?:\b(?:https?|ftp):|(?<![\w:/]))//[a-z0-9\[][^\s"'<>\\]*''')
_EMAIL_RE = re.compile(r'(?i)\b[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}\b')
_PX_RE = re.compile(r'^\s*(\d+(?:\.\d+)?)\s*(?:px)?\s*(?:!important)?\s*$', re.I)
_HOST_RE = re.compile(r'(?i)\b(?:[a-z0-9-]+\.)+[a-z]{2,}\b')
_LONG_DIGITS_RE = re.compile(r'\b\d{8,}\b')
_PHONE_RE = re.compile(r'(?<![\w.])\+?\d(?:[ .-]?\d){8,}(?![\w.])')
_ID_RE = re.compile(r'^\d+(?:-\d+)?$')
_SLUG_RE = re.compile(r'^[a-z0-9_]+$')
_ATTR_RE = re.compile(r'''(\s+)([^\s=/>]+)(?:(\s*=\s*)("[^"]*"|'[^']*'|[^\s>]+))?''')
_PLACEHOLDER_HOST_RE = re.compile(r'(?i)^(?:[a-z]+:)?//(?:fixture|link\d+)\.invalid(?:/|$)')

# Attributes whose value is a URL (or a srcset list of URLs).
URL_ATTRIBUTES = {'href', 'src', 'background', 'action', 'poster', 'srcset',
                  'data-src', 'longdesc', 'cite'}
# Attributes whose value is human text, so names and domains are replaced.
TEXT_ATTRIBUTES = {'alt', 'title', 'value', 'content', 'aria-label',
                   'placeholder', 'label', 'summary'}
# Header name words too generic to treat as private.
NAME_STOPWORDS = {'team', 'support', 'info', 'noreply', 'no-reply', 'the', 'and',
                  'news', 'newsletter', 'service', 'mail', 'admin', 'contact',
                  'hello', 'notification', 'notifications', 'from', 'via'}


def _sorted_strings(values):
    """Longest first, then alphabetical: stable across processes."""
    return sorted(values, key=lambda value: (-len(value), value))


def _pad(base, length, filler='x'):
    return base + filler * (length - len(base)) if len(base) < length else base


# ---------------------------------------------------------------- images

def image_size_from_bytes(data):
    """Returns (width, height) for PNG/GIF/JPEG bytes, else None."""
    if data[:8] == b'\x89PNG\r\n\x1a\n' and len(data) >= 24:
        return struct.unpack('>II', data[16:24])
    if data[:6] in (b'GIF87a', b'GIF89a') and len(data) >= 10:
        return struct.unpack('<HH', data[6:10])
    if data[:2] == b'\xff\xd8':
        i = 2
        while i + 9 < len(data):
            if data[i] != 0xFF:
                i += 1
                continue
            marker = data[i + 1]
            if marker in (0xD8, 0x01) or 0xD0 <= marker <= 0xD7:
                i += 2
                continue
            length = struct.unpack('>H', data[i + 2:i + 4])[0]
            if 0xC0 <= marker <= 0xCF and marker not in (0xC4, 0xC8, 0xCC):
                height, width = struct.unpack('>HH', data[i + 5:i + 9])
                return width, height
            i += 2 + length
    return None


def _data_uri_size(uri):
    match = re.match(r'(?is)data:image/[\w.+-]+;base64,(.*)$', uri)
    if not match:
        return None
    try:
        return image_size_from_bytes(base64.b64decode(match.group(1)[:4096] + '==='))
    except (binascii.Error, ValueError):
        return None


def _px(value):
    if value is None:
        return None
    match = _PX_RE.match(value)
    return int(float(match.group(1))) if match else None


def _style_px(style, prop):
    if not style:
        return None
    match = re.search(r'(?i)(?:^|;)\s*' + prop + r'\s*:\s*([^;]+)', style)
    return _px(match.group(1)) if match else None


# ------------------------------------------------------------ anonymizer

class Anonymizer:
    """Replaces URLs, addresses, names and sender domains with stable,
    same-length placeholders (layout-neutral where possible)."""

    def __init__(self, names, domains):
        words = set()
        for name in names:
            for word in re.split(r'[\s,"]+', name):
                if len(word) >= 3 and word.lower() not in NAME_STOPWORDS:
                    words.add(word)
        self.names = _sorted_strings({n for n in names if len(n) >= 3})
        self.words = _sorted_strings(words)
        self.domains = _sorted_strings({d for d in domains if d})
        self.urls = {}
        self.relative = {}
        self.emails = {}
        self.counts = {'urls': 0, 'mailto': 0, 'tel': 0, 'addresses': 0,
                       'names': 0, 'domains': 0}

    # -- urls
    def fake_url(self, url):
        trimmed = url
        while trimmed.endswith(')') and trimmed.count('(') < trimmed.count(')'):
            trimmed = trimmed[:-1]
        tail = url[len(trimmed):]
        if _PLACEHOLDER_HOST_RE.match(trimmed):
            return url
        self.counts['urls'] += 1
        if trimmed not in self.urls:
            scheme = trimmed.split('//', 1)[0]
            base = '%s//link%d.invalid/' % (scheme.lower(), len(self.urls) + 1)
            self.urls[trimmed] = _pad(base, len(trimmed))
        return self.urls[trimmed] + tail

    def fake_relative(self, value):
        self.counts['urls'] += 1
        if value not in self.relative:
            self.relative[value] = _pad('rel%d/' % (len(self.relative) + 1), len(value))
        return self.relative[value]

    def fake_email(self, address):
        if address.lower().endswith('@example.invalid'):
            return address
        self.counts['addresses'] += 1
        key = address.lower()
        if key not in self.emails:
            domain = '@example.invalid'
            local = _pad('user%d' % (len(self.emails) + 1), len(address) - len(domain))
            self.emails[key] = local + domain
        return self.emails[key]

    def url_value(self, value):
        """Anonymizes one URL-valued attribute value."""
        stripped = value.strip()
        lower = stripped.lower()
        if not stripped or stripped.startswith('#') or _PLACEHOLDER_HOST_RE.match(stripped):
            return value
        if lower.startswith(('cid:', 'data:', 'javascript:', 'about:')):
            return value
        if lower.startswith('mailto:'):
            self.counts['mailto'] += 1
            rest = stripped[len('mailto:'):]
            address = _EMAIL_RE.search(rest)
            fake = self.fake_email(address.group(0)) if address else 'user@example.invalid'
            extra = len(rest) - len(fake)
            return 'mailto:' + fake + ('?' + 'x' * (extra - 1) if extra > 0 else '')
        if lower.startswith('tel:'):
            self.counts['tel'] += 1
            return 'tel:' + _pad('+1555', len(stripped) - 4, '0')
        if _URL_RE.match(stripped):
            return _URL_RE.sub(lambda m: self.fake_url(m.group(0)), stripped)
        if re.match(r'(?i)^[a-z][a-z0-9+.-]*:', stripped):
            return value  # other schemes (sms:, webcal:...) carry no host here
        return self.fake_relative(stripped)

    def srcset_value(self, value):
        return ', '.join(
            ' '.join([self.url_value(item.split()[0])] + item.split()[1:])
            for item in value.split(',') if item.strip())

    # -- text
    def text(self, text):
        """URLs, addresses and identities in free text (body, comments, CSS)."""
        text = _URL_RE.sub(lambda m: self.fake_url(m.group(0)), text)
        text = re.sub(r'''(?i)url\(\s*(['"]?)([^'")]+)\1\s*\)''',
                      lambda m: 'url(%s%s%s)' % (m.group(1), self.url_value(m.group(2)), m.group(1)),
                      text)
        text = _EMAIL_RE.sub(lambda m: self.fake_email(m.group(0)), text)
        return self.identities(text)

    def identities(self, text):
        separator = r'(?:\s|&nbsp;|&#160;|&#xa0;)+'
        for index, name in enumerate(self.names):
            pattern = separator.join(re.escape(word) for word in name.split())
            fake = _pad('Person%s' % chr(ord('A') + index % 26), len(name))
            text, n = re.subn(r'(?i)(?<!\w)' + pattern + r'(?!\w)', fake, text)
            self.counts['names'] += n
        for index, word in enumerate(self.words):
            fake = _pad('N%d' % (index + 1), len(word))
            text, n = re.subn(r'(?i)(?<!\w)' + re.escape(word) + r'(?!\w)', fake, text)
            self.counts['names'] += n
        for index, domain in enumerate(self.domains):
            fake = _pad('d%d' % (index + 1), len(domain) - len('.invalid')) + '.invalid'
            text, n = re.subn(r'(?i)(?<![\w.-])' + re.escape(domain) + r'(?![\w-])', fake, text)
            self.counts['domains'] += n
        return text


# ------------------------------------------------------ start-tag rewrite

def rewrite_attributes(tag_text, rewrite):
    """Rebuilds a start tag, calling rewrite(name, value) for each attribute
    value in order. Unchanged values are kept byte for byte."""
    head = re.match(r'(?s)<[^\s/>]+', tag_text)
    if not head:
        return tag_text
    end = len(tag_text) - len(re.search(r'\s*/?>$', tag_text).group(0)) \
        if re.search(r'\s*/?>$', tag_text) else len(tag_text)
    out = [head.group(0)]
    position = head.end()
    for match in _ATTR_RE.finditer(tag_text, position, end):
        if match.start() != position:
            break
        space, name, equals, raw = match.groups()
        out.append(space + name)
        if raw is not None:
            quote = raw[0] if raw[0] in '"\'' else ''
            value = raw[1:-1] if quote else raw
            new_value = rewrite(name.lower(), value)
            if new_value != value:
                if not quote:
                    quote = '"'
                raw = quote + new_value.replace(quote, '&quot;' if quote == '"' else '&#39;') + quote
            out.append(equals + raw)
        position = match.end()
    out.append(tag_text[position:])
    return ''.join(out)


class _TagRewriter(HTMLParser):
    """Records start-tag rewrites by source offset so the rest of the markup
    is kept byte for byte."""

    def __init__(self, source, cid_sizes, anonymizer):
        super().__init__(convert_charrefs=False)
        self.cid_sizes = cid_sizes
        self.anonymizer = anonymizer
        self.line_offsets = [0]
        for match in re.finditer('\n', source):
            self.line_offsets.append(match.end())
        self.containers = []  # (tag, width or None)
        self.edits = []  # (start, end, replacement)
        self.size_counts = {key: 0 for key in SIZE_SOURCES}

    def _offset(self):
        line, column = self.getpos()
        return self.line_offsets[line - 1] + column

    def handle_starttag(self, tag, attrs):
        self._start(tag, attrs, closes=False)

    def handle_startendtag(self, tag, attrs):
        self._start(tag, attrs, closes=True)

    def handle_endtag(self, tag):
        if tag in ('td', 'th', 'table'):
            for index in range(len(self.containers) - 1, -1, -1):
                if self.containers[index][0] == tag:
                    del self.containers[index:]
                    break

    def _start(self, tag, attrs, closes):
        attr_map = {name: value or '' for name, value in attrs}
        if tag in ('td', 'th') and self.containers and self.containers[-1][0] in ('td', 'th'):
            self.containers.pop()  # implicitly closed cell
        if tag in ('td', 'th', 'table') and not closes:
            width = _px(attr_map.get('width')) or _style_px(attr_map.get('style'), 'width')
            self.containers.append((tag, width))
        raw = self.get_starttag_text()
        image = self._image_placeholder(attr_map) if tag == 'img' else None

        def rewrite(name, value):
            if image and name in ('src', 'srcset'):
                return image
            if name == 'srcset':
                return self.anonymizer.srcset_value(value)
            if name in URL_ATTRIBUTES:
                return self.anonymizer.url_value(value)
            value = _EMAIL_RE.sub(lambda m: self.anonymizer.fake_email(m.group(0)),
                                  _URL_RE.sub(lambda m: self.anonymizer.fake_url(m.group(0)), value))
            if name == 'style':
                value = re.sub(r'''(?i)url\(\s*(['"]?)([^'")]+)\1\s*\)''',
                               lambda m: 'url(%s%s%s)' % (m.group(1), self.anonymizer.url_value(m.group(2)), m.group(1)),
                               value)
            if name in TEXT_ATTRIBUTES:
                value = self.anonymizer.identities(value)
            return value

        replacement = rewrite_attributes(raw, rewrite)
        if replacement != raw:
            start = self._offset()
            self.edits.append((start, start + len(raw), replacement))

    def _container_width(self):
        for _, width in reversed(self.containers):
            if width:
                return width
        return None

    def _measure(self, src, attrs):
        if src.lower().startswith('cid:'):
            size = self.cid_sizes.get(src[4:].strip('<>'))
            if size:
                return 'cid', size
        if src.lower().startswith('data:'):
            size = _data_uri_size(src)
            if size:
                return 'data', size
        style = attrs.get('style')
        attr_w, attr_h = _px(attrs.get('width')), _px(attrs.get('height'))
        if attr_w is not None:
            return 'attr', (attr_w, attr_h if attr_h is not None else attr_w // 2)
        css_w, css_h = _style_px(style, 'width'), _style_px(style, 'height')
        if css_w is not None:
            return 'css', (css_w, css_h if css_h is not None else css_w // 2)
        container = self._container_width()
        if container:
            return 'container', (container, attr_h or css_h or container // 2)
        return 'default', DEFAULT_IMAGE_SIZE

    def _image_placeholder(self, attrs):
        source, (width, height) = self._measure(attrs.get('src') or '', attrs)
        self.size_counts[source] += 1
        kind = 'cid' if source == 'cid' else 'img'
        return '%s/%s/%dx%d' % (FIXTURE_HOST, kind, width, height)


def rewrite_html(html, cid_sizes, anonymizer):
    parser = _TagRewriter(html, cid_sizes, anonymizer)
    parser.feed(html)
    parser.close()
    out = html
    for start, end, replacement in sorted(parser.edits, reverse=True):
        out = out[:start] + replacement + out[end:]
    # Free text, comments and <style> CSS; start tags were rewritten above.
    parts = re.split(r'(?s)(<!--.*?-->|<[^>]*>)', out)
    for index, part in enumerate(parts):
        if part.startswith('<!--') or not part.startswith('<'):
            parts[index] = anonymizer.text(part)
    return ''.join(parts), parser.size_counts


# ------------------------------------------------------------ identities

def header_identities(message):
    names, domains = set(), set()
    for header in ('from', 'to', 'cc', 'bcc', 'reply-to', 'sender', 'delivered-to'):
        for value in message.get_all(header, []):
            for name, address in email.utils.getaddresses([str(value)]):
                if name:
                    names.add(name.strip().strip('"'))
                if '@' in address:
                    domains.add(address.rsplit('@', 1)[1].lower())
    return names, domains


def body_identities(body):
    """Names written before an address in the body, e.g. quoted reply
    headers: 'From: Carol Doe <carol@x>' or 'Carol Doe &lt;carol@x&gt; wrote:'."""
    text = html_lib.unescape(re.sub(r'<[^>]*>', ' ', body))
    names, domains = set(), set()
    pattern = r"([A-Z][\w'.-]+(?:[ \t\xa0]+[A-Z][\w'.-]+){0,3})[ \t\xa0]*[<\[(]\s*(?:mailto:)?" \
              r"[^<>@\s]+@((?i:[a-z0-9.-]+\.[a-z]{2,}))"
    for match in re.finditer(pattern, text):
        names.add(re.sub(r'[ \t\xa0]+', ' ', match.group(1)))
        domains.add(match.group(2).lower())
    return names, domains


def suspicious_leftovers(text):
    visible = re.sub(r'(?is)<(style|script)\b.*?</\1>', ' ', text)
    visible = html_lib.unescape(re.sub(r'(?s)<!--.*?-->|<[^>]*>', ' ', visible))
    visible = re.sub(r'(?i)(?:[a-z]+:)?//(?:fixture|link\d+)\.invalid/[^\s"\'<>)]*', ' ', visible)
    visible = re.sub(r'(?i)\b(?:d\d+x*|example|link\d+|fixture)\.invalid\b', ' ', visible)
    everything = re.sub(r'(?i)(?:[a-z]+:)?//(?:fixture|link\d+)\.invalid/[^\s"\'<>)]*', ' ', text)
    return {
        'hosts': sorted(set(_HOST_RE.findall(visible))
                        | set(re.findall(r'(?i)//([a-z0-9-]+(?:\.[a-z0-9-]+)+)', everything))),
        'emails': sorted(e for e in set(_EMAIL_RE.findall(html_lib.unescape(everything)))
                         if not e.lower().endswith('@example.invalid')),
        'longDigits': sorted(set(_LONG_DIGITS_RE.findall(visible))),
        'phones': sorted(set(_PHONE_RE.findall(visible))),
    }


# ------------------------------------------------------------- converter

def _cid_sizes(message):
    sizes = {}
    for part in message.walk():
        cid = part.get('Content-ID')
        if not cid or part.get_content_maintype() != 'image':
            continue
        size = image_size_from_bytes(part.get_payload(decode=True) or b'')
        if size:
            sizes[cid.strip().strip('<>')] = size
    return sizes


def convert(eml_bytes):
    """Returns (body, sidecar_fields, report) for raw EML bytes."""
    message = email.message_from_bytes(eml_bytes, policy=email.policy.default)
    part = message.get_body(preferencelist=('html', 'plain'))
    if part is None:
        raise ValueError('no text/html or text/plain body')
    content_type = part.get_content_type()
    body = part.get_content()

    names, domains = header_identities(message)
    body_names, body_domains = body_identities(body)
    anonymizer = Anonymizer(names | body_names, domains | body_domains)

    size_counts = {key: 0 for key in SIZE_SOURCES}
    if content_type == 'text/html':
        body, size_counts = rewrite_html(body, _cid_sizes(message), anonymizer)
    else:
        body = anonymizer.text(body)

    report = dict(anonymizer.counts)
    report['images'] = size_counts
    report['leftovers'] = suspicious_leftovers(body)
    return body, {'contentType': content_type, 'imageSizes': size_counts}, report


def _real(path):
    return os.path.normcase(os.path.realpath(path))


def _repo_root(start):
    path = _real(start)
    while path != os.path.dirname(path):
        if os.path.exists(os.path.join(path, '.git')):
            return path
        path = os.path.dirname(path)
    return None


def _print_report(report, show_samples):
    print('privacy report')
    for key in ('urls', 'mailto', 'tel', 'addresses', 'names', 'domains'):
        print('  rewritten %-9s %d' % (key, report[key]))
    print('  image sizes        ' + ', '.join(
        '%s=%d' % (k, report['images'][k]) for k in SIZE_SOURCES))
    leftovers = report['leftovers']
    for key, values in leftovers.items():
        line = '  LEFTOVER %-10s %d' % (key, len(values))
        if show_samples and values:
            line += '  ' + ', '.join(values[:10])
        print(line)
    if any(leftovers.values()):
        print('  -> review leftovers before committing (--show-samples lists them)')


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__.split('\n')[0])
    parser.add_argument('eml')
    parser.add_argument('--id', required=True, help='trailing EML file ID, e.g. 12 or 41-1')
    parser.add_argument('--category', default='real')
    parser.add_argument('--name')
    parser.add_argument('--purpose', default='')
    parser.add_argument('--expect', default='', help='comma list of ' + '|'.join(EXPECT_VALUES))
    parser.add_argument('--rtl', action='store_true')
    parser.add_argument('--dry-run', action='store_true', help='print the report only')
    parser.add_argument('--show-samples', action='store_true',
                        help='print leftover values (may show private data)')
    parser.add_argument('--out', help='fixtures root (default: core/test/fixtures/html_emails)')
    args = parser.parse_args(argv)

    if not _ID_RE.match(args.id):
        parser.error('--id must be the trailing file ID, e.g. 12 or 41-1')
    name = args.name or 'eml_%s' % args.id.replace('-', '_')
    for label, value in (('--category', args.category), ('--name', name)):
        if not _SLUG_RE.match(value):
            parser.error('%s must match [a-z0-9_]+' % label)

    here = os.path.dirname(os.path.abspath(__file__))
    repo = _repo_root(here)
    eml_path = _real(args.eml)
    if repo and (eml_path + os.sep).startswith(repo + os.sep):
        parser.error('the raw EML must live outside the repo: %s' % args.eml)

    expect = [value for value in args.expect.split(',') if value]
    unknown = [value for value in expect if value not in EXPECT_VALUES]
    if unknown:
        parser.error('unknown --expect value(s): %s' % ', '.join(unknown))

    with open(eml_path, 'rb') as handle:
        body, fields, report = convert(handle.read())
    _print_report(report, args.show_samples)
    if args.dry_run:
        return 0

    out_root = args.out or os.path.join(here, '..', 'test', 'fixtures', 'html_emails')
    out_dir = os.path.join(out_root, args.category)
    os.makedirs(out_dir, exist_ok=True)
    sidecar = {
        'source': 'eml #%s, anonymized' % args.id,
        'purpose': args.purpose,
        'contentType': fields['contentType'],
        'expect': expect,
        'minPreservation': 0.95,
        'imageSizes': fields['imageSizes'],
    }
    if args.rtl:
        sidecar['rtl'] = True
    with open(os.path.join(out_dir, name + '.html'), 'w', encoding='utf-8', newline='') as handle:
        handle.write(body if body.endswith('\n') else body + '\n')
    with open(os.path.join(out_dir, name + '.json'), 'w', encoding='utf-8', newline='\n') as handle:
        handle.write(json.dumps(sidecar, indent=2, sort_keys=True, ensure_ascii=False) + '\n')
    print('wrote %s/%s.{html,json}' % (args.category, name))
    return 0


if __name__ == '__main__':
    sys.exit(main())
