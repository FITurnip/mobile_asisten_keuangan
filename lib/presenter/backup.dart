import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:mobile_asisten_keuangan/data/pengeluaran_dao.dart';
import 'package:mobile_asisten_keuangan/utils/file.dart';

abstract class BackupViewContract {
  void showFiles(List<FileSystemEntity> files);
  void showAnnouncement(bool success, String error);
}

class BackupPresenter {
  final BackupViewContract view;

  BackupPresenter(this.view);

  Future<void> loadFiles() async {
    try {
      final dir = await getExternalStorageDirectory();
      if (dir == null) {
        view.showFiles([]);
        return;
      }

      final files = dir
          .listSync()
          .where((f) => f is File && f.path.toLowerCase().endsWith('.xlsx'))
          .toList();

      files.sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
      view.showFiles(files);
    } catch (e) {
      view.showAnnouncement(false, e.toString());
    }
  }

  Future<void> openFile(String path) async {
    final result = await OpenFilex.open(path);
  }

  String formatTimestamp(DateTime dt) {
    return '${_2(dt.year % 100)}${_2(dt.month)}${_2(dt.day)}'
          '${_2(dt.hour)}${_2(dt.minute)}${_2(dt.second)}';
  }

  String _2(int n) => n.toString().padLeft(2, '0');
  
  void downloadAllData() async {
    final pengeluaranDao = PengeluaranDao();
    final pengeluaranList = await pengeluaranDao.getAll(asMap: true);
    final now = DateTime.now();
    final fileName = 'keuangan_pribadi_${formatTimestamp(now)}.xlsx';

    final result = await exportToExcelFlexible(data: pengeluaranList, fileName: fileName);
    view.showAnnouncement(result.success, result.error ?? '');
    loadFiles();
  }
}
