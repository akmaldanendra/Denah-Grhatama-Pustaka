import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../main.dart';
import '../models/room_model.dart';
import '../data/room_data.dart';
import '../widgets/room_detail_sheet.dart';
import '../utils/floor_label.dart';

class MapScreen extends StatefulWidget {
  final RoomModel? initialRoom;

  const MapScreen({super.key, this.initialRoom});

  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen>
    with TickerProviderStateMixin {
  int currentFloor = 1;
  RoomModel? selectedZone;
  bool _showRoomList = true;

  late AnimationController _panelAnim;
  late Animation<double> _panelSlide;

  // Controller untuk animasi pulse pada marker selected
  late AnimationController _pulseAnim;

  // Controller untuk animasi smooth pan ke marker
  AnimationController? _flyAnim;
  Animation<Matrix4>? _flyMatrix;

  final TransformationController _transformController =
      TransformationController();
  final GlobalKey _viewerKey = GlobalKey();

  final double originalWidth  = 1200.0;
  final double originalHeight = 900.0;

  // Target zoom saat focus ke ruangan
  static const double _focusScale = 2.2;

  // Cache list ruangan per lantai
  static final Map<int, List<RoomModel>> _roomsByFloor = {
    1: masterRoomsData.where((r) => r.floor == 1).toList(),
    2: masterRoomsData.where((r) => r.floor == 2).toList(),
    3: masterRoomsData.where((r) => r.floor == 3).toList(),
  };

  String get currentMapAsset => 'assets/images/lantai$currentFloor.png';
  List<RoomModel> get currentFloorRooms => _roomsByFloor[currentFloor] ?? [];

  @override
  void initState() {
    super.initState();

    _panelAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1.0,
    );
    _panelSlide = CurvedAnimation(parent: _panelAnim, curve: Curves.easeInOut);

    // Pulse loop untuk marker selected
    _pulseAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    if (widget.initialRoom != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        focusRoom(widget.initialRoom!);
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache semua gambar peta di awal agar perpindahan lantai instan
    precacheImage(const AssetImage('assets/images/lantai1.png'), context);
    for (int i = 2; i <= 3; i++) {
      precacheImage(AssetImage('assets/images/lantai$i.png'), context);
    }
  }

  @override
  void dispose() {
    _panelAnim.dispose();
    _pulseAnim.dispose();
    _flyAnim?.dispose();
    _transformController.dispose();
    super.dispose();
  }

  void _togglePanel() {
    setState(() => _showRoomList = !_showRoomList);
    _showRoomList ? _panelAnim.forward() : _panelAnim.reverse();
  }

  // ── Smooth fly-to: animasikan TransformationController ke posisi marker ───
  void _flyToRoom(RoomModel room) {
    final RenderBox? viewerBox =
        _viewerKey.currentContext?.findRenderObject() as RenderBox?;
    if (viewerBox == null) return;

    final viewerSize = viewerBox.size;

    // Hitung Matrix4 target: scale ke _focusScale, posisikan marker di tengah viewport
    final double targetX = room.xRatio * originalWidth;
    final double targetY = room.yRatio * originalHeight;

    // Seberapa besar gambar di-fit ke viewer (FittedBox contain)
    final double fitScale = (viewerSize.width / originalWidth)
        .clamp(0.0, viewerSize.height / originalHeight);

    final double finalScale = _focusScale;

    // Terjemahkan agar titik (targetX, targetY) ada di tengah viewport
    final double tx = viewerSize.width  / 2 - targetX * fitScale * finalScale;
    final double ty = viewerSize.height / 2 - targetY * fitScale * finalScale;

    final Matrix4 target = Matrix4.identity()
      ..translate(tx, ty)
      ..scale(finalScale);

    final Matrix4 start = _transformController.value.clone();

    _flyAnim?.dispose();
    _flyAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _flyMatrix = Matrix4Tween(begin: start, end: target).animate(
      CurvedAnimation(parent: _flyAnim!, curve: Curves.easeInOutCubic),
    )..addListener(() {
        _transformController.value = _flyMatrix!.value;
      });

    _flyAnim!.forward();
  }

  /// Publik — dipanggil dari HomeScreen saat navigasi dari halaman daftar
  void focusRoom(RoomModel room) {
    setState(() {
      currentFloor = room.floor;
      selectedZone = room;
    });
    // Fly dulu, lalu tampilkan sheet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _flyToRoom(room);
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _showDetail(room);
      });
    });
  }

  void _showDetail(RoomModel room) {
    setState(() => selectedZone = room);
    _flyToRoom(room);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RoomDetailSheet(room: room),
    ).then((_) {
      if (mounted) setState(() => selectedZone = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide = MediaQuery.of(context).size.width >= 720;

    return Scaffold(
      appBar: _buildAppBar(isDark),
      body: isWide
          ? _buildWideLayout(isDark)
          : _buildNarrowLayout(isDark),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark ? AppColors.darkHeader : AppColors.primary,
      title: Row(
        children: [
          Image.asset(
            'assets/images/logodpad.png',
            height: 30,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.account_balance_rounded,
              color: Colors.white,
              size: 26,
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
                'Peta Interaktif',
                style: TextStyle(
                    fontSize: 9, color: Colors.white60, fontWeight: FontWeight.w400),
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
              size: 21,
            ),
          ),
          onPressed: () => MyApp.of(context)?.toggleTheme(),
        ),
        IconButton(
          tooltip: _showRoomList ? 'Tutup Panel' : 'Buka Panel',
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              _showRoomList ? Icons.menu_open_rounded : Icons.menu_rounded,
              key: ValueKey(_showRoomList),
              color: Colors.white,
            ),
          ),
          onPressed: _togglePanel,
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ── Wide layout ────────────────────────────────────────────────────────────
  Widget _buildWideLayout(bool isDark) {
    return Row(
      children: [
        Expanded(child: _buildMapArea(isDark, isWide: true)),
        SizeTransition(
          axis: Axis.horizontal,
          sizeFactor: _panelSlide,
          child: SizedBox(
            width: 300,
            child: _buildRoomPanel(isDark, isWide: true),
          ),
        ),
      ],
    );
  }

  // ── Narrow layout ──────────────────────────────────────────────────────────
  Widget _buildNarrowLayout(bool isDark) {
    return Column(
      children: [
        Expanded(child: _buildMapArea(isDark, isWide: false)),
        SizeTransition(
          sizeFactor: _panelSlide,
          axisAlignment: -1,
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.36,
            child: _buildRoomPanel(isDark, isWide: false),
          ),
        ),
      ],
    );
  }

  // ── Area peta ──────────────────────────────────────────────────────────────
  Widget _buildMapArea(bool isDark, {required bool isWide}) {
    return Stack(
      children: [
        Container(
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFEEF2F7),
        ),
        InteractiveViewer(
          key: _viewerKey,
          transformationController: _transformController,
          minScale: 0.5,
          maxScale: 5.0,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: originalWidth,
                  height: originalHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      GestureDetector(
                        onTapDown: (_) {}, // reserved untuk debug koordinat
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            currentMapAsset,
                            width: originalWidth,
                            height: originalHeight,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildErrorPlaceholder(isDark),
                          ),
                        ),
                      ),
                      for (final room in currentFloorRooms)
                        _buildMarker(room),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        Positioned(
          right: 12,
          top: 0,
          bottom: 0,
          child: Center(child: _buildFloorSelector(isDark)),
        ),

        if (isWide)
          Positioned(
            bottom: 108,
            left: 14,
            child: _buildLegend(isDark),
          ),

        // Kompas — kiri bawah
        Positioned(
          bottom: 12,
          left: 14,
          child: _buildCompass(isDark),
        ),

        Positioned(
          bottom: 12,
          right: 12,
          child: _buildResetBtn(isDark),
        ),
      ],
    );
  }

  // ── Marker dengan pulse animation ─────────────────────────────────────────
  Widget _buildMarker(RoomModel room) {
    final bool isSelected = selectedZone?.code == room.code;
    // Ukuran dasar marker — sedikit lebih besar dari sebelumnya
    const double baseSize   = 36.0;
    const double selectSize = 46.0;
    final double size = isSelected ? selectSize : baseSize;

    final markerWidget = GestureDetector(
      onTap: () => _showDetail(room),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutBack,
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: room.color,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: isSelected ? 3.5 : 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? room.color.withValues(alpha: 0.6)
                  : Colors.black.withValues(alpha: 0.3),
              blurRadius: isSelected ? 16 : 5,
              spreadRadius: isSelected ? 2 : 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            room.code,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: isSelected ? 10.5 : 8.5,
            ),
          ),
        ),
      ),
    );

    // Kalau selected, wrap dengan pulse ring
    if (isSelected) {
      // Ukuran total area termasuk pulse ring
      const double pulseArea = selectSize + 36;
      return Positioned(
        // Posisikan agar pusat pulse tepat di koordinat room
        left: (room.xRatio * originalWidth) - pulseArea / 2,
        top:  (room.yRatio * originalHeight) - pulseArea / 2,
        child: SizedBox(
          width: pulseArea,
          height: pulseArea,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Ring 1 — lebih besar, fase awal
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (context, child) {
                  final t = _pulseAnim.value;
                  return Opacity(
                    opacity: (1 - t).clamp(0.0, 0.5),
                    child: Container(
                      width:  selectSize + 4 + t * 32,
                      height: selectSize + 4 + t * 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: room.color,
                          width: 2.5,
                        ),
                      ),
                    ),
                  );
                },
              ),
              // Ring 2 — delay setengah siklus untuk efek berkelanjutan
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (context, child) {
                  final t = ((_pulseAnim.value + 0.5) % 1.0);
                  return Opacity(
                    opacity: (1 - t).clamp(0.0, 0.45),
                    child: Container(
                      width:  selectSize + 4 + t * 32,
                      height: selectSize + 4 + t * 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: room.color.withValues(alpha: 0.7),
                          width: 2.0,
                        ),
                      ),
                    ),
                  );
                },
              ),
              // Marker itu sendiri
              markerWidget,
            ],
          ),
        ),
      );
    }

    return Positioned(
      left: (room.xRatio * originalWidth) - size / 2,
      top:  (room.yRatio * originalHeight) - size / 2,
      child: markerWidget,
    );
  }

  // ── Floor selector vertikal ────────────────────────────────────────────────
  Widget _buildFloorSelector(bool isDark) {
    final bg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final activeColor = AppColors.primary;
    final inactiveText = isDark ? Colors.white54 : Colors.black45;

    // Urutan tampilan dari atas: lantai tertinggi dulu
    final floors = [3, 2, 1];

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: floors.map((floor) {
          final bool active = currentFloor == floor;
          final label = floorLabelShort(floor); // "Dasar", "Lt. 1", "Lt. 2"
          // Pisah jadi dua baris: prefix & angka/teks
          final bool isDasar = floor == 1;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 3),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  currentFloor = floor;
                  selectedZone = null;
                  _transformController.value = Matrix4.identity();
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: isDasar ? 42 : 38,
                decoration: BoxDecoration(
                  color: active ? activeColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: active
                      ? null
                      : Border.all(
                          color: isDark ? Colors.white12 : Colors.black12),
                ),
                child: Center(
                  child: isDasar
                      ? Text(
                          'Dasar',
                          style: TextStyle(
                            color: active ? Colors.white : inactiveText,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            height: 1.0,
                          ),
                          textAlign: TextAlign.center,
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Lt.',
                              style: TextStyle(
                                color: active ? Colors.white60 : inactiveText,
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              label.replaceAll('Lt. ', ''),
                              style: TextStyle(
                                color: active ? Colors.white : inactiveText,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Legenda (wide only) ────────────────────────────────────────────────────
  Widget _buildLegend(bool isDark) {
    const items = [
      _LegendItem(RoomCategory.koleksi,   RoomColors.koleksi),
      _LegendItem(RoomCategory.kantor,    RoomColors.kantor),
      _LegendItem(RoomCategory.pertemuan, RoomColors.pertemuan),
      _LegendItem(RoomCategory.loker,     RoomColors.loker),
      _LegendItem(RoomCategory.cafetaria, RoomColors.cafetaria),
    ];
    final bg = isDark
        ? const Color(0xFF1E293B).withValues(alpha: 0.95)
        : Colors.white.withValues(alpha: 0.95);
    final textColor  = isDark ? Colors.white60 : Colors.black54;
    final titleColor = isDark ? Colors.white   : Colors.black87;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_outline_rounded, size: 11, color: titleColor),
              const SizedBox(width: 4),
              Text('Legenda',
                  style: TextStyle(
                      color: titleColor, fontWeight: FontWeight.w700, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 6),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                        color: item.color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(RoomColors.labelFromCategory(item.category),
                      style: TextStyle(color: textColor, fontSize: 10)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Reset zoom button ──────────────────────────────────────────────────────
  Widget _buildResetBtn(bool isDark) {
    return FloatingActionButton.small(
      heroTag: 'resetZoom',
      tooltip: 'Reset Tampilan',
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      foregroundColor: isDark ? Colors.white70 : Colors.black54,
      elevation: 2,
      onPressed: () {
        _flyAnim?.stop();
        _transformController.value = Matrix4.identity();
      },
      child: const Icon(Icons.center_focus_strong_rounded, size: 19),
    );
  }

  // ── Kompas arah mata angin ─────────────────────────────────────────────────
  Widget _buildCompass(bool isDark) {
    final bg = isDark
        ? const Color(0xFF1E293B).withValues(alpha: 0.92)
        : Colors.white.withValues(alpha: 0.95);
    final shadow = isDark ? Colors.black45 : Colors.black12;

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: shadow, blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: CustomPaint(
        painter: _CompassPainter(
          primaryColor: AppColors.primary,
          isDark: isDark,
        ),
      ),
    );
  }

  // ── Panel keterangan ruangan ───────────────────────────────────────────────
  Widget _buildRoomPanel(bool isDark, {required bool isWide}) {
    final rooms        = currentFloorRooms;
    final bg           = isDark ? const Color(0xFF1E293B) : Colors.white;
    final headerBg     = isDark ? AppColors.darkHeader    : AppColors.primary;
    final textPrimary  = isDark ? Colors.white            : Colors.black87;
    final textSec      = isDark ? Colors.white60          : Colors.black45;
    final dividerColor = isDark
        ? Colors.white10
        : Colors.black.withValues(alpha: 0.06);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border(
          top: isWide
              ? BorderSide.none
              : BorderSide(
                  color: isDark
                      ? Colors.white10
                      : Colors.black.withValues(alpha: 0.08)),
          left: isWide
              ? BorderSide(
                  color: isDark
                      ? Colors.white10
                      : Colors.black.withValues(alpha: 0.08))
              : BorderSide.none,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
            color: headerBg,
            child: Row(
              children: [
                const Icon(Icons.list_alt_rounded,
                    color: Colors.white70, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ruangan — ${floorLabelFull(currentFloor)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _togglePanel,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.close_rounded,
                        color: Colors.white, size: 15),
                  ),
                ),
              ],
            ),
          ),

          if (!isWide) _buildLegendRow(isDark),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: 8),
              itemCount: rooms.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: dividerColor, indent: 14),
              itemBuilder: (context, index) {
                final room  = rooms[index];
                final isSel = selectedZone?.code == room.code;

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showDetail(room),
                    splashColor: room.color.withValues(alpha: 0.1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSel
                            ? room.color.withValues(alpha: 0.08)
                            : Colors.transparent,
                        border: Border(
                          left: BorderSide(
                            color: isSel ? room.color : Colors.transparent,
                            width: 3.5,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 22,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: room.color,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              room.code,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              room.name,
                              style: TextStyle(
                                color: isSel ? textPrimary : textSec,
                                fontSize: 12.5,
                                fontWeight: isSel
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 17,
                            color: isSel
                                ? room.color
                                : (isDark ? Colors.white24 : Colors.black26),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Legenda horizontal (mobile panel) ────────────────────────────────────
  Widget _buildLegendRow(bool isDark) {
    const items = [
      _LegendItem(RoomCategory.koleksi,   RoomColors.koleksi),
      _LegendItem(RoomCategory.kantor,    RoomColors.kantor),
      _LegendItem(RoomCategory.pertemuan, RoomColors.pertemuan),
      _LegendItem(RoomCategory.loker,     RoomColors.loker),
      _LegendItem(RoomCategory.cafetaria, RoomColors.cafetaria),
    ];
    final bg        = isDark
        ? const Color(0xFF0F172A).withValues(alpha: 0.6)
        : const Color(0xFFF0F4FF);
    final textColor = isDark ? Colors.white54 : Colors.black45;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      color: bg,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                        color: item.color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    RoomColors.labelFromCategory(item.category),
                    style: TextStyle(fontSize: 10, color: textColor),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── Error placeholder ──────────────────────────────────────────────────────
  Widget _buildErrorPlaceholder(bool isDark) {
    return Container(
      width: originalWidth,
      height: originalHeight,
      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEEF2F7),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image_rounded,
                color: isDark ? Colors.white30 : Colors.black26, size: 50),
            const SizedBox(height: 12),
            Text(
              'Gambar tidak ditemukan',
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.black45,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Pastikan file gambar ${floorLabelFull(currentFloor)} ada di assets/images/',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white38 : Colors.black38,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem {
  final RoomCategory category;
  final Color color;
  const _LegendItem(this.category, this.color);
}

// ── Compass CustomPainter ─────────────────────────────────────────────────────
class _CompassPainter extends CustomPainter {
  final Color primaryColor;
  final bool isDark;

  const _CompassPainter({required this.primaryColor, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // ── Lingkaran luar tipis ──────────────────────────────────────────────
    final ringPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, radius - 2, ringPaint);

    // ── Titik tengah ──────────────────────────────────────────────────────
    final dotPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 3, dotPaint);

    // ── 4 garis tick arah ─────────────────────────────────────────────────
    final tickPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withValues(alpha: 0.15)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    for (final angle in [0.0, 90.0, 180.0, 270.0]) {
      final rad = _deg2rad(angle - 90);
      final inner = Offset(
        center.dx + (radius * 0.45) * math.cos(rad),
        center.dy + (radius * 0.45) * math.sin(rad),
      );
      final outer = Offset(
        center.dx + (radius * 0.72) * math.cos(rad),
        center.dy + (radius * 0.72) * math.sin(rad),
      );
      canvas.drawLine(inner, outer, tickPaint);
    }

    // ── Panah Utara (merah) — di BAWAH peta ─────────────────────────────
    _drawArrow(
      canvas: canvas,
      center: center,
      angleDeg: 90, // bawah = utara (sesuai orientasi peta)
      length: radius * 0.52,
      tipWidth: radius * 0.18,
      color: primaryColor,
      shadow: true,
    );

    // ── Panah Selatan (abu/gelap) — di ATAS peta ─────────────────────────
    _drawArrow(
      canvas: canvas,
      center: center,
      angleDeg: -90, // atas = selatan
      length: radius * 0.42,
      tipWidth: radius * 0.14,
      color: isDark
          ? Colors.white.withValues(alpha: 0.35)
          : Colors.black.withValues(alpha: 0.2),
      shadow: false,
    );

    // ── Label U / S / T / B ───────────────────────────────────────────────
    final labels = {
       90.0: 'U',   // Utara — bawah
      -90.0: 'S',   // Selatan — atas
      180.0: 'T',   // Timur — kiri
        0.0: 'B',   // Barat — kanan
    };

    labels.forEach((angleDeg, label) {
      final isNorth = angleDeg == 90.0;
      final rad = _deg2rad(angleDeg);
      final pos = Offset(
        center.dx + (radius * 0.82) * math.cos(rad),
        center.dy + (radius * 0.82) * math.sin(rad),
      );

      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: isNorth
                ? primaryColor
                : (isDark
                    ? Colors.white.withValues(alpha: 0.55)
                    : Colors.black.withValues(alpha: 0.45)),
            fontSize: isNorth ? 11.0 : 9.0,
            fontWeight: isNorth ? FontWeight.w800 : FontWeight.w600,
            height: 1.0,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(
        canvas,
        pos - Offset(tp.width / 2, tp.height / 2),
      );
    });
  }

  void _drawArrow({
    required Canvas canvas,
    required Offset center,
    required double angleDeg,
    required double length,
    required double tipWidth,
    required Color color,
    required bool shadow,
  }) {
    final rad = _deg2rad(angleDeg);
    final tip = Offset(
      center.dx + length * math.cos(rad),
      center.dy + length * math.sin(rad),
    );
    final base = Offset(
      center.dx - (length * 0.15) * math.cos(rad),
      center.dy - (length * 0.15) * math.sin(rad),
    );
    final perp = Offset(-math.sin(rad), math.cos(rad));
    final left  = base + perp * tipWidth;
    final right = base - perp * tipWidth;

    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(left.dx, left.dy)
      ..lineTo(center.dx, center.dy)
      ..lineTo(right.dx, right.dy)
      ..close();

    if (shadow) {
      canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }

    canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.fill);
  }

  double _deg2rad(double deg) => deg * (math.pi / 180.0);

  @override
  bool shouldRepaint(_CompassPainter old) =>
      old.primaryColor != primaryColor || old.isDark != isDark;
}

