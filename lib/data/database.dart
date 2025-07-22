import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static Database? _database;

  // Getter database
  static Future<Database> getDatabase() async {
    if (_database != null) return _database!;

    // Lokasi file database
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_asisten_keuangan.db');

    // Buka atau buat database
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );

    return _database!;
  }

  // Buat struktur tabel
  static Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE saldo (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        saldo INTEGER NOT NULL
      )
    ''');

    // Contoh data awal (opsional)
    await db.insert('saldo', {'nama': 'total', 'saldo': 10000000});
    await db.insert('saldo', {'nama': 'harian', 'saldo': 100000});
  }

  // Optional: method untuk reset database
  static Future<void> resetDatabase() async {
    final db = await getDatabase();
    await db.delete('saldo');
  }
}

