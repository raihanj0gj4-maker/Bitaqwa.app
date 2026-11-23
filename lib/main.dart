import 'package:bitaqwa/screen/jadwal_sholat_screen.dart';
import 'package:bitaqwa/screen/video_kajian_screen.dart';
import 'package:flutter/material.dart';
// Import file-file screen Anda dengan benar:
import 'package:bitaqwa/screen/dashboard_screen.dart'; // atau halaman utama Anda
import 'package:bitaqwa/screen/doa_screen.dart';
import 'package:bitaqwa/screen/zakat_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      routes: {
        '/': (context) => const HomePage(),
        '/doa': (context) => const DoaScreen(),
        '/zakat': (context) => const ZakatScreen(),
        '/jadwal-sholat': (context) => const JadwalSholatScreen(),
        '/video-kajian': (context) => const VideoKajianScreen(),

      },
      
      // home: HomePage(),

    );
  }
}
