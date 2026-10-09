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

  void _openViewer(BuildContext context, int initialIndex) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        barrierDismissible: true,
        pageBuilder: (_, __, ___) => _PhotoViewerPage(
          images: room.images,
          initialIndex: initialIndex,
          roomName: room.name,
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (room.images.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Foto Ruangan',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${room.images.length} foto',
                style: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black38,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 165,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: room.images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) => GestureDetector(
                onTap: () => _openViewer(context, i),
                child: Hero(
                  tag: 'photo_${room.code}_$i',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        Image.asset(
                          room.images[i],
                          width: 225,
                          height: 165,
                          fit: BoxFit.cover,
                          cacheWidth: 450,
                          errorBuilder: (_, __, ___) => _photoPlaceholder(),
                        ),
                        // Overlay icon tap hint
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.fullscreen_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
          Icon(Icons.add_photo_alternate_outlined,
              size: 32, color: isDark ? Colors.white24 : Colors.black26),
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
        child: Icon(Icons.broken_image_outlined, color: Colors.white30, size: 32),
      ),
    );
  }
}

// ── Full screen photo viewer ──────────────────────────────────────────────────
class _PhotoViewerPage extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final String roomName;

  const _PhotoViewerPage({
    required this.images,
    required this.initialIndex,
    required this.roomName,
  });

  @override
  State<_PhotoViewerPage> createState() => _PhotoViewerPageState();
}

class _PhotoViewerPageState extends State<_PhotoViewerPage> {
  late PageController _pageCtrl;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _pageCtrl = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.images.length;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── PageView foto ──────────────────────────────────────────────
          PageView.builder(
            controller: _pageCtrl,
            itemCount: total,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (context, i) => _ZoomablePage(
              imagePath: widget.images[i],
              heroTag: 'photo_${widget.roomName}_$i',
            ),
          ),

          // ── Tombol tutup ───────────────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded,
                    color: Colors.white, size: 22),
              ),
            ),
          ),

          // ── Counter foto (X / N) ───────────────────────────────────────
          if (total > 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_current + 1} / $total',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

          // ── Nama ruangan di bawah ──────────────────────────────────────
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 20,
            left: 20,
            right: 20,
            child: Text(
              widget.roomName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // ── Dot indicator ──────────────────────────────────────────────
          if (total > 1)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 44,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(total, (i) {
                  final active = i == _current;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: active
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Single zoomable photo page ────────────────────────────────────────────────
class _ZoomablePage extends StatefulWidget {
  final String imagePath;
  final String heroTag;

  const _ZoomablePage({required this.imagePath, required this.heroTag});

  @override
  State<_ZoomablePage> createState() => _ZoomablePageState();
}

class _ZoomablePageState extends State<_ZoomablePage> {
  final TransformationController _ctrl = TransformationController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Double tap untuk reset zoom
      onDoubleTap: () {
        if (_ctrl.value != Matrix4.identity()) {
          _ctrl.value = Matrix4.identity();
        } else {
          // Zoom in 2.5x ke tengah
          final m = Matrix4.identity()..scale(2.5);
          _ctrl.value = m;
        }
      },
      child: InteractiveViewer(
        transformationController: _ctrl,
        minScale: 0.8,
        maxScale: 5.0,
        child: Center(
          child: Hero(
            tag: widget.heroTag,
            child: Image.asset(
              widget.imagePath,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(Icons.broken_image_outlined,
                    color: Colors.white30, size: 48),
              ),
            ),
          ),
        ),
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
