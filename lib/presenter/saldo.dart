import 'package:mobile_asisten_keuangan/model/saldo.dart';

abstract class SaldoViewContract {
  void updateSaldo(int saldo);
  Future<int?> mintaInput(bool tambah); // true untuk tambah, false untuk kurangi
  void showError(String pesan);
}

class SaldoPresenter {
  final SaldoModel _model = SaldoModel();
  final SaldoViewContract _view;

  SaldoPresenter(this._view) {
    _view.updateSaldo(_model.saldo);
  }

  Future<void> tambahSaldo() async {
    final input = await _view.mintaInput(true);
    if (input == null || input <= 0) {
      _view.showError("Input tidak valid");
      return;
    }
    _model.tambah(input);
    _view.updateSaldo(_model.saldo);
  }

  Future<void> kurangiSaldo() async {
    final input = await _view.mintaInput(false);
    if (input == null || input <= 0) {
      _view.showError("Input tidak valid");
      return;
    }
    if (_model.saldo < input) {
      _view.showError("Saldo tidak mencukupi");
      return;
    }
    _model.kurangi(input);
    _view.updateSaldo(_model.saldo);
  }
}

