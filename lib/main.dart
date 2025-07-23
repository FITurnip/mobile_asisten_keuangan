import 'package:flutter/material.dart';
import 'package:mobile_asisten_keuangan/view/saldo.dart';
import 'package:mobile_asisten_keuangan/view/pengeluaran_harian.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_asisten_keuangan/data/saldo_dao.dart';
import 'package:shared_preferences/shared_preferences.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _resetSaldoHarianJikaPerlu();
  runApp(const AsistenKeuangan());
}

Future<void> _resetSaldoHarianJikaPerlu() async {
  final prefs = await SharedPreferences.getInstance();
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final lastResetStr = prefs.getString('last_reset_date');
  if (lastResetStr != null) {
    final lastReset = DateTime.parse(lastResetStr);
    final lastResetDate = DateTime(lastReset.year, lastReset.month, lastReset.day);

    if (today.isAfter(lastResetDate)) {
      await _resetSaldoHarian();
      await prefs.setString('last_reset_date', now.toIso8601String());
    }
  } else {
    await _resetSaldoHarian();
    await prefs.setString('last_reset_date', now.toIso8601String());
  }
}

Future<void> _resetSaldoHarian() async {
  final saldoDao = await SaldoDao();
  final _saldoHarian = await saldoDao.getSaldoByNama('harian');
  final _saldoDefault = await saldoDao.getSaldoByNama('harian_default');
  _saldoHarian!.updateJumlah(_saldoDefault!.saldo);

  await saldoDao.updateSaldo(_saldoHarian!);
}

class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController() : super(ThemeMode.system);

  void toggle() {
    if (value == ThemeMode.light) {
      value = ThemeMode.dark;
    } else if (value == ThemeMode.dark) {
      value = ThemeMode.system;
    } else {
      value = ThemeMode.light;
    }
  }

  String get label {
    switch (value) {
      case ThemeMode.light:
        return 'Terang';
      case ThemeMode.dark:
        return 'Gelap';
      default:
        return 'Sistem';
    }
  }

  IconData get icon {
    switch (value) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      default:
        return Icons.settings;
    }
  }
}

final themeController = ThemeController();

class AsistenKeuangan extends StatelessWidget {
  const AsistenKeuangan({super.key});

  static const textTheme = TextTheme(
    bodyLarge: TextStyle(fontSize: 14),
    bodyMedium: TextStyle(fontSize: 12),
    bodySmall: TextStyle(fontSize: 10),
    titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    labelSmall: TextStyle(fontSize: 10),
  );

  static final lightColorScheme = ColorScheme.fromSeed(
    seedColor: Color(0xFF2E7D32),
    brightness: Brightness.light,
  ).copyWith(primary: Color(0xFF43A047));

  static final darkColorScheme = ColorScheme.fromSeed(
    seedColor: Color(0xFF2E7D32),
    brightness: Brightness.dark,
  ).copyWith(primary: Color(0xFF43A047));

  static AppBarTheme buildAppBarTheme(ColorScheme colorScheme) {
    return AppBarTheme(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      titleTextStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: colorScheme.onPrimary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeController,
      builder: (context, mode, _) {
        return MaterialApp(
          theme: ThemeData(
            textTheme: textTheme,
            colorScheme: lightColorScheme,
            appBarTheme: buildAppBarTheme(lightColorScheme),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            textTheme: textTheme,
            colorScheme: darkColorScheme,
            appBarTheme: buildAppBarTheme(darkColorScheme),
            useMaterial3: true,
          ),
          themeMode: mode,
          home: const MainLayout(),
          debugShowCheckedModeBanner: kDebugMode,
        );
      },
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});
  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int selectedMenuIndex = 0;

  final List<Widget> menus = [
    PengeluaranHarianView(),
    SaldoView(),
  ];

  void _onSelectMenu(int index) {
    setState(() {
      selectedMenuIndex = index;
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asisten Keuangan'),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.today),
              title: const Text('Hari Ini'),
              selected: selectedMenuIndex == 0,
              onTap: () => _onSelectMenu(0),
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text('Saldo'),
              selected: selectedMenuIndex == 1,
              onTap: () => _onSelectMenu(1),
            ),
            const Divider(),
            ListTile(
              leading: Icon(themeController.icon),
              title: Text('Tema: ${themeController.label}'),
              onTap: () {
                setState(() => themeController.toggle());
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: menus[selectedMenuIndex],
      ),
    );
  }
}
