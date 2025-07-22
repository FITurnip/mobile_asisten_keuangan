import 'package:mobile_asisten_keuangan/data/database.dart';
import 'package:mobile_asisten_keuangan/data/saldo_dao.dart';
import 'package:mobile_asisten_keuangan/model/saldo.dart';

abstract class SaldoViewContract {
  void updateSaldo(int saldo);
  Future<int?> mintaInput(bool tambah); // true untuk tambah, false untuk kurangi
  void showError(String pesan);

  String getNamaSaldo();
}

class SaldoPresenter {
  final SaldoDao dao;
  SaldoModel? _model;
  final SaldoViewContract _view;

  SaldoPresenter(this._view, this.dao);

  Future<void> init() async {
    final nama = _view.getNamaSaldo();

    // Coba ambil dari DB
    _model = await dao.getSaldoByNama(nama);

    // Kalau belum ada, buat baru
    if (_model == null) {
      _model = SaldoModel(nama: nama, saldo: 0);
      _model!.id = await dao.insertSaldo(_model!);
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
    await dao.updateSaldo(_model!);
    _view.updateSaldo(_model!.saldo);
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
    await dao.updateSaldo(_model!);
    _view.updateSaldo(_model!.saldo);
  }
}

