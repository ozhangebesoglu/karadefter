class TransactionTable {
  static const String tableName = 'transactions';

  // Column names
  static const String id = 'id';
  static const String customerName = 'customer_name';
  static const String type = 'type';
  static const String amount = 'amount';
  static const String description = 'description';
  static const String date = 'date';
  static const String createdAt = 'created_at';

  // Create table SQL
  static const String createTable =
      '''
    CREATE TABLE $tableName (
      $id INTEGER PRIMARY KEY AUTOINCREMENT,
      $customerName TEXT NOT NULL,
      $type TEXT NOT NULL CHECK ($type IN ('credit', 'debit')),
      $amount REAL NOT NULL CHECK ($amount > 0),
      $description TEXT,
      $date DATETIME DEFAULT CURRENT_TIMESTAMP,
      $createdAt DATETIME DEFAULT CURRENT_TIMESTAMP
    )
  ''';

  // Create indexes SQL
  static const String createIndexes =
      '''
    CREATE INDEX idx_${tableName}_customer_name ON $tableName($customerName);
    CREATE INDEX idx_${tableName}_date ON $tableName($date);
    CREATE INDEX idx_${tableName}_type ON $tableName($type);
  ''';

  // Drop table SQL
  static const String dropTable = 'DROP TABLE IF EXISTS $tableName';
}
