import 'package:keuangan_pribadi/data/database.dart';
import 'package:keuangan_pribadi/data/saldo_dao.dart';
import 'package:keuangan_pribadi/model/saldo.dart';
import 'package:keuangan_pribadi/data/pengeluaran_dao.dart';
import 'package:keuangan_pribadi/model/pengeluaran.dart';

abstract class SaldoViewContract {
  void updateSaldo(int saldo);
  Future<int?> mintaInput(bool tambah); // true untuk tambah, false untuk kurangi
  void showError(String pesan);

  String getNamaSaldo();
}

class SaldoPresenter {
  late SaldoDao saldoDao;
  SaldoModel? _model;
  final SaldoViewContract _view;

  late PengeluaranDao pengeluaranDao;
  late String nama;

  late DateTime curDatetime;

  SaldoPresenter(this._view);

  Future<void> init() async {
    nama = _view.getNamaSaldo();

    // Coba ambil dari DB
    saldoDao = SaldoDao();
    _model = await saldoDao.getSaldoByNama(nama);

    // Kalau belum ada, buat baru
    if (_model == null) {
      _model = SaldoModel(nama: nama, saldo: 0);
      _model!.id = await saldoDao.insertSaldo(_model!);
    }

    if(nama == "harian") {
      pengeluaranDao = PengeluaranDao();
      curDatetime = DateTime.now();
    }
    _view.updateSaldo(_model!.saldo);
  }

  Future<void> tambahSaldo() async {
    final input = await _view.mintaInput(true);
    if (input == null || input <= 0) {
      _view.showError("Input tidak valid");
      return;
    }
    _model!.tambah(input);
    await saldoDao.updateSaldo(_model!);

    _view.updateSaldo(_model!.saldo);

    if(nama == "harian") pengeluaranDao.tambahSaldoSemua(curDatetime, input.toDouble());
  }

  Future<void> kurangiSaldo() async {
    final input = await _view.mintaInput(false);
    if (input == null || input <= 0) {
      _view.showError("Input tidak valid");
      return;
    }
    if (_model!.saldo < input) {
      _view.showError("Saldo tidak mencukupi");
      return;
    }
    _model!.kurangi(input);
    await saldoDao.updateSaldo(_model!);
    _view.updateSaldo(_model!.saldo);

    if(nama == "harian") pengeluaranDao.kurangiSaldoSemua(curDatetime, input.toDouble());
  }
}

