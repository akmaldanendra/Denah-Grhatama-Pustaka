import 'package:flutter/material.dart';

// 5 Kategori ruangan sesuai legenda denah
enum RoomCategory {
  loker,       // Loker Penitipan       — teal hijau
  koleksi,     // Ruang Layanan/Koleksi — amber kuning
  pertemuan,   // Ruang Pertemuan       — pink gelap
  kantor,      // Kantor/Administrasi   — biru
  cafetaria,   // Cafetaria             — pink muda
}

// Palet 5 warna resmi berdasarkan legenda denah Grhatama Pustaka
class RoomColors {
  static const Color loker     = Color(0xFF26A69A); // Teal
  static const Color koleksi   = Color(0xFFFFA726); // Amber
  static const Color pertemuan = Color(0xFFC2185B); // Pink gelap (Ruang Pertemuan)
  static const Color kantor    = Color(0xFF1E88E5); // Biru
  static const Color cafetaria = Color(0xFFF48FB1); // Pink muda (Cafetaria)

  static Color fromCategory(RoomCategory cat) {
    switch (cat) {
      case RoomCategory.loker:     return loker;
      case RoomCategory.koleksi:   return koleksi;
      case RoomCategory.pertemuan: return pertemuan;
      case RoomCategory.kantor:    return kantor;
      case RoomCategory.cafetaria: return cafetaria;
    }
  }

  static String labelFromCategory(RoomCategory cat) {
    switch (cat) {
      case RoomCategory.loker:     return 'Loker Penitipan';
      case RoomCategory.koleksi:   return 'Ruang Layanan / Koleksi';
      case RoomCategory.pertemuan: return 'Ruang Pertemuan';
      case RoomCategory.kantor:    return 'Kantor / Administrasi';
      case RoomCategory.cafetaria: return 'Cafetaria';
    }
  }
}

class RoomModel {
  final String code;
  final String name;
  final int floor;
  final double xRatio;
  final double yRatio;
  final RoomCategory category;
  final String desc;
  // Slot gambar — isi dengan path asset saat foto tersedia
  final List<String> images;

  const RoomModel({
    required this.code,
    required this.name,
    required this.floor,
    required this.xRatio,
    required this.yRatio,
    required this.category,
    required this.desc,
    this.images = const [],
  });

  Color get color => RoomColors.fromCategory(category);
}
