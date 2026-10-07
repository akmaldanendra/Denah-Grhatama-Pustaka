import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  static const _websiteUrl   = 'https://balaiyanpus.jogjaprov.go.id';
  static const _mapsFallback = 'https://www.google.com/maps/search/?api=1&query=Grhatama+Pustaka+Jl+Janti+Banguntapan+Bantul+Yogyakarta';
  static const _emailAddr    = 'balaiyanpus@jogjaprov.go.id';
  static const _phoneNumber  = '+62274536234';

  Future<void> _open(BuildContext context, String rawUrl) async {
    final uri = Uri.parse(rawUrl);
    final scheme = uri.scheme.toLowerCase();

    // Di web (termasuk mobile browser): semua scheme pakai platformDefault
    // Di native app: externalApplication untuk https, platformDefault untuk mailto/tel
    final mode = kIsWeb
        ? LaunchMode.platformDefault
        : (scheme == 'https' || scheme == 'http')
            ? LaunchMode.externalApplication
            : LaunchMode.platformDefault;

    bool launched = false;
    try {
      launched = await launchUrl(uri, mode: mode);
    } catch (_) {
      launched = false;
    }

    // Fallback khusus mailto di web: copy email ke clipboard
    if (!launched && scheme == 'mailto' && kIsWeb) {
      await Clipboard.setData(ClipboardData(text: _emailAddr));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Email disalin ke clipboard: balaiyanpus@jogjaprov.go.id'),
            backgroundColor: const Color(0xFF1565C0),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
      return;
    }

    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            scheme == 'tel'
                ? 'Fitur telepon tidak tersedia di perangkat ini.'
                : 'Tidak bisa membuka link.',
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? AppColors.darkBg : const Color(0xFFF5F5F5);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: _buildAppBar(context, isDark),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroBanner(isDark),
            _buildInfoSection(isDark),
            _buildWebsiteButton(context, isDark),
            _buildContactSection(context, isDark),
            _buildFooter(isDark),
          ],
        ),
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    return AppBar(
      backgroundColor: isDark ? AppColors.darkHeader : AppColors.primary,
      title: Row(
        children: [
          Image.asset(
            'assets/images/logodpad.png',
            height: 32,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.account_balance_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Grhatama Pustaka',
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
              ),
              Text(
                'Balai Layanan Perpustakaan DPAD DIY',
                style: TextStyle(fontSize: 9, color: Colors.white60),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: isDark ? 'Mode Terang' : 'Mode Gelap',
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Icon(
              isDark ? Icons.wb_sunny_rounded : Icons.dark_mode_rounded,
              key: ValueKey(isDark),
              color: Colors.white,
              size: 20,
            ),
          ),
          onPressed: () => MyApp.of(context)?.toggleTheme(),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ── Hero banner ────────────────────────────────────────────────────────────
  Widget _buildHeroBanner(bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [AppColors.darkHeader, const Color(0xFF3E0000)]
              : [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/logodpad.png',
                height: 56,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.account_balance_rounded,
                      color: Colors.white, size: 30),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Balai Yanpus',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Dinas Perpustakaan dan Arsip Daerah\nDaerah Istimewa Yogyakarta',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 12, height: 1.45),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.map_rounded, color: Colors.white70, size: 16),
                SizedBox(width: 8),
                Text(
                  'Peta Interaktif Grhatama Pustaka',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Info singkat ───────────────────────────────────────────────────────────
  Widget _buildInfoSection(bool isDark) {
    final cardBg = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSec = isDark ? Colors.white60 : Colors.black54;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.business_rounded,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Tentang Grhatama Pustaka',
                  style: TextStyle(
                      color: textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Grhatama Pustaka adalah gedung perpustakaan milik Dinas Perpustakaan '
            'dan Arsip Daerah (DPAD) Provinsi Daerah Istimewa Yogyakarta. '
            'Perpustakaan ini menyediakan berbagai layanan literasi, koleksi buku, '
            'ruang baca, serta fasilitas penunjang bagi masyarakat DIY.',
            style: TextStyle(color: textSec, fontSize: 13.5, height: 1.65),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.badge_outlined,
                    color: AppColors.primary, size: 14),
                const SizedBox(width: 6),
                Text(
                  'NPP : 3471023F1020343',
                  style: TextStyle(
                    color: isDark ? AppColors.primaryLight : AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Tombol website resmi ───────────────────────────────────────────────────
  Widget _buildWebsiteButton(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: isDark ? AppColors.primaryDark : AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => _open(context, _websiteUrl),
          icon: const Icon(Icons.language_rounded, size: 18),
          label: const Text(
            'Kunjungi Website Resmi',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ),
      ),
    );
  }

  // ── Kontak section ─────────────────────────────────────────────────────────
  Widget _buildContactSection(BuildContext context, bool isDark) {
    final cardBg = isDark ? AppColors.darkSurface : Colors.white;

    final contacts = [
      _ContactItem(
        icon: Icons.location_on_rounded,
        title: 'Lokasi',
        subtitle: 'Jl. Janti, Banguntapan, Kabupaten Bantul,\nDI Yogyakarta 55198 Indonesia',
        color: AppColors.primary,
        url: _mapsFallback,
      ),
      _ContactItem(
        icon: Icons.email_rounded,
        title: 'Surel',
        subtitle: _emailAddr,
        color: const Color(0xFF1565C0),
        url: 'mailto:$_emailAddr',
      ),
      _ContactItem(
        icon: Icons.phone_rounded,
        title: 'Telepon',
        subtitle: '(0274) 4536234',
        color: const Color(0xFF2E7D32),
        url: 'tel:$_phoneNumber',
      ),
      _ContactItem(
        icon: Icons.schedule_rounded,
        title: 'Jam Layanan',
        subtitle: 'Senin – Jumat : 08.00 – 16.00 WIB\nSabtu – Minggu : 09.00 – 15.00 WIB',
        color: const Color(0xFFE65100),
        url: null,
      ),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header kartu
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.contact_support_rounded,
                      color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Kontak & Informasi',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Tile per kontak
          ...contacts.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            return Column(
              children: [
                _buildContactTile(context, item, isDark),
                if (i < contacts.length - 1)
                  Divider(
                    height: 1,
                    indent: 58,
                    color: isDark
                        ? Colors.white10
                        : Colors.black.withValues(alpha: 0.06),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildContactTile(
      BuildContext context, _ContactItem item, bool isDark) {
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSec = isDark ? Colors.white60 : Colors.black54;
    final isClickable = item.url != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(0),
        onTap: isClickable ? () => _open(context, item.url!) : null,
        splashColor: item.color.withValues(alpha: 0.08),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Ikon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, color: item.color, size: 20),
              ),
              const SizedBox(width: 14),

              // Teks
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        color: textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.subtitle,
                      style: TextStyle(
                        color: isClickable ? item.color : textSec,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Indikator bisa diklik
              if (isClickable)
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: item.color.withValues(alpha: 0.6),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Footer ─────────────────────────────────────────────────────────────────
  Widget _buildFooter(bool isDark) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [AppColors.darkHeader, const Color(0xFF2A0000)]
              : [AppColors.primaryDark, AppColors.primary],
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logodpad.png',
                height: 36,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.account_balance_rounded,
                  color: Colors.white54,
                  size: 32,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Balai Yanpus',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Balai Layanan Perpustakaan\nDinas Perpustakaan dan Arsip Daerah\nDaerah Istimewa Yogyakarta',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.6),
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.15)),
          const SizedBox(height: 14),
          const Text(
            '© 2026 - Balai Layanan Perpustakaan Pemda DIY\nAll Rights Reserved.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38, fontSize: 11, height: 1.6),
          ),
        ],
      ),
    );
  }
}

// ── Model kontak ──────────────────────────────────────────────────────────────
class _ContactItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String? url;

  const _ContactItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.url,
  });
}
