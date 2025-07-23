import 'package:mobile_asisten_keuangan/model/pengeluaran.dart';
import 'package:mobile_asisten_keuangan/data/pengeluaran_dao.dart';
import 'package:mobile_asisten_keuangan/model/saldo.dart';
import 'package:mobile_asisten_keuangan/data/saldo_dao.dart';

abstract class PengeluaranViewContract {
  void refresh();
  void showError(String message);
}

class PengeluaranPresenter {
  late PengeluaranDao pengeluaranDao;
  late SaldoDao saldoDao;
  final PengeluaranViewContract view;

  List<PengeluaranModel> pengeluaranList = [];
  SaldoModel? _saldoHarian, _saldoTotal;

  PengeluaranPresenter({
    required this.view,
  });

  int get saldoTerkini => _saldoHarian?.saldo ?? 0;

  int get totalPengeluaran =>
      pengeluaranList.fold(0, (sum, item) => sum + item.pengeluaran);

  Future<void> init() async {
    pengeluaranDao = PengeluaranDao();
    saldoDao = SaldoDao();

    _saldoHarian = await saldoDao.getSaldoByNama("harian");
    _saldoTotal = await saldoDao.getSaldoByNama("total");
    
    pengeluaranList = await pengeluaranDao.getAll();
    view.refresh();
  }

  Future<void> tambahPengeluaran(String deskripsi, int jumlah) async {
    if (_saldoHarian!.saldo < jumlah) {
      view.showError("Saldo tidak mencukupi");
      return;
    }

    final data = PengeluaranModel(
      deskripsi: deskripsi,
      pengeluaran: jumlah,
      saldoSebelumnya: _saldoHarian!.saldo,
    );

    await pengeluaranDao.insert(data);
    pengeluaranList.insert(0, data);

    _saldoHarian!.kurangi(jumlah);
    await saldoDao.updateSaldo(_saldoHarian!);

    _saldoTotal!.kurangi(jumlah);
    await saldoDao.updateSaldo(_saldoTotal!);

    view.refresh();
  }

  Future<void> hapusPengeluaran(int index) async {
    if (_saldoHarian == null || _saldoTotal == null || index < 0 || index >= pengeluaranList.length) return;

    final data = pengeluaranList.removeAt(index);
    await pengeluaranDao.deleteById(data.id!);

    _saldoHarian!.tambah(data.pengeluaran);
    await saldoDao.updateSaldo(_saldoHarian!);

    _saldoTotal!.tambah(data.pengeluaran);
    await saldoDao.updateSaldo(_saldoTotal!);

    // hitung ulang saldo_sebelumnya untuk data yang tersisa
    int saldoTemp = _saldoHarian!.saldo;
    for (var item in pengeluaranList) {
      item.saldoSebelumnya = saldoTemp;
      saldoTemp -= item.pengeluaran;
    }

    view.refresh();
  }
}

