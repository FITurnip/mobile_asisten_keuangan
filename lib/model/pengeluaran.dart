class PengeluaranModel {
  int? id;
  String deskripsi;
  int pengeluaran;
  int saldoSebelumnya;
  DateTime timestamp;

  PengeluaranModel({
    this.id,
    required this.deskripsi,
    required this.pengeluaran,
    required this.saldoSebelumnya,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  int get saldoAkhir => saldoSebelumnya - pengeluaran;

  factory PengeluaranModel.fromMap(Map<String, dynamic> map) {
    return PengeluaranModel(
      id: map['id'],
      deskripsi: map['deskripsi'],
      pengeluaran: map['pengeluaran'],
      saldoSebelumnya: map['saldo_sblm'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'deskripsi': deskripsi,
      'pengeluaran': pengeluaran,
      'saldo_sblm': saldoSebelumnya,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
