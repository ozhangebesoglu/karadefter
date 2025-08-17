class TransactionTable {
  static const String tableName = 'transactions';

  // Column names
  static const String id = 'id';
  static const String customerId = 'customer_id';
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
      $customerId INTEGER NOT NULL,
      $type TEXT NOT NULL CHECK ($type IN ('credit', 'debit')),
      $amount REAL NOT NULL CHECK ($amount > 0),
      $description TEXT,
      $date DATETIME DEFAULT CURRENT_TIMESTAMP,
      $createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY ($customerId) REFERENCES customers(id) ON DELETE CASCADE
    )
  ''';

  // Create indexes SQL
  static const String createIndexes =
      '''
    CREATE INDEX idx_${tableName}_customer_id ON $tableName($customerId);
    CREATE INDEX idx_${tableName}_date ON $tableName($date);
    CREATE INDEX idx_${tableName}_type ON $tableName($type);
  ''';

  // Drop table SQL
  static const String dropTable = 'DROP TABLE IF EXISTS $tableName';
}
