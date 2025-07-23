import 'package:sqflite/sqflite.dart';
import 'package:mobile_asisten_keuangan/data/database.dart';
import 'package:mobile_asisten_keuangan/model/pengeluaran.dart';

class PengeluaranDao {
  Future<int> insert(PengeluaranModel data) async {
    final db = await AppDatabase.getDatabase();
    return await db.insert('pengeluaran', data.toMap());
  }

  Future<dynamic> getAll({bool asMap = false}) async {
    final db = await AppDatabase.getDatabase();
    final result = await db.query(
      'pengeluaran',
      orderBy: 'timestamp DESC',
    );

    if(asMap) return result;
    else return result.map((map) => PengeluaranModel.fromMap(map)).toList();
  }

  Future<void> deleteById(int id) async {
    final db = await AppDatabase.getDatabase();
    await db.delete('pengeluaran', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAll() async {
    final db = await AppDatabase.getDatabase();
    await db.delete('pengeluaran');
  }

  Future<void> updateBatch(List<PengeluaranModel> dataList) async {
    final db = await AppDatabase.getDatabase();
    final batch = db.batch();

    for (var data in dataList) {
      batch.update(
        'pengeluaran',
        data.toMap(),
        where: 'id = ?',
        whereArgs: [data.id],
      );
    }

    await batch.commit(noResult: true);
  }

  String formatTanggal(DateTime dt) {
    return "${dt.year.toString().padLeft(4, '0')}"
          "-${dt.month.toString().padLeft(2, '0')}"
          "-${dt.day.toString().padLeft(2, '0')}";
  }

  Future<void> tambahSaldoSemua(DateTime tanggal, double jumlah) async {
    final keyTanggal = formatTanggal(tanggal);
    print(keyTanggal);

    final db = await AppDatabase.getDatabase();
    await db.rawUpdate(
      '''
      UPDATE pengeluaran
      SET saldo_sblm = saldo_sblm + ?
      WHERE timestamp LIKE ?
      ''',
      [jumlah, '$keyTanggal%'],
    );
  }

  Future<void> kurangiSaldoSemua(DateTime tanggal, double jumlah) async {
    final keyTanggal = formatTanggal(tanggal);
    
    final db = await AppDatabase.getDatabase();
    await db.rawUpdate(
      '''
      UPDATE pengeluaran
      SET saldo_sblm = saldo_sblm - ?
      WHERE timestamp LIKE ?
      ''',
      [jumlah, '$keyTanggal%'],
    );
  }

  Future<List<PengeluaranModel>> getMingguan() async {
    final db = await AppDatabase.getDatabase();

    final now = DateTime.now();
    final toDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1)); // Kemarin
    final fromDate = toDate.subtract(const Duration(days: 6)); // 7 hari total

    final String fromIso = fromDate.toIso8601String();
    final String toIso = DateTime(toDate.year, toDate.month, toDate.day, 23, 59, 59).toIso8601String();

    final result = await db.query(
      'pengeluaran',
      where: 'timestamp BETWEEN ? AND ?',
      whereArgs: [fromIso, toIso],
      orderBy: 'timestamp DESC',
    );

    return result.map((map) => PengeluaranModel.fromMap(map)).toList();
  }

  Future<List<PengeluaranModel>> getBulanan() async {
    final db = await AppDatabase.getDatabase();

    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month, 1);
    final fromDate = DateTime(thisMonth.year, thisMonth.month - 1, 1);
    final toDate = thisMonth.subtract(const Duration(seconds: 1)); // Akhir bulan lalu

    final String fromIso = fromDate.toIso8601String();
    final String toIso = DateTime(toDate.year, toDate.month, toDate.day, 23, 59, 59).toIso8601String();

    final result = await db.query(
      'pengeluaran',
      where: 'timestamp BETWEEN ? AND ?',
      whereArgs: [fromIso, toIso],
      orderBy: 'timestamp DESC',
    );

    return result.map((map) => PengeluaranModel.fromMap(map)).toList();
  }
}
