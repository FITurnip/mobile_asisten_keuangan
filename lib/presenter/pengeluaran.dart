import 'package:keuangan_pribadi/model/pengeluaran.dart';
import 'package:keuangan_pribadi/data/pengeluaran_dao.dart';
import 'package:keuangan_pribadi/model/saldo.dart';
import 'package:keuangan_pribadi/data/saldo_dao.dart';

abstract class PengeluaranViewContract {
  void refresh();
  void showError(String message);
}

class PengeluaranPresenter {
  late PengeluaranDao pengeluaranDao;
  late SaldoDao saldoDao;
  final PengeluaranViewContract view;

  List<PengeluaranModel> pengeluaranList = [];
  SaldoModel? _saldoModel;

  PengeluaranPresenter({
    required this.view,
  });

  int get saldoTerkini => _saldoModel?.saldo ?? 0;

  int get totalPengeluaran =>
      pengeluaranList.fold(0, (sum, item) => sum + item.pengeluaran);

  Future<void> init(String namaSaldo) async {
    pengeluaranDao = PengeluaranDao();
    saldoDao = SaldoDao();

    _saldoModel = await saldoDao.getSaldoByNama(namaSaldo);
    if (_saldoModel == null) {
      _saldoModel = SaldoModel(nama: namaSaldo, saldo: 0);
      _saldoModel!.id = await saldoDao.insertSaldo(_saldoModel!);
    }

    pengeluaranList = await pengeluaranDao.getAll();
    view.refresh();
  }

  Future<void> tambahPengeluaran(String deskripsi, int jumlah) async {
    if (_saldoModel == null) return;

    if (_saldoModel!.saldo < jumlah) {
      view.showError("Saldo tidak mencukupi");
      return;
    }

    final data = PengeluaranModel(
      deskripsi: deskripsi,
      pengeluaran: jumlah,
      saldoSebelumnya: _saldoModel!.saldo,
    );

    await pengeluaranDao.insert(data);
    pengeluaranList.insert(0, data);

    _saldoModel!.kurangi(jumlah);
    await saldoDao.updateSaldo(_saldoModel!);

    view.refresh();
  }

  Future<void> hapusPengeluaran(int index) async {
    if (_saldoModel == null || index < 0 || index >= pengeluaranList.length) return;

    final data = pengeluaranList.removeAt(index);
    await pengeluaranDao.deleteById(data.id!);

    _saldoModel!.tambah(data.pengeluaran);
    await saldoDao.updateSaldo(_saldoModel!);

    // hitung ulang saldo_sebelumnya untuk data yang tersisa
    int saldoTemp = _saldoModel!.saldo;
    for (var item in pengeluaranList) {
      item.saldoSebelumnya = saldoTemp;
      saldoTemp -= item.pengeluaran;
    }

    view.refresh();
  }
}

