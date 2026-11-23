import 'package:flutter/material.dart';

class DetailDoaScreen extends StatelessWidget {
  final String title;
  final String arabicText;
  final String translation;
  final String reference;

  const DetailDoaScreen({
    super.key,
    required this.title,
    required this.arabicText,
    required this.translation,
    required this.reference,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F1F9), // Menyesuaikan latar belakang
      appBar: AppBar(
        backgroundColor: const Color(0xFFE88A68), // Warna oranye koral senada
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: "PoppinsMedium",
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          // Jika ingin menggunakan background gambar, aktifkan baris di bawah:
           image: DecorationImage(
             image: AssetImage('assets/images/background_sunset2.jpg'),
             fit: BoxFit.cover,
           ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8.0,
                    spreadRadius: 1.0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Judul Doa
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: "PoppinsMedium",
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE88A68),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Teks Arab
                  Text(
                    arabicText,
                    textAlign: TextAlign.right, // Teks Arab rata kanan
                    style: const TextStyle(
                      fontFamily: "Traditional Arabic", // Atau font Arab kustommu
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.8,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Terjemahan
                  Text(
                    translation,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: "PoppinsMedium",
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Referensi / Sumber Doa
                  Text(
                    reference,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: "PoppinsMedium",
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}