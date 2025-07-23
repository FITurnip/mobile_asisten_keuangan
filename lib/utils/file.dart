import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<({bool success, String? error})> exportToExcelFlexible({
  required List<Map<String, dynamic>> data,
  String sheetName = 'Sheet1',
  String fileName = 'data_export.xlsx',
}) async {
  try {
    if (data.isEmpty) {
      return (success: false, error: "Data kosong, tidak bisa ekspor.");
    }

    final excel = Excel.createExcel();
    final sheet = excel[sheetName];

    // Header
    final headers = data.first.keys.toList();
    sheet.appendRow(headers);

    // Baris
    for (var row in data) {
      final rowValues = headers.map((key) => row[key]?.toString() ?? '').toList();
      sheet.appendRow(rowValues);
    }

    // Izin
    final status = await Permission.manageExternalStorage.request();
    if (status.isDenied) {
      return (success: false, error: "Izin penyimpanan ditolak.");
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }

    // Simpan
    final directory = await getExternalStorageDirectory();
    final filePath = "${directory!.path}/$fileName";
    final file = File(filePath);
    final fileBytes = excel.encode();
    await file.writeAsBytes(fileBytes!);

    return (success: true, error: null);
  } catch (e) {
    return (success: false, error: e.toString());
  }
}
