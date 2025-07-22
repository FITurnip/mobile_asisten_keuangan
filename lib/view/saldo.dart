import 'package:flutter/material.dart';
import 'package:mobile_asisten_keuangan/view/components/form_saldo.dart';

class SaldoView extends StatelessWidget {
  const SaldoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        FormSaldoComponent(title: 'Total Saldo', nama: 'total'),
        SizedBox(height: 32),
        FormSaldoComponent(title: 'Saldo Harian', nama: 'harian'),
      ],
    );
  }
}

