import 'package:sqflite/sqflite.dart';
import '../model/saldo.dart';
import 'package:mobile_asisten_keuangan/data/database.dart';

class SaldoDao {
  final Database db;

  SaldoDao(this.db);

  Future<int> insertSaldo(SaldoModel saldo) async {
    return await db.insert('saldo', saldo.toMap());
  }

  Future<List<SaldoModel>> getAllSaldo() async {
    final maps = await db.query('saldo');
    return maps.map((e) => SaldoModel.fromMap(e)).toList();
  }

  Future<SaldoModel?> getSaldoById(int id) async {
    final result = await db.query('saldo', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return SaldoModel.fromMap(result.first);
    }
    return null;
  }

  Future<SaldoModel?> getSaldoByNama(String nama) async {
    final db = await AppDatabase.getDatabase();
    final result = await db.query(
      'saldo',
      where: 'nama = ?',
      whereArgs: [nama],
    );

    if (result.isNotEmpty) {
      return SaldoModel.fromMap(result.first);
    }

    return null;
  }

  Future<void> updateSaldo(SaldoModel saldo) async {
    await db.update('saldo', saldo.toMap(), where: 'id = ?', whereArgs: [saldo.id]);
  }

  Future<void> deleteSaldo(int id) async {
    await db.delete('saldo', where: 'id = ?', whereArgs: [id]);
  }
}

