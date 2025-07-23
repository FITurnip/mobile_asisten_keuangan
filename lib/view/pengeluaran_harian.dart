import 'package:flutter/material.dart';
import 'package:mobile_asisten_keuangan/model/pengeluaran.dart';
import 'package:mobile_asisten_keuangan/presenter/pengeluaran.dart';
import 'package:mobile_asisten_keuangan/view/components/saldo.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mobile_asisten_keuangan/utils/format.dart';
import 'package:mobile_asisten_keuangan/data/pengeluaran_dao.dart';
import 'package:mobile_asisten_keuangan/data/saldo_dao.dart';

class PengeluaranHarianView extends StatefulWidget {
  const PengeluaranHarianView({super.key});

  @override
  State<PengeluaranHarianView> createState() => _PengeluaranHarianViewState();
}

class _PengeluaranHarianViewState extends State<PengeluaranHarianView>
    implements PengeluaranViewContract {
  final _formKey = GlobalKey<FormState>();
  late PengeluaranPresenter presenter;

  @override
  void initState() {
    super.initState();
    presenter = PengeluaranPresenter(
      pengeluaranDao: PengeluaranDao(),
      saldoDao: SaldoDao(),
      view: this,
    );
    presenter.init("harian"); // Nama saldo bisa disesuaikan
  }

  @override
  void refresh() => setState(() {});

  @override
  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void showPengeluaranModal(BuildContext context, int saldoSaatIni) {
    final deskripsiController = TextEditingController();
    final jumlahController = TextEditingController(text: "10000");
    final saldoAkhirController =
        TextEditingController(text: (saldoSaatIni - 10000).toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: StatefulBuilder(
            builder: (context, setModalState) {
              void updateSaldoAkhir(String value) {
                final jumlah = int.tryParse(value) ?? 0;
                setModalState(() {
                  saldoAkhirController.text =
                      (saldoSaatIni - jumlah).toString();
                });
              }

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Tambah Pengeluaran',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: deskripsiController,
                        decoration: const InputDecoration(
                          labelText: 'Deskripsi',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Saldo Saat Ini',
                          border: OutlineInputBorder(),
                        ),
                        controller: TextEditingController(
                          text: saldoSaatIni.toString(),
                        ),
                        enabled: false,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: jumlahController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Jumlah Pengeluaran',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: updateSaldoAkhir,
                        validator: (value) {
                          final angka = int.tryParse(value ?? '');
                          if (angka == null || angka <= 0) {
                            return 'Jumlah harus > 0';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: saldoAkhirController,
                        enabled: false,
                        decoration: const InputDecoration(
                          labelText: 'Saldo Akhir',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              await presenter.tambahPengeluaran(
                                deskripsiController.text.trim(),
                                int.parse(jumlahController.text),
                              );
                              Navigator.pop(context);
                            }
                          },
                          child: const Text('Simpan'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void hapusPengeluaran(int index) async {
    await presenter.hapusPengeluaran(index);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            SaldoComponent(
              judul: 'Saldo Hari Ini',
              saldo: presenter.saldoTerkini,
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Pengeluaran Hari Ini:'),
                  Text(formatRupiah(presenter.totalPengeluaran)),
                ],
              ),
            ),
            Flexible(
              child: presenter.pengeluaranList.length > 0 ? ListView.separated(
                itemCount: presenter.pengeluaranList.length,
                separatorBuilder: (context, index) => const Divider(height: 0.5),
                itemBuilder: (context, index) {
                  final item = presenter.pengeluaranList[index];
                  return Slidable(
                    key: ValueKey(item.deskripsi + index.toString()),
                    startActionPane: buildDeletePane(index),
                    endActionPane: buildDeletePane(index),
                    child: ListTile(
                      title: Text(item.deskripsi),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Saldo: ${formatRupiah(item.saldoSebelumnya)}',
                              style: const TextStyle(color: Colors.green)),
                          Text('-${formatRupiah(item.pengeluaran)}',
                              style: const TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  );
                },
              ) : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 24),
                  Icon(Icons.inbox, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada pengeluaran',
                  )
                ]
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () =>
                showPengeluaranModal(context, presenter.saldoTerkini),
            child: const Icon(Icons.upload),
          ),
        ),
      ],
    );
  }

  ActionPane buildDeletePane(int index) {
    return ActionPane(
      motion: const ScrollMotion(),
      dismissible: DismissiblePane(onDismissed: () => hapusPengeluaran(index)),
      children: [
        SlidableAction(
          onPressed: (_) => hapusPengeluaran(index),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          icon: Icons.delete,
          label: 'Hapus',
        ),
      ],
    );
  }
}

