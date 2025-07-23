import 'package:mobile_asisten_keuangan/model/pengeluaran.dart';
import 'package:mobile_asisten_keuangan/data/pengeluaran_dao.dart';

abstract class OverviewViewContract {
  void updateItemList(List<Map<String, dynamic>> newList);
  String selectedMode = "";
}

class OverviewPresenter {
  late PengeluaranDao pengeluaranDao;
  final OverviewViewContract view;

  List<PengeluaranModel> pengeluaranMingguanList = [];
  List<PengeluaranModel> pengeluaranBulananList = [];

  List<Map<String, dynamic>> resultMingguanList = [];
  List<Map<String, dynamic>> resultBulananList = [];

  bool isMingguanSetted = false, isBulananSetted = false;

  OverviewPresenter({
    required this.view,
  });

  Future<void> init() async {
    pengeluaranDao = PengeluaranDao();
    setData(view.selectedMode);
  }

  List<Map<String, dynamic>> kelompokkanPengeluaranModel(List<PengeluaranModel> data) {
    final Map<String, Map<String, dynamic>> hasil = {};

    for (var item in data) {
      final key = item.deskripsi;

      if (hasil.containsKey(key)) {
        hasil[key]!['jumlah'] += 1;
        hasil[key]!['totalHarga'] += item.pengeluaran;
      } else {
        hasil[key] = {
          'deskripsi': key,
          'jumlah': 1,
          'totalHarga': item.pengeluaran,
        };
      }
    }

    return hasil.values.toList();
 }

  Future<void> setData(rangeType) async {
    if(rangeType == 'minggu') {
      if(!isMingguanSetted) {
        pengeluaranMingguanList = await pengeluaranDao.getMingguan();
        resultMingguanList = kelompokkanPengeluaranModel(pengeluaranMingguanList);
        isMingguanSetted = true;
      }
      view.updateItemList(resultMingguanList);
    } else {
      if(!isBulananSetted) {
        pengeluaranBulananList = await pengeluaranDao.getBulanan();
        resultMingguanList = kelompokkanPengeluaranModel(pengeluaranMingguanList);
        isBulananSetted= true;
      }
      view.updateItemList(resultBulananList);
    }
  }
}
