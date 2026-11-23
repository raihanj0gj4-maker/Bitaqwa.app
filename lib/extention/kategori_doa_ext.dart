import 'package:bitaqwa/enum/kategori_doa_enum.dart';

extension DoaCategoryExtension on DoaCategory {
  String get title {
    switch (this) {
      case DoaCategory.makananMinuman:
        return "Makanan & Minuman";

      case DoaCategory.pagiMalam:
        return "Pagi & Malam";

      case DoaCategory.rumah:
        return "Rumah";

      case DoaCategory.perjalanan:
        return "Perjalanan";
 
      case DoaCategory.sholat:
        return "Sholat";

      case DoaCategory.etikaBaik:
        return "Etika Baik";
    }
  }

  String get image {
    switch (this) {
      case DoaCategory.makananMinuman:
        return "assets/images/icon_makanan_minuman.png";

      case DoaCategory.pagiMalam:
        return "assets/images/icon_pagi_malam_2.png";

      case DoaCategory.rumah:
        return "assets/images/icon_rumah_2.png";

      case DoaCategory.perjalanan:
        return "assets/images/icon_perjalanan_2.png";

      case DoaCategory.sholat:
        return "assets/images/icon_sholat_2.png";

      case DoaCategory.etikaBaik:
        return "assets/images/icon_etika_baik.png";
    }
  }
}
