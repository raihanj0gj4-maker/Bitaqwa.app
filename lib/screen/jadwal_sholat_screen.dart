import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class JadwalSholatScreen extends StatefulWidget {
  const JadwalSholatScreen({super.key});

  @override
  State<JadwalSholatScreen> createState() => _JadwalSholatScreenState();
}

class _JadwalSholatScreenState extends State<JadwalSholatScreen> {
  List _daftarKota = [];
  String? _selectedCityId;
  String _selectedCityName = 'Mendeteksi lokasi...';
  bool _isLoading = true;
  String? _errorMessage;

  List _jadwalSholat = [];

  @override
  void initState() {
    super.initState();
    _inisialisasiOtomatis();
  }

  Future<void> _inisialisasiOtomatis() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await _muatDaftarKotaDariApi();
    await _deteksiLokasiDanAmbilJadwal();
  }

  Future<void> _muatDaftarKotaDariApi() async {
    try {
      final url = Uri.parse('https://api.myquran.com/v2/sholat/kota/semua');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final dataList = jsonData['data'] as List<dynamic>?;
        if (dataList != null && dataList.isNotEmpty) {
          final parsed = dataList
              .map((item) => item as Map<String, dynamic>)
              .map((item) => {
                    'id': item['id'].toString(),
                    'nama': item['lokasi'].toString(),
                  })
              .toList();

          if (!mounted) return;
          setState(() {
            _daftarKota = parsed;
            _selectedCityId ??= parsed.first['id'];
            if (_selectedCityName == 'Mendeteksi lokasi...') {
              _selectedCityName = parsed.first['nama']!;
            }
          });
        }
      }
    } catch (_) {
      // Penanganan error utama tetap terjadi saat memuat jadwal sholat dari API
    }
  }

  Future<void> _deteksiLokasiDanAmbilJadwal() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Layanan lokasi tidak aktif.');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Izin lokasi belum diberikan.');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final namaWilayah = await _ambilNamaWilayahDariKoordinat(
        position.latitude,
        position.longitude,
      );

      if (namaWilayah == null || namaWilayah.isEmpty) {
        throw Exception('Nama wilayah tidak ditemukan dari koordinat.');
      }

      final kotaApi = await _cariKotaDiApi(namaWilayah);
      if (kotaApi == null) {
        throw Exception('Kota "$namaWilayah" tidak ditemukan pada API jadwal sholat.');
      }

      if (!mounted) return;
      setState(() {
        _selectedCityId = kotaApi['id']!;
        _selectedCityName = kotaApi['lokasi']!;
      });

      await _ambilJadwalDariApi(kotaApi['id']!);
    } catch (e) {
      if (!mounted) return;
      // Jika sudah ada _selectedCityId dari daftar kota API, tetap coba ambil jadwal API
      if (_selectedCityId != null) {
        await _ambilJadwalDariApi(
          _selectedCityId!,
          catatanTambahan: e.toString().replaceFirst('Exception: ', ''),
        );
      } else {
        setState(() {
          _jadwalSholat = [];
          _isLoading = false;
          _errorMessage =
              'Gagal memuat jadwal dari API: ${e.toString().replaceFirst('Exception: ', '')}';
        });
      }
    }
  }

  Future<String?> _ambilNamaWilayahDariKoordinat(double lat, double lon) async {
    if (!kIsWeb) {
      final placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final wilayah = (place.subAdministrativeArea?.trim().isNotEmpty == true
                ? place.subAdministrativeArea!
                : (place.locality ?? ''))
            .trim();
        if (wilayah.isNotEmpty) return wilayah;
      }
      return null;
    }

    final uri = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=$lat&lon=$lon',
    );
    final res = await http.get(
      uri,
      headers: {'User-Agent': 'FlutterJadwalSholatApp/1.0'},
    ).timeout(const Duration(seconds: 10));

    if (res.statusCode == 200) {
      final data = json.decode(res.body) as Map<String, dynamic>;
      final address = data['address'] as Map<String, dynamic>?;
      if (address != null) {
        return (address['city'] ??
                address['county'] ??
                address['regency'] ??
                address['state_district'] ??
                address['town'] ??
                address['village'])
            ?.toString();
      }
    }
    return null;
  }

  String _bersihkanNamaKota(String nama) {
    return nama
        .toLowerCase()
        .replaceAll(
          RegExp(
            r'\b(kabupaten|kab\.?|kota|administrasi|daerah khusus ibukota|dki|daerah istimewa|di)\b',
          ),
          '',
        )
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Future? _cariKotaDiApi(String namaWilayah) async {
    final keyword = Uri.encodeComponent(_bersihkanNamaKota(namaWilayah));
    if (keyword.isEmpty) return null;

    final url = Uri.parse('https://api.myquran.com/v2/sholat/kota/cari/$keyword');
    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      final list = jsonData['data'] as List<dynamic>?;
      if (list != null && list.isNotEmpty) {
        final first = list.first as Map<String, dynamic>;
        return {
          'id': first['id'].toString(),
          'lokasi': first['lokasi'].toString(),
        };
      }
    }
    return null;
  }

  Future<void> _ambilJadwalDariApi(
    String cityId, {
    String? catatanTambahan,
  }) async {
    setState(() {
      _isLoading = true;
      _errorMessage = catatanTambahan;
    });

    final now = DateTime.now();
    final year = DateFormat('yyyy').format(now);
    final month = DateFormat('MM').format(now);
    final day = DateFormat('dd').format(now);

    final url = Uri.parse(
      'https://api.myquran.com/v2/sholat/jadwal/$cityId/$year/$month/$day',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        final data = jsonData['data'] as Map<String, dynamic>?;
        final jadwal = data?['jadwal'] as Map<String, dynamic>?;
        final lokasiApi = data?['lokasi']?.toString();

        if (jadwal != null) {
          if (!mounted) return;
          setState(() {
            if (lokasiApi != null && lokasiApi.isNotEmpty) {
              _selectedCityName = lokasiApi;
            }
            _jadwalSholat = [
              {'nama': 'Subuh', 'waktu': (jadwal['subuh'] ?? '--:--').toString()},
              {'nama': 'Dzuhur', 'waktu': (jadwal['dzuhur'] ?? '--:--').toString()},
              {'nama': 'Ashar', 'waktu': (jadwal['ashar'] ?? '--:--').toString()},
              {'nama': 'Maghrib', 'waktu': (jadwal['maghrib'] ?? '--:--').toString()},
              {'nama': 'Isya', 'waktu': (jadwal['isya'] ?? '--:--').toString()},
            ];
            _isLoading = false;
          });
          return;
        }
      }

      if (!mounted) return;
      setState(() {
        _jadwalSholat = [];
        _isLoading = false;
        _errorMessage = 'Gagal mengambil jadwal sholat dari API.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _jadwalSholat = [];
        _isLoading = false;
        _errorMessage = 'Tidak dapat terhubung ke API jadwal sholat.';
      });
    }
  }

  Map<String, String>? _cariSholatBerikutnya(DateTime sekarang) {
    if (_jadwalSholat.isEmpty) return null;
    final menitSekarang = sekarang.hour * 60 + sekarang.minute;

    for (final item in _jadwalSholat) {
      final parts = item['waktu']!.split(':');
      if (parts.length == 2) {
        final jam = int.tryParse(parts[0]) ?? 0;
        final menit = int.tryParse(parts[1]) ?? 0;
        final totalMenitSholat = jam * 60 + menit;

        if (totalMenitSholat > menitSekarang) {
          return item;
        }
      }
    }

    return _jadwalSholat.first;
  }

  @override
  Widget build(BuildContext context) {
    final sekarang = DateTime.now();
    final tanggalFormatted =
        DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(sekarang);
    final sholatBerikutnya = _cariSholatBerikutnya(sekarang);
    final namaSholatBerikutnya = sholatBerikutnya?['nama'] ?? '-';
    final waktuSholatBerikutnya = sholatBerikutnya?['waktu'] ?? '--:--';

    final dropdownValue =
        _daftarKota.any((k) => k['id'] == _selectedCityId) ? _selectedCityId : null;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFF7E5F),
              Color(0xFFFEB47B),
              Color(0xFF4A5568),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Utama
              Container(
                height: 52,
                padding: const EdgeInsets.only(right: 8),
                color: Colors.transparent,
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
                        'Jadwal Sholat',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: dropdownValue,
                        hint: const Text(
                          'Pilih Kota',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        dropdownColor: const Color(0xFF3A4454),
                        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                        items: _daftarKota.map((kota) {
                          return DropdownMenuItem<String>(
                            value: kota['id'],
                            child: Text(kota['nama']!),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          final kotaDipilih = _daftarKota.firstWhere(
                            (k) => k['id'] == value,
                            orElse: () => _daftarKota.first,
                          );
                          setState(() {
                            _selectedCityId = value;
                            _selectedCityName = kotaDipilih['nama']!;
                            _errorMessage = null;
                          });
                          _ambilJadwalDariApi(value);
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: _inisialisasiOtomatis,
                      tooltip: 'Deteksi lokasi & ambil jadwal API',
                      icon: const Icon(
                        Icons.my_location_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),

              // Bagian Konten Utama
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10.0),
                        padding: const EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 20.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.location_on,
                                    color: Color(0xFFFFE600), size: 18),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    _selectedCityName,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              tanggalFormatted,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 20),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.15)),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Sholat Berikutnya',
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        namaSholatBerikutnya,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    waktuSholatBerikutnya,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 4),
                          child: Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),

                      const SizedBox(height: 10),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: _isLoading
                              ? const Padding(
                                  padding: EdgeInsets.all(32.0),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFFFF896B),
                                    ),
                                  ),
                                )
                              : _jadwalSholat.isEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.all(24.0),
                                      child: Column(
                                        children: [
                                          const Text(
                                            'Jadwal sholat dari API belum tersedia.',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Color(0xFF2D3142),
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          ElevatedButton(
                                            onPressed: _inisialisasiOtomatis,
                                            child: const Text('Coba Lagi'),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.separated(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: _jadwalSholat.length,
                                      separatorBuilder: (context, index) =>
                                          const Divider(
                                        height: 1,
                                        thickness: 1,
                                        color: Color(0xFFF0F0F0),
                                        indent: 20,
                                        endIndent: 20,
                                      ),
                                      itemBuilder: (context, index) {
                                        final item = _jadwalSholat[index];
                                        final bool isAktif =
                                            item['nama'] == namaSholatBerikutnya;

                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 16),
                                          decoration: BoxDecoration(
                                            color: isAktif
                                                ? const Color(0xFFFF896B)
                                                    .withValues(alpha: 0.1)
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                                isAktif ? 16 : 0),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: isAktif
                                                          ? const Color(0xFFFF896B)
                                                              .withValues(
                                                                  alpha: 0.2)
                                                          : const Color(0xFFF4F7F6),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(
                                                      Icons.access_time_rounded,
                                                      color: isAktif
                                                          ? const Color(0xFFFF896B)
                                                          : Colors.grey,
                                                      size: 20,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 14),
                                                  Text(
                                                    item['nama']!,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: isAktif
                                                          ? FontWeight.bold
                                                          : FontWeight.w500,
                                                      color: isAktif
                                                          ? const Color(0xFFFF896B)
                                                          : const Color(0xFF2D3142),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    item['waktu']!,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: isAktif
                                                          ? FontWeight.bold
                                                          : FontWeight.w600,
                                                      color: isAktif
                                                          ? const Color(0xFFFF896B)
                                                          : const Color(0xFF2D3142),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  const Icon(
                                                    Icons.notifications_active_rounded,
                                                    color: Color(0xFFFF896B),
                                                    size: 20,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}