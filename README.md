# Peta Interaktif Grhatama Pustaka

Aplikasi peta interaktif gedung **Grhatama Pustaka** – Balai Layanan Perpustakaan DPAD DIY, dibangun dengan Flutter Web.

## Fitur

- 🗺️ Peta interaktif 3 lantai (zoom, pan, tap marker)
- 📋 Daftar ruangan dengan filter kategori & pencarian
- ℹ️ Halaman info kontak & lokasi instansi
- 🌙 Mode gelap / terang
- 📱 Responsif (mobile & desktop)
- ⚡ PWA — bisa di-bookmark/install dari browser

## Teknologi

- Flutter 3.x (Web)
- Renderer: HTML (ringan, optimal untuk mobile)
- Package: `url_launcher`

## Menjalankan Lokal

```bash
flutter pub get
flutter run -d chrome --web-renderer html
```

## Build untuk Produksi

```bash
flutter build web --release --no-tree-shake-icons
```

Output ada di `build/web/`.

## Deploy

Proyek ini di-deploy otomatis ke **Vercel** via `vercel.json`.  
Setiap push ke branch `main` akan trigger deploy ulang.

## Struktur Proyek

```
lib/
├── main.dart               — Entry point & tema global
├── data/room_data.dart     — Data master semua ruangan
├── models/room_model.dart  — Model & kategori ruangan
├── screens/
│   ├── home_screen.dart    — Shell navigasi utama
│   ├── map_screen.dart     — Peta interaktif
│   ├── room_list_screen.dart — Daftar & cari ruangan
│   └── info_screen.dart    — Info & kontak instansi
└── widgets/
    └── room_detail_sheet.dart — Bottom sheet detail ruangan
```

---

© 2026 Balai Layanan Perpustakaan – DPAD DIY
