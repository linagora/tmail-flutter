
import 'package:core/utils/mail/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Domain.of(args) should not be case sensitive', () {
    expect(Domain.of('Domain'), equals(Domain.of('domain')));
  });

  group('Domain.of(arg) should throw an AssertionError with a list of invalid domains', () {
    final listDomainInValid = [
      'domain\$bad.com',
      '',
      'aab..ddd',
      'aab.cc.1com',
      'abc.abcdefghijabcdefghijabcdefghijabcdefghijabcdefghijabcdefghijabcd.com',
      'domain\$bad.com',
      'domain/bad.com',
      'domain\\bad.com',
      'domain@bad.com',
      'domain@bad.com',
      'domain%bad.com',
      '#domain.com',
      'bad-.com',
      'bad_.com',
      '-bad.com',
      'bad_.com',
      '[domain.tld',
      'domain.tld]',
      'a[aaa]a',
      '[aaa]a',
      'a[aaa]',
      '[]'
    ];
    for (var arg in listDomainInValid) {
      test(arg, () {
        expect(() => Domain.of(arg), throwsA(const TypeMatcher<AssertionError>()));
      });
    }
  });

  group('Domain.of(arg) should not throw any exceptions with the list of valid domains', () {
    final listDomainValid = [
      '127.0.0.1',
      'domain.tld',
      'do-main.tld',
      'do_main.tld',
      'ab.dc.de.fr',
      '123.456.789.a23',
      'acv.abcdefghijabcdefghijabcdefghijabcdefghijabcdefghijabcdefghijabc.fr',
      'ab--cv.fr',
      'ab__cd.fr',
      'domain',
      '[domain]',
      '127.0.0.1'
    ];
    for (var arg in listDomainValid) {
      test(arg, () {
        expect(() => Domain.of(arg), returnsNormally);
      });
    }
  });

  test('Domain.of(args) should remove brackets', () {
    expect(Domain.of('[domain]'), equals(Domain.of('domain')));
  });

  test('Domain.of(args) should throw AssertionError when args is null', () {
    expect(() => Domain.of(null), throwsA(const TypeMatcher<AssertionError>()));
  });

  test('Domain.of(args) should allow 253 long domain', () {
    expect(Domain.of('${'aaaaaaaaa.' * 25}aaa').domainName.length, 253);
  });

  test('Domain.of(args) should throw AssertionError when too long', () {
    expect(() => Domain.of('a' * 254), throwsA(const TypeMatcher<AssertionError>()));
  });
}
