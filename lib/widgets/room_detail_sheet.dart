import 'package:flutter/material.dart';
import '../models/room_model.dart';
import '../utils/floor_label.dart';

/// Bottom sheet detail ruangan ala Google Maps.
/// [onShowOnMap] dipanggil ketika tombol "Lihat di Peta" ditekan.
class RoomDetailSheet extends StatelessWidget {
  final RoomModel room;
  final VoidCallback? onShowOnMap;

  const RoomDetailSheet({
    super.key,
    required this.room,
    this.onShowOnMap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSec = isDark ? Colors.white60 : Colors.black54;
    final divider = isDark
        ? Colors.white10
        : Colors.black.withValues(alpha: 0.07);
    final screenH = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(maxHeight: screenH * 0.85),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle bar ──────────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 2),
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white24
                  : Colors.black.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // ── Konten scroll ────────────────────────────────────────────────
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: room.color.withValues(alpha: 0.13),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            room.code,
                            style: TextStyle(
                              color: room.color,
                              fontWeight: FontWeight.w800,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              room.name,
                              style: TextStyle(
                                color: textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 6),
                            _CategoryBadge(room: room),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),
                  Divider(color: divider),
                  const SizedBox(height: 14),

                  // Foto slot
                  _PhotoSection(room: room, isDark: isDark),

                  const SizedBox(height: 18),

                  // Deskripsi
                  Text(
                    'Tentang Ruangan',
                    style: TextStyle(
                      color: textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    room.desc,
                    style: TextStyle(
                      color: textSec,
                      fontSize: 14,
                      height: 1.65,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Info chips
                  Wrap(
                    spacing: 8,
                    children: [
                      _InfoChip(
                        icon: Icons.layers_rounded,
                        label: floorLabelFull(room.floor),
                        isDark: isDark,
                      ),
                      _InfoChip(
                        icon: Icons.door_front_door_outlined,
                        label: 'Kode ${room.code}',
                        color: room.color,
                        isDark: isDark,
                      ),
                    ],
                  ),

                  // Tombol "Lihat di Peta" — hanya tampil kalau callback ada
                  if (onShowOnMap != null) ...[
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: room.color,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          onShowOnMap!();
                        },
                        icon: const Icon(Icons.my_location_rounded, size: 18),
                        label: const Text(
                          'Lihat di Peta',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Category badge ────────────────────────────────────────────────────────────
class _CategoryBadge extends StatelessWidget {
  final RoomModel room;
  const _CategoryBadge({required this.room});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: room.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: room.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: room.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            RoomColors.labelFromCategory(room.category),
            style: TextStyle(
              color: room.color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Foto section ──────────────────────────────────────────────────────────────
class _PhotoSection extends StatelessWidget {
  final RoomModel room;
  final bool isDark;
  const _PhotoSection({required this.room, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (room.images.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Foto Ruangan',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 165,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: room.images.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, i) => ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  room.images[i],
                  width: 225,
                  height: 165,
                  fit: BoxFit.cover,
                  // Decode hanya sebesar ukuran display (225px) — hemat RAM signifikan
                  cacheWidth: 450, // 2x untuk layar retina/HDPI
                  errorBuilder: (context, error, stackTrace) => _photoPlaceholder(),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white10
              : Colors.black.withValues(alpha: 0.07),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 32,
            color: isDark ? Colors.white24 : Colors.black26,
          ),
          const SizedBox(height: 6),
          Text(
            'Foto belum tersedia',
            style: TextStyle(
              color: isDark ? Colors.white38 : Colors.black38,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _photoPlaceholder() {
    return Container(
      width: 225,
      height: 165,
      color: isDark
          ? Colors.white.withValues(alpha: 0.07)
          : Colors.black.withValues(alpha: 0.05),
      child: const Center(
        child: Icon(Icons.broken_image_outlined,
            color: Colors.white30, size: 32),
      ),
    );
  }
}

// ── Info chip ─────────────────────────────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final bool isDark;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.isDark,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? (isDark ? Colors.white54 : Colors.black54);
    final bg = isDark
        ? Colors.white.withValues(alpha: 0.07)
        : Colors.black.withValues(alpha: 0.05);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: c),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: c,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
