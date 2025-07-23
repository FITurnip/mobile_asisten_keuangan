import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobile_asisten_keuangan/presenter/backup.dart';

class BackupView extends StatefulWidget {
  const BackupView({super.key});

  @override
  State<BackupView> createState() => _BackupViewState();
}

class _BackupViewState extends State<BackupView> implements BackupViewContract {
  late BackupPresenter _presenter;
  List<FileSystemEntity> _files = [];

  @override
  void initState() {
    super.initState();
    _presenter = BackupPresenter(this);
    _presenter.loadFiles();
  }

  @override
  void showFiles(List<FileSystemEntity> files) {
    setState(() {
      _files = files;
    });
  }

  @override
  void showAnnouncement(bool success, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'Berhasil diunduh' : 'Error: $error')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExportBackupButton(onPressed: () => _presenter.downloadAllData()),
        const SizedBox(height: 10),
        Flexible(
          child: _files.isEmpty
              ? const Center(child: Text('Tidak ada file ditemukan'))
              : ListView.builder(
                  itemCount: _files.length,
                  itemBuilder: (context, index) {
                    final file = _files[index] as File;
                    final name = file.path.split('/').last;

                    return ListTile(
                      leading: const Icon(Icons.description),
                      title: Text(name),
                      subtitle: Text(
                        'Modifikasi: ${file.lastModifiedSync()}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.open_in_new),
                        onPressed: () => _presenter.openFile(file.path),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class ExportBackupButton extends StatelessWidget {
  const ExportBackupButton({super.key, this.onPressed});
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.save_alt),
      label: const Text('Data Terbaru'),
      onPressed: onPressed,
    );
  }
}

