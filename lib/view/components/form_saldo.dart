import 'package:flutter/material.dart';
import 'package:mobile_asisten_keuangan/view/components/saldo.dart'; // Import SaldoComponent yang sudah kamu buat
import 'package:mobile_asisten_keuangan/presenter/saldo.dart';
import 'package:mobile_asisten_keuangan/data/database.dart';
import 'package:mobile_asisten_keuangan/data/saldo_dao.dart';

class FormSaldoComponent extends StatefulWidget {
  final String title;
  final String nama;
  const FormSaldoComponent({super.key, required this.title, required this.nama});

  @override
  State<FormSaldoComponent> createState() => _FormSaldoComponentState();
}

class _FormSaldoComponentState extends State<FormSaldoComponent>
    implements SaldoViewContract {
  late SaldoPresenter _presenter;
  int _saldo = 0;

  @override
  void initState() {
    super.initState();
    AppDatabase.getDatabase().then((db) {
      final dao = SaldoDao();
      _presenter = SaldoPresenter(this, dao);
      _presenter.init();
    });
  }

  @override
  void updateSaldo(int saldoBaru) {
    setState(() {
      _saldo = saldoBaru;
    });
  }

  @override
  Future<int?> mintaInput(bool tambah) async {
    final controller = TextEditingController();

    final jumlah = await showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(tambah ? 'Tambah Saldo' : 'Kurangi Saldo'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Masukkan jumlah'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              final nilai = int.tryParse(controller.text);
              Navigator.pop(context, nilai);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );

    return jumlah;
  }

  @override
  void showError(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(pesan)),
    );
  }

  @override
  String getNamaSaldo() => widget.nama;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SaldoComponent(
          judul: widget.title,
          saldo: _saldo,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _presenter.tambahSaldo(),
                icon: const Icon(Icons.add),
                label: const Text('Tambah'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _presenter.kurangiSaldo(),
                icon: const Icon(Icons.remove),
                label: const Text('Kurangi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
