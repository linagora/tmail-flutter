
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:model/extensions/presentation_email_extension.dart';

import '../../fixtures/email_fixtures.dart';

void main() {

  group('avatar_email test', () {
    test('presentationEmail.avatarColors should return list color when `From` email is NotNull and NotEmpty', () {
      final listColors = EmailFixtures.presentationEmailWithFromIsNotNull.avatarColors;
      
      expect(listColors.length, equals(2));
    });

    test('presentationEmail.avatarColors should return list default color when `From` email is Null', () {
      final listColors = EmailFixtures.presentationEmailWithFromIsNull.avatarColors;

      expect(listColors, containsAll(AppColor.mapGradientColor.first));
      expect(listColors.length, equals(2));
    });

    test('presentationEmail.avatarColors should return list default color when `From` email is Empty', () {
      final listColors = EmailFixtures.presentationEmailWithFromIsEmpty.avatarColors;

      expect(listColors, containsAll(AppColor.mapGradientColor.first));
      expect(listColors.length, equals(2));
    });
  });
}