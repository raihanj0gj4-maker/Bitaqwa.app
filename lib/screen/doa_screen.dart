
import 'package:bitaqwa/data/dummy/kategori_doa_data.dart';
import 'package:bitaqwa/extention/kategori_doa_ext.dart';
import 'package:bitaqwa/widget/card_doa.dart';
import 'package:flutter/material.dart';
import 'package:bitaqwa/screen/doa_list_screen.dart';

class DoaScreen extends StatelessWidget {
  const DoaScreen({super.key});

  static const Color orange = Color(0xFFFF896B);
  static const Color background = Color(0xFFFFF8FF);

  @override
  Widget build(BuildContext context) {
    final categories = doaCategoryData;
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              height: 48,
              color: orange,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Doa-doa',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Background ilustrasi yang kamu import
            SizedBox(
              height: 200,
              width: double.infinity,
              child: Image.asset(
                'assets/images/gambar_doa_background.png',
                fit: BoxFit.fitHeight,
              ),
            ),

            const SizedBox(height: 12),

            // Grid kategori
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                itemCount: categories.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.91,
                ),
                itemBuilder: (context, index) {
                  final item = categories[index];

                  return DoaCard(
                    title: item.category.title,
                    image: item.category.image,
                    onTap: () {
                      // Navigasi ke halaman kategori doa
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DoaListScreen(
                            category: item.category,
                          ),
                        ),
                      );
                    },
                  );

                  // return Material(
                  //   color: Colors.white,
                  //   borderRadius: BorderRadius.circular(9),
                  //   child: InkWell(
                  //     borderRadius: BorderRadius.circular(9),
                  //     onTap: () {
                  //       // Tambahkan navigasi ke halaman kategori nanti.
                  //     },
                  //     child: Container(
                  //       decoration: BoxDecoration(
                  //         borderRadius: BorderRadius.circular(9),
                  //         border: Border.all(
                  //           color: const Color(0xFFF0EAF1),
                  //         ),
                  //       ),
                  //       padding: const EdgeInsets.all(6),
                  //       child: Column(
                  //         mainAxisAlignment: MainAxisAlignment.center,
                  //         children: [
                  //           Image.asset(
                  //             item.category.image,
                  //             width: 200,
                  //             height: 100,
                  //             fit: BoxFit.contain,
                  //           ),
                  //           const SizedBox(height: 6),
                  //           Text(
                  //             item.category.title,
                  //             textAlign: TextAlign.center,
                  //             style: const TextStyle(
                  //               fontSize: 15.5,
                  //               color: Color(0xFF28232B),
                  //               height: 1.2,
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),
                  // );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
