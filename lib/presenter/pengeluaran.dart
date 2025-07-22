import 'package:mobile_asisten_keuangan/model/pengeluaran.dart';
import 'package:mobile_asisten_keuangan/model/saldo.dart';

class PengeluaranPresenter {
  final List<PengeluaranModel> _pengeluaranList = [];
  final SaldoModel _saldoModel = SaldoModel(saldoAwal: 200000);

  List<PengeluaranModel> get pengeluaranList => _pengeluaranList;

  int get saldoTerkini => _saldoModel.saldo;

  int get totalPengeluaran =>
      _pengeluaranList.fold(0, (sum, item) => sum + item.pengeluaran);

  void tambahPengeluaran(String deskripsi, int jumlah) {
    final pengeluaran = PengeluaranModel(
      deskripsi: deskripsi,
      pengeluaran: jumlah,
      saldoSebelumnya: _saldoModel.saldo,
    );

    _pengeluaranList.insert(0, pengeluaran);
    _saldoModel.kurangi(jumlah);
  }

  void hapusPengeluaran(int index) {
    if (index < 0 || index >= _pengeluaranList.length) return;

    final jumlah = _pengeluaranList[index].pengeluaran;
    _pengeluaranList.removeAt(index);
    _saldoModel.tambah(jumlah);

    // Update saldo_sebelumnya agar tetap konsisten
    int saldoSementara = _saldoModel.saldo;
    for (var item in _pengeluaranList) {
      item.saldoSebelumnya = saldoSementara;
      saldoSementara -= item.pengeluaran;
    }
  }
}

