class CustomerTable {
  static const String tableName = 'customers';

  // Column names
  static const String id = 'id';
  static const String name = 'name';
  static const String phone = 'phone';
  static const String address = 'address';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';

  // Create table SQL
  static const String createTable =
      '''
    CREATE TABLE $tableName (
      $id INTEGER PRIMARY KEY AUTOINCREMENT,
      $name TEXT NOT NULL,
      $phone TEXT,
      $address TEXT,
      $createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
      $updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP
    )
  ''';

  // Create indexes SQL
  static const String createIndexes =
      '''
    CREATE INDEX idx_${tableName}_name ON $tableName($name);
    CREATE INDEX idx_${tableName}_phone ON $tableName($phone);
  ''';

  // Drop table SQL
  static const String dropTable = 'DROP TABLE IF EXISTS $tableName';
}
