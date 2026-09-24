/// Bundles the resize/compress knobs of an inline-image download into one
/// named parameter, keeping downloadImageAsBase64's arg count within limits.
typedef ImageDownloadOptions = ({double? maxWidth, bool? compress});
