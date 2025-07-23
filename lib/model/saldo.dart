class SaldoModel {
  int ?id;
  String nama;
  int saldo;

  SaldoModel({this.id, required this.nama, required this.saldo}); // id tetap 1 karena hanya satu baris

  void tambah(int jumlah) {
    saldo += jumlah;
  }

  void kurangi(int jumlah) {
    if (saldo >= jumlah) {
      saldo -= jumlah;
    }
  }

  void updateJumlah(int jumlah) {
    if(jumlah >= 0) {
      saldo = jumlah;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'saldo': saldo,
    };
  }

  factory SaldoModel.fromMap(Map<String, dynamic> map) {
    return SaldoModel(
      id: map['id'],
      nama: map['nama'],
      saldo: map['saldo'],
    );
  }
}

