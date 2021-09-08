
class EmailAddressTable {
  static const String TABLE_NAME = 'EmailAddress';

  static const String EMAIL = 'email';
  static const String NAME = 'name';

  static const String CREATE = '''CREATE TABLE IF NOT EXISTS $TABLE_NAME (
    $EMAIL TEXT PRIMARY KEY,
    $NAME TEXT
  )''';
}