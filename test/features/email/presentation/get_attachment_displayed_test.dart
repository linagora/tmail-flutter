import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';

import 'get_attachment_displayed_test.mocks.dart';

@GenerateMocks([BuildContext, ResponsiveUtils])
void main() {
  late MockBuildContext mockContext;
  late MockResponsiveUtils mockResponsiveUtils;
  late List<Attachment> attachments;

  setUp(() {
    mockContext = MockBuildContext();
    mockResponsiveUtils = MockResponsiveUtils();
    attachments = [
      Attachment(name: 'file1.pdf'),
      Attachment(name: 'file2.jpg'),
      Attachment(name: 'file3.png'),
    ];
  });

  test('should return empty list when attachments are empty', () {
    final result = EmailUtils.getAttachmentDisplayed(
      context: mockContext,
      responsiveUtils: mockResponsiveUtils,
      maxWidth: 300.0,
      platformIsMobile: true,
      attachments: [],
    );
    expect(result, []);
  });

  test('should return all attachments when mobile and attachments < 3', () {
    when(mockResponsiveUtils.isMobile(mockContext)).thenReturn(true);

    final result = EmailUtils.getAttachmentDisplayed(
      context: mockContext,
      responsiveUtils: mockResponsiveUtils,
      maxWidth: 300.0,
      platformIsMobile: true,
      attachments: attachments.sublist(0, 2),
    );
    expect(result.length, 2);
    expect(result, attachments.sublist(0, 2));
  });

  test('should return first 3 attachments when mobile and attachments >= 4', () {
    when(mockResponsiveUtils.isMobile(mockContext)).thenReturn(true);

    final result = EmailUtils.getAttachmentDisplayed(
      context: mockContext,
      responsiveUtils: mockResponsiveUtils,
      maxWidth: 300.0,
      platformIsMobile: true,
      attachments: attachments,
    );
    expect(result.length, 3);
    expect(result, attachments.sublist(0, 3));
  });

  test('should return sublist based on maxWidthTabletLarge when responsiveIsTabletLarge is true', () {
    when(mockResponsiveUtils.isMobile(mockContext)).thenReturn(false);
    when(mockResponsiveUtils.isTablet(mockContext)).thenReturn(false);
    when(mockResponsiveUtils.isTabletLarge(mockContext)).thenReturn(true);
    final result = EmailUtils.getAttachmentDisplayed(
      context: mockContext,
      responsiveUtils: mockResponsiveUtils,
      maxWidth: 360.0,
      platformIsMobile: false,
      attachments: attachments,
    );
    expect(result.length, 1);
    expect(result, attachments.sublist(0, 1));
  });

  test('should return sublist based on maxWidthTablet when responsiveIsTablet is true', () {
    when(mockResponsiveUtils.isMobile(mockContext)).thenReturn(false);
    when(mockResponsiveUtils.isTablet(mockContext)).thenReturn(true);
    when(mockResponsiveUtils.isTabletLarge(mockContext)).thenReturn(false);

    final result = EmailUtils.getAttachmentDisplayed(
      context: mockContext,
      responsiveUtils: mockResponsiveUtils,
      maxWidth: 320.0,
      platformIsMobile: false,
      attachments: attachments,
    );
    expect(result.length, 1);
    expect(result, attachments.sublist(0, 1));
  });

  test('should return sublist based on maxWidthMobile when not tablet or tabletLarge', () {
    when(mockResponsiveUtils.isMobile(mockContext)).thenReturn(false);
    when(mockResponsiveUtils.isTablet(mockContext)).thenReturn(false);
    when(mockResponsiveUtils.isTabletLarge(mockContext)).thenReturn(false);

    final result = EmailUtils.getAttachmentDisplayed(
      context: mockContext,
      responsiveUtils: mockResponsiveUtils,
      maxWidth: 280.0,
      platformIsMobile: false,
      attachments: attachments,
    );
    expect(result.length, 1);
    expect(result, attachments.sublist(0, 1));
  });

  test('should return sublist based on maxWidthMobile when platformIsMobile and responsiveIsMobile are true', () {
    when(mockResponsiveUtils.isTablet(mockContext)).thenReturn(false);
    when(mockResponsiveUtils.isTabletLarge(mockContext)).thenReturn(false);
    when(mockResponsiveUtils.isMobile(mockContext)).thenReturn(true);

    final result = EmailUtils.getAttachmentDisplayed(
      context: mockContext,
      responsiveUtils: mockResponsiveUtils,
      maxWidth: 280.0,
      platformIsMobile: true,
      attachments: attachments,
    );
    expect(result.length, 3);
    expect(result, attachments.sublist(0, 3));
  });

  test('should return sublist based on maxWidthTablet when platformIsMobile is true and responsiveIsMobile is false', () {
    when(mockResponsiveUtils.isMobile(mockContext)).thenReturn(false);
    when(mockResponsiveUtils.isTablet(mockContext)).thenReturn(false);
    when(mockResponsiveUtils.isTabletLarge(mockContext)).thenReturn(false);

    final result = EmailUtils.getAttachmentDisplayed(
      context: mockContext,
      responsiveUtils: mockResponsiveUtils,
      maxWidth: 320.0,
      platformIsMobile: true,
      attachments: attachments,
    );
    expect(result.length, 1);
    expect(result, attachments.sublist(0, 1));
  });

  test('should return first attachment when possibleDisplayedCount is 0', () {
    when(mockResponsiveUtils.isMobile(mockContext)).thenReturn(false);
    when(mockResponsiveUtils.isTablet(mockContext)).thenReturn(false);
    when(mockResponsiveUtils.isTabletLarge(mockContext)).thenReturn(false);

    final result = EmailUtils.getAttachmentDisplayed(
      context: mockContext,
      responsiveUtils: mockResponsiveUtils,
      maxWidth: 100.0,
      platformIsMobile: false,
      attachments: attachments,
    );
    expect(result.length, 1);
    expect(result.first, attachments.first);
  });
}