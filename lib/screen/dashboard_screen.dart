import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              HeaderSection(),
              SizedBox(height: 24),
              // Transform.translate(
              //   offset: const Offset(0, -1),
              //   child: const MenuSection(),
              // ),
              MenuSection(),
              SizedBox(height: 24),
              InspirationSection(),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// ======================================================
// HELPER: TENTUKAN WAKTU (PAGI/SIANG/MALAM)
// ======================================================

String getBackgroundImage(DateTime time) {
  final hour = time.hour;

  if (hour >= 4 && hour < 11) {
    // Pagi: 04:00 - 10:59
    return 'assets/images/gambar_pagi2.jpg';
  } else if (hour >= 11 && hour < 18) {
    // Siang: 11:00 - 17:59
    return 'assets/images/gambar_siang2.jpg';
  } else {
    // Malam: 18:00 - 03:59
    return 'assets/images/gambar_malam2.jpg';
  }
}

String getGreeting(DateTime time) {
  final hour = time.hour;

  if (hour >= 4 && hour < 11) {
    return 'Selamat Pagi';
  } else if (hour >= 11 && hour < 18) {
    return 'Selamat Siang';
  } else {
    return 'Selamat Malam';
  }
}

// ======================================================
// HEADER
// ======================================================

class HeaderSection extends StatefulWidget {
  const HeaderSection({super.key});

  @override
  State<HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<HeaderSection> {
  late String _backgroundImage;
  late String _greeting;
  late String _timeString;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _backgroundImage = getBackgroundImage(now);
    _greeting = getGreeting(now);
    _timeString = DateFormat('HH:mm').format(now);

    // Dicek tiap detik, tapi setState hanya dipanggil kalau ada yang berubah
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateAll());
  }

  void _updateAll() {
    final now = DateTime.now();
    final newBackground = getBackgroundImage(now);
    final newGreeting = getGreeting(now);
    final newTime = DateFormat('HH:mm').format(now);

    final changed = newBackground != _backgroundImage ||
        newGreeting != _greeting ||
        newTime != _timeString;

    if (mounted && changed) {
      setState(() {
        _backgroundImage = newBackground;
        _greeting = newGreeting;
        _timeString = newTime;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 305,
      width: double.infinity,
      child: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13),
              child: Image.asset(
                _backgroundImage,
                key: ValueKey(_backgroundImage),
                fit: BoxFit.cover,
                width: double.infinity,
                height: 305,
              ),
            ),
          ),
          

          // Jam realtime
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                _timeString,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Greeting
          Positioned(
            top: 86,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$_greeting Fulan',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF444444),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// MENU
// ======================================================

class MenuSection extends StatelessWidget {
  const MenuSection({super.key});

  Future<void> navi(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tidak bisa membuka $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 13),
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF48E6C),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          MenuItem(
            image: 'assets/images/gambar_tanganberdoa.png',
            title: 'Doa-doa',
            onTap: () => Navigator.pushNamed(context, '/doa'),
          ),
          MenuItem(
            image: 'assets/images/gambar_zakat.png',
            title: 'Zakat',
            onTap: () => Navigator.pushNamed(context, '/zakat')
          ),
          MenuItem(
            image: 'assets/images/gambar_jadwalsholat.png',
            title: 'Jadwal Sholat',
            onTap: () => Navigator.pushNamed(context, '/jadwal-sholat')
                
          ),
          MenuItem(
            image: 'assets/images/gambar_video_kajian.png',
            title: 'Video Kajian',
            onTap: () => Navigator.pushNamed(context, '/video-kajian'),
          ),
        ],
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  final String image;
  final String title;
  final VoidCallback onTap;

  const MenuItem({
    super.key,
    required this.image,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: const BoxDecoration(
                color: Color(0xFF4F4C73),
                shape: BoxShape.circle,
              ),
              child: Image.asset(image),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// INSPIRATION
// ======================================================

class InspirationSection extends StatelessWidget {
  const InspirationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: Column(
        children: const [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Inspirasi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF222222),
              ),
            ),
          ),
          SizedBox(height: 24),
          InspirationCard(
            quote: '"Dan pada sebagian malam, '
                'bertahajudlah kamu sebagai '
                'suatu ibadah tambahan bagimu, '
                'mudah-mudahan Tuhanmu '
                'mengangkatmu ke tempat yang terpuji."',
          ),
          SizedBox(height: 7),
          InspirationCard(
            quote: '"Sesungguhnya bersama kesulitan '
                'ada kemudahan. Maka apabila kamu '
                'telah selesai dari suatu urusan, '
                'tetaplah bekerja keras."',
          ),
        ],
      ),
    );
  }
}

class InspirationCard extends StatelessWidget {
  final String quote;

  const InspirationCard({
    super.key,
    required this.quote,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 240,
      decoration: BoxDecoration(
        color: const Color(0xFF354762),
        borderRadius: BorderRadius.circular(1),
      ),
      child: Stack(
        children: [
          // Garis dekorasi
          Positioned.fill(
            child: CustomPaint(
              painter: InspirationBackgroundPainter(),
            ),
          ),

          // Judul
          const Positioned(
            top: 27,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'TAHAJUD',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),

          // Awan kiri
          const Positioned(
            top: 34,
            left: 25,
            child: SmallCloud(),
          ),

          // Awan kanan
          const Positioned(
            top: 38,
            right: 24,
            child: SmallCloud(),
          ),

          // Quote
          Positioned(
            top: 78,
            left: 25,
            right: 25,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFEFECE7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                quote,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF4A4A4A),
                  fontSize: 10,
                  height: 1.25,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Bintang
          const Positioned(
            left: 15,
            bottom: 25,
            child: Text('✦', style: TextStyle(color: Colors.white, fontSize: 18)),
          ),
          const Positioned(
            right: 15,
            bottom: 30,
            child: Text('✦', style: TextStyle(color: Colors.white, fontSize: 18)),
          ),
          const Positioned(
            left: 70,
            bottom: 20,
            child: Text('✦', style: TextStyle(color: Colors.white, fontSize: 11)),
          ),
          const Positioned(
            right: 65,
            bottom: 22,
            child: Text('✦', style: TextStyle(color: Colors.white, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// SMALL CLOUD
// ======================================================

class SmallCloud extends StatelessWidget {
  const SmallCloud({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 62,
      height: 27,
      child: CustomPaint(
        painter: SmallCloudPainter(),
      ),
    );
  }
}

class SmallCloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF56677E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();

    path.moveTo(2, 19);
    path.quadraticBezierTo(5, 7, 15, 11);
    path.quadraticBezierTo(22, -1, 31, 10);
    path.quadraticBezierTo(43, 2, 52, 12);
    path.quadraticBezierTo(60, 14, 60, 20);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// ======================================================
// INSPIRATION BACKGROUND
// ======================================================

class InspirationBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF718096)
      ..strokeWidth = 1;

    // Garis vertikal seperti tali
    for (double x = 10; x < size.width; x += 32) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Titik dekorasi
    final dotPaint = Paint()..color = Colors.white.withValues(alpha: 0.65);

    canvas.drawCircle(
      Offset(18, size.height - 35),
      2,
      dotPaint,
    );

    canvas.drawCircle(
      Offset(size.width - 18, size.height - 40),
      2,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}