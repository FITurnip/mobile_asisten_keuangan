import 'package:flutter/material.dart';
import 'package:keuangan_pribadi/utils/format.dart';
import 'package:keuangan_pribadi/presenter/overview.dart';

class OverviewView extends StatefulWidget {
  const OverviewView({super.key});

  @override
  State<OverviewView> createState() => _OverviewViewState();
}

class _OverviewViewState extends State<OverviewView> implements OverviewViewContract {
  List<Map<String, dynamic>> items = [];

  String selectedMode = 'minggu';

  void _changeMode(String mode) {
    setState(() {
      selectedMode = mode;
    });
  }

  @override
  void updateItemList(List<Map<String, dynamic>> newList) => setState(() {
      items = newList;
    });

  late OverviewPresenter presenter;

  @override
  void initState() {
    super.initState();
    presenter = OverviewPresenter(
      view: this,
    );
    presenter.init();
  }

  @override
  void showAnnouncement(bool Success, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(Success ? 'Berhasil diunduh' : 'Error: $error')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children : [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ChoiceChip(
              label: const Text("Seminggu Lalu"),
              showCheckmark: false,
              selected: selectedMode == 'minggu',
              onSelected: (_) => _changeMode('minggu'),
            ),
            const SizedBox(width: 10),
            ChoiceChip(
              label: const Text("Bulan lalu"),
              showCheckmark: false,
              selected: selectedMode == 'bulan',
              onSelected: (_) => _changeMode('bulan'),
            ),
            const Spacer(),

            IconButton(
              icon: const Icon(Icons.download_rounded),
              onPressed: () => presenter.downloadAllData()
            )
          ]
        ),
        SizedBox(height: 16),
        RecordListView(items: items)
      ]
    );
  }
  
}

class RecordListView extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const RecordListView({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: ListView.separated(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return RecordItemTile(
            deskripsi: item["deskripsi"],
            jumlah: item["jumlah"],
            totalHarga: item["totalHarga"],
          );
        },
        separatorBuilder: (context, index) => const Divider(
          thickness: 1,
          height: 0,
          indent: 16,
          endIndent: 16,
          color: Colors.grey,
        ),
      ),
    );
  }
}

class RecordItemTile extends StatelessWidget {
  final String deskripsi;
  final int jumlah;
  final int totalHarga;

  const RecordItemTile({
    super.key,
    required this.deskripsi,
    required this.jumlah,
    required this.totalHarga,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        deskripsi,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text("Jumlah: $jumlah"),
      trailing: Text(
        "Rp ${formatRupiah(totalHarga)}",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
