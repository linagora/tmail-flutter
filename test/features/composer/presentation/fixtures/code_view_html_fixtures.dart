const ghsaEmbedCodeXssPayload =
    '<img src=x onerror="alert(1)"><script>alert(2)</script>'
    '<a href="javascript:alert(3)">clickme</a>'
    '<svg onload=alert(4)></svg><p>visible text</p>';

const scriptOnlyEmbedCodePayload = '<script>alert(1)</script>';

const youtubeIframeEmbed =
    '<iframe width="560" height="315" '
    'src="https://www.youtube.com/embed/dQw4w9WgXcQ"></iframe>'
    '<p>watch this</p>';

const benignComposerHtml =
    '<p>Hello <a href="https://example.com">link</a></p>'
    '<img src="cid:img-1" alt="cid image">'
    '<img src="https://cdn.example.com/sig.png" public-asset-id="sig1" '
    'data-filename="sig.png" data-mimetype="image/png">'
    '<table><tr><td>cell</td></tr></table>'
    '<a href="https://drive.example.com/file" class="tmail-file-link-card" '
    'contenteditable="false">report.pdf</a>'
    '<p>visible text</p>';
