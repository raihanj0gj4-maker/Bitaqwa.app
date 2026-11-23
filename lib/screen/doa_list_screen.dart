import 'package:bitaqwa/data/dummy/doa_data.dart';
import 'package:bitaqwa/enum/kategori_doa_enum.dart';
import 'package:bitaqwa/extention/kategori_doa_ext.dart';
import 'package:bitaqwa/screen/doa_detail_screen.dart';
import 'package:flutter/material.dart';

class DoaListScreen extends StatelessWidget {
  final DoaCategory category;

  const DoaListScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final doaList = doaData[category] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFE8F1F9), // Warna latar belakang biru muda
      appBar: AppBar(
        backgroundColor: const Color(0xFFE88A68), // Warna oranye koral pada AppBar
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          category.title, // Menggunakan extension nama kategori (misal: "Pagi & Malam")
          style: const TextStyle(
            color: Colors.white,
            fontFamily: "PoppinsMedium",
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        itemCount: doaList.length,
        itemBuilder: (context, index) {
          final doa = doaList[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4.0,
                    spreadRadius: 1.0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
              leading: Image.asset(
  category.image, // <-- Ganti dengan path gambar Anda
  width: 44,
  height: 44,
  errorBuilder: (context, error, stackTrace) =>
      const Icon(Icons.image, size: 40), // Fallback jika gambar tidak ketemu
),
                title: Text(
                  doa.title,
                  style: const TextStyle(
                    fontFamily: "PoppinsMedium",
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailDoaScreen(
                        title: doa.title,
                        arabicText: doa.arabicText,
                        translation: doa.translation,
                        reference: doa.reference,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}