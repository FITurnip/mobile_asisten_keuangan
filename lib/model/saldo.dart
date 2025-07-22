class SaldoModel {
  int _saldo;

  SaldoModel({int saldoAwal = 0}) : _saldo = saldoAwal;
  int get saldo => _saldo;

  void tambah(int jumlah) {
    _saldo += jumlah;
  }

  void kurangi(int jumlah) {
    if (_saldo >= jumlah) {
      _saldo -= jumlah;
    }
  }
}

