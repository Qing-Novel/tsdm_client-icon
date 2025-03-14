part of 'schema.dart';

/// Table for user cookies.
@DataClassName('CookieEntity')
class Cookie extends Table {
  /// User's name.
  TextColumn get username => text()();

  /// User id.
  IntColumn get uid => integer()();

  /// Cookie value.
  TextColumn get cookie => text()();

  /// Last checkin time.
  DateTimeColumn get lastCheckin => dateTime().nullable()();

  /// Timestamp of last notice fetch from server.
  ///
  /// This timestamp is in stored in milliseconds level while most of other
  /// timestamps are in seconds level. Because only this field is always used
  /// by client, not server.
  DateTimeColumn get lastFetchNotice => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {uid};
}
