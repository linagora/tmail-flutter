import 'package:core/domain/exceptions/address_exception.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/mail/domain.dart';
import 'package:equatable/equatable.dart';

class MailAddress with EquatableMixin {
  static final List<String> SPECIAL = [
    '<',
    '>',
    '(',
    ')',
    '[',
    ']',
    '\\',
    '.',
    ',',
    ';',
    ':',
    '@',
    '\"'
  ];

  final String localPart;
  final Domain domain;

  MailAddress({required this.localPart, required this.domain});

  factory MailAddress.validateAddress(String address) {
    log('MailAddress::validate: Address = $address');
    String localPart;
    Domain domain;

    address = address.trim();
    if (address.isEmpty) {
      throw AddressException('Addresses should not be empty');
    }
    int pos = 0;

    // Test if mail address has source routing information (RFC-821) and get rid of it!!
    // must be called first!! (or at least prior to updating pos)
    _stripSourceRoute(address, pos);

    StringBuffer localPartSB = StringBuffer();
    StringBuffer domainSB = StringBuffer();
    // Begin parsing
    // <mailbox> ::= <local-part> "@" <domain>

    try {
      // parse local-part
      // <local-part> ::= <dot-string> | <quoted-string>
      if (address[pos] == '\"') {
        pos = _parseQuotedLocalPartOrThrowException(localPartSB, address, pos);
      } else {
        pos = parseUnquotedLocalPartOrThrowException(localPartSB, address, pos);
      }
      // find @
      if (pos >= address.length || address[pos] != '@') {
        throw AddressException('Did not find @ between local-part and domain at position ${pos + 1} in "$address"');
      }
      pos++;
      // parse domain
      // <domain> ::=  <element> | <element> "." <domain>
      // <element> ::= <name> | "#" <number> | "[" <dotnum> "]"
      while (true) {
        if (pos >= address.length) {
          break;
        }
        var postChar = address[pos];
        if (postChar == '#') {
          pos = _parseNumber(domainSB, address, pos);
        } else if (postChar == '[') {
          pos = _parseDomainLiteral(domainSB, address, pos);
        } else {
          pos = _parseDomain(domainSB, address, pos);
        }
        if (pos >= address.length) {
          break;
        }
        postChar = address[pos];
        if (postChar == '.') {
          var lastChar = address[pos - 1];
          if (lastChar == '@' || lastChar == '.') {
            throw AddressException('Subdomain expected before "." or duplicate "." in "address"');
          }
          domainSB.write('.');
          pos++;
          continue;
        }
        break;
      }
      if (domainSB.length == 0) {
        throw AddressException('No domain found at position ${pos + 1} in "$address"');
      }
    } catch (e) {
      logError('MailAddress::validate: Exception = $e');
      if (e is AddressException) {
        rethrow;
      } else {
        throw AddressException('Out of data at position ${pos + 1} in "$address"');
      }
    }

    localPart = localPartSB.toString();

    if (localPart.startsWith('.') ||
        localPart.endsWith('.') ||
        _haveDoubleDot(localPart)) {
      throw AddressException('Addresses cannot start end with "." or contain two consecutive dots');
    }

    domain = _createDomain(domainSB.toString());

    return MailAddress(localPart: localPart, domain: domain);
  }

  factory MailAddress.validateLocalPartAndDomain({required String localPart, required dynamic domain}) {
    if (domain is Domain) {
      return MailAddress.validateAddress('$localPart@${domain.name()}');
    } else {
      return MailAddress.validateAddress('$localPart@$domain');
    }
  }

  String asString() {
    return '$localPart@${domain.asString()}';
  }

  String asPrettyString() {
    return '<${asString()}>';
  }

  Domain getDomain() {
    return domain;
  }

  String getLocalPart() {
    return localPart;
  }

  @override
  String toString() {
    return '$localPart@${domain.asString()}';
  }

  static bool _haveDoubleDot(String localPart) {
    return localPart.contains('..');
  }

  static Domain _createDomain(String domain) {
    try {
      return Domain.of(domain);
    } catch (e) {
      throw AddressException(e.toString());
    }
  }

  static int _parseNumber(StringBuffer dSB, String address, int pos) {
    // <number> ::= <d> | <d> <number>

    // we were passed the string with pos pointing the the # char.
    // take the first char (#), put it in the result buffer and increment pos
    var postChar = address[pos];
    dSB.write(postChar);
    pos++;
    // We keep the position from the class level pos field
    while (true) {
      if (pos >= address.length) {
        break;
      }
      // <d> ::= any one of the ten digits 0 through 9
      var d = address[pos];
      if (d == '.') {
        break;
      }
      if (d.compareTo('0') < 0 || d.compareTo('9') > 0) {
        throw AddressException('In domain, did not find a number in # address at position ${pos + 1} in "$address"');
      }
      dSB.write(d);
      pos++;
    }
    if (dSB.length < 2) {
      throw AddressException('In domain, did not find a number in # address at position ${pos + 1} in "$address"');
    }
    return pos;
  }

  static int _parseDomainLiteral(StringBuffer dSB, String address, int pos) {
    // we were passed the string with pos pointing the the [ char.
    // take the first char ([), put it in the result buffer and increment pos
    var posChar = address[pos];
    dSB.write(posChar);
    pos++;

    // <dotnum> ::= <snum> "." <snum> "." <snum> "." <snum>
    for (int octet = 0; octet < 4; octet++) {
      // <snum> ::= one, two, or three digits representing a decimal
      //                      integer value in the range 0 through 255
      // <d> ::= any one of the ten digits 0 through 9
      StringBuffer snumSB = StringBuffer();
      for (int digits = 0; digits < 3; digits++) {
        String currentChar = address[pos];
        if (currentChar == '.' || currentChar == ']') {
          break;
        } else if (currentChar.compareTo('0') < 0 ||
            currentChar.compareTo('9') > 0) {
          throw AddressException('Invalid number at position ${pos + 1} in "$address"');
        }
        snumSB.write(currentChar);
        pos++;
      }
      if (snumSB.length == 0) {
        throw AddressException('Number not found at position ${pos + 1} in "$address"');
      }
      try {
        int snum = int.parse(snumSB.toString());
        if (snum > 255) {
          throw AddressException('Invalid number at position ${pos + 1} in "$address"');
        }
      } catch (e) {
        throw AddressException('Invalid number at position ${pos + 1} in "$address"');
      }
      dSB.write(snumSB.toString());
      var posChar = address[pos];
      if (posChar == ']') {
        if (octet < 3) {
          throw AddressException('End of number reached too quickly at ${pos + 1} in "$address"');
        }
        break;
      }
      if (posChar == '.') {
        dSB.write('.');
        pos++;
      }
    }
    posChar = address[pos];
    if (posChar != ']') {
      throw AddressException('Did not find closing bracket \"]\" in domain at position ${pos + 1} in "$address"');
    }
    dSB.write(']');
    pos++;
    return pos;
  }

  static int _parseDomain(StringBuffer dSB, String address, int pos) {
    StringBuffer resultSB = StringBuffer();
    // <name> ::= <a> <ldh-str> <let-dig>
    // <ldh-str> ::= <let-dig-hyp> | <let-dig-hyp> <ldh-str>
    // <let-dig> ::= <a> | <d>
    // <let-dig-hyp> ::= <a> | <d> | "-"
    // <a> ::= any one of the 52 alphabetic characters A through Z
    //  in upper case and a through z in lower case
    // <d> ::= any one of the ten digits 0 through 9

    // basically, this is a series of letters, digits, and hyphens,
    // but it can't start with a digit or hypthen
    // and can't end with a hyphen

    // in practice though, we should relax this as domain names can start
    // with digits as well as letters.  So only check that doesn't start
    // or end with hyphen.
    while (true) {
      if (pos >= address.length) {
        break;
      }
      var ch = address[pos];
      if ((ch.compareTo('0') >= 0 && ch.compareTo('9') <= 0) ||
          (ch.compareTo('a') >= 0 && ch.compareTo('z') <= 0) ||
          (ch.compareTo('A') >= 0 && ch.compareTo('Z') <= 0) ||
          (ch == '-')) {
        resultSB.write(ch);
        pos++;
        continue;
      }
      if (ch == '.') {
        break;
      }
      throw AddressException('Invalid character at $pos in "$address"');
    }
    String result = resultSB.toString();
    if (result.startsWith('-') || result.endsWith('-')) {
      throw AddressException('Domain name cannot begin or end with a hyphen \"-\" at position ${pos + 1} in "$address"');
    }
    dSB.write(result);
    return pos;
  }

  static int _stripSourceRoute(String address, int pos) {
    var posChar = address[pos];
    if (pos < address.length && posChar == '@') {
      int i = address.indexOf(':');
      if (i != -1) {
        pos = i + 1;
      }
    }
    return pos;
  }

