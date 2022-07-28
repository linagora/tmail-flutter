# 11. down-size-of-base64-image

Date: 2022-07-28

## Status

Accepted

## Context

For large images (several MB or more) converting to base64 will take a long time and exceed the storage limit of the string. 
Leads to long waits on the main thread, causing a feeling of not being smooth on mobile devices with weak configuration.

## Decision

We can reduce the image `size` and `quality` when displaying.
- For mobile: 
  + Use [flutter_image_compress](https://pub.dev/packages/flutter_image_compress) to compress image use native (Objective-C/Kotlin) with faster speed.

## Consequences

- The size of the image has been significantly reduced with the display quality not much different from the original image.
- Faster processing speed.
