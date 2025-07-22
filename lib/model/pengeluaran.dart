class PengeluaranModel {
  String deskripsi;
  int pengeluaran;
  int saldoSebelumnya;

  PengeluaranModel({
    required this.deskripsi,
    required this.pengeluaran,
    required this.saldoSebelumnya,
  });

  int get saldoAkhir => saldoSebelumnya - pengeluaran;
}
