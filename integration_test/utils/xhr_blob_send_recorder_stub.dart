/// `XMLHttpRequest` exists only in a browser.
void recordXhrBlobSends() =>
    throw UnsupportedError('recordXhrBlobSends is web only');

List<int> get recordedXhrBlobSendSizes =>
    throw UnsupportedError('recordedXhrBlobSendSizes is web only');
