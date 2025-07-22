String formatRupiah(int number) {
  return "Rp${number.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => "${m[1]}.",
    )}";
}