  static int _parseUnquotedLocalPart(StringBuffer lpSB, String address, int pos) {
    // <dot-string> ::= <string> | <string> "." <dot-string>
    bool lastCharDot = false;
    while (true) {
      if (pos >= address.length) {
        break;
      }
      // <string> ::= <char> | <char> <string>
      // <char> ::= <c> | "\" <x>
      var postChar = address[pos];
      if (postChar == '\\') {
        lpSB.write('\\');
        pos++;
        // <x> ::= any one of the 128 ASCII characters (no exceptions)
        var x = address[pos];
        if (x.codeUnitAt(0) < 0 || x.codeUnitAt(0) > 127) {
          throw AddressException('Invalid \\ syntax character at position ${pos + 1}  in "$address"');
        }
        lpSB.write(x);
        pos++;
        lastCharDot = false;
      } else if (postChar == '.') {
        if (pos == 0) {
          throw AddressException('Local part must not start with a "."');
        }
        lpSB.write('.');
        pos++;
        lastCharDot = true;
      } else if (postChar == '@') {
        // End of local-part
        break;
      } else {
        // <c> ::= any one of the 128 ASCII characters, but not any
        //    <special> or <SP>
        // <special> ::= "<" | ">" | "(" | ")" | "[" | "]" | "\" | "."
        //    | "," | ";" | ":" | "@"  """ | the control
        //    characters (ASCII codes 0 through 31 inclusive and
        //    127)
        // <SP> ::= the space character (ASCII code 32)
        var c = address[pos];
        if (c.codeUnitAt(0) <= 31 || c.codeUnitAt(0) >= 127 || c == ' ') {
          throw AddressException('Invalid character in local-part (user account) at position ${pos + 1}  in "$address"');
        }
        int i = 0;
        while (i < SPECIAL.length) {
          if (c == SPECIAL[i]) {
            throw AddressException('Invalid character in local-part (user account) at position ${pos + 1}  in "$address"');
          }
          i++;
        }
        lpSB.write(c);
        pos++;
        lastCharDot = false;
      }
    }
    if (lastCharDot) {
      throw AddressException('local-part (user account) ended with a \".\", which is invalid in address "$address"');
    }
    return pos;
  }

  static int parseUnquotedLocalPartOrThrowException(StringBuffer localPartSB, String address, int pos) {
    pos = _parseUnquotedLocalPart(localPartSB, address, pos);
    if (localPartSB.length == 0) {
      throw AddressException('No local-part (user account) found at position ${pos + 1}  in "$address"');
    }
    return pos;
  }

  static int _parseQuotedLocalPartOrThrowException(StringBuffer localPartSB, String address, int pos) {
    pos = _parseQuotedLocalPart(localPartSB, address, pos);
    if (localPartSB.length == 2) {
      throw AddressException('No quoted local-part (user account) found at position ${pos + 2}  in "$address"');
    }
    return pos;
  }

  static int _parseQuotedLocalPart(StringBuffer lpSB, String address, int pos) {
    lpSB.write('\"');
    pos++;
    // <quoted-string> ::=  """ <qtext> """
    // <qtext> ::=  "\" <x> | "\" <x> <qtext> | <q> | <q> <qtext>
    while (true) {
      if (pos >= address.length) {
        break;
      }
      var postChar = address[pos];
      if (postChar == '\"') {
        lpSB.write('\"');
        // end of quoted string... move forward
        pos++;
        break;
      }
      if (postChar == '\\') {
        lpSB.write('\\');
        pos++;
        // <x> ::= any one of the 128 ASCII characters (no exceptions)
        var x = address[pos];
        if (x.codeUnitAt(0) < 0 || x.codeUnitAt(0) > 127) {
          throw AddressException('Invalid \\ syntax character at position ${pos + 1} in "$address"');
        }
        lpSB.write(x);
        pos++;
      } else {
        // <q> ::= any one of the 128 ASCII characters except <CR>,
        // <LF>, quote ("), or backslash (\)
        var q = address[pos];
        if (q.codeUnitAt(0) <= 0 ||
            q == '\n' ||
            q == '\r' ||
            q == '\"' ||
            q == '\\') {
          throw AddressException('Unquoted local-part (user account) must be one of the 128 ASCII characters exception <CR>, <LF>, quote (\"), or backslash (\\) at position ${pos + 1} in "$address"');
        }
        lpSB.write(q);
        pos++;
      }
    }
    return pos;
  }

  @override
  List<Object?> get props => [localPart, domain];
}
