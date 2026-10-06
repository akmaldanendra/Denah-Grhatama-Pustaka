import 'package:flutter/material.dart';
import '../main.dart';
import '../models/room_model.dart';
import '../data/room_data.dart';
import '../widgets/room_detail_sheet.dart';
import 'home_screen.dart';

class RoomListScreen extends StatefulWidget {
  const RoomListScreen({super.key});

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchCtrl = TextEditingController();
  late TabController _tabCtrl;

  // Filter aktif: null = semua kategori
  RoomCategory? _activeCategory;
  String _query = '';

  // Tab: 0 = semua lantai, 1/2/3 = per lantai
  static const _tabs = ['Semua', 'Lantai 1', 'Lantai 2', 'Lantai 3'];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
    _searchCtrl.addListener(() {
      setState(() => _query = _searchCtrl.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<RoomModel> get _filteredRooms {
    int? floorFilter;
    if (_tabCtrl.index > 0) floorFilter = _tabCtrl.index;

    return masterRoomsData.where((r) {
      final matchFloor = floorFilter == null || r.floor == floorFilter;
      final matchCat =
          _activeCategory == null || r.category == _activeCategory;
      final matchQuery = _query.isEmpty ||
          r.name.toLowerCase().contains(_query) ||
          r.code.toLowerCase().contains(_query) ||
          r.desc.toLowerCase().contains(_query);
      return matchFloor && matchCat && matchQuery;
    }).toList();
  }

  void _openDetail(BuildContext context, RoomModel room) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RoomDetailSheet(
        room: room,
        onShowOnMap: () => HomeScreen.goToMap(context, room),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appBarBg =
        isDark ? AppColors.darkHeader : AppColors.primary;
    final scaffoldBg =
        isDark ? const Color(0xFF0F172A) : const Color(0xFFF5F7FA);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: appBarBg,
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
                  'Daftar Ruangan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Grhatama Pustaka',
                  style: TextStyle(
                      fontSize: 9,
                      color: Colors.white60,
                      fontWeight: FontWeight.w400),
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
          const SizedBox(width: 4),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          labelStyle: const TextStyle(
              fontWeight: FontWeight.w700, fontSize: 13),
          unselectedLabelStyle: const TextStyle(fontSize: 13),
          onTap: (_) => setState(() {}),
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: Column(
        children: [
          // ── Search bar ───────────────────────────────────────────────────
          Container(
            color: isDark
                ? AppColors.darkHeader
                : AppColors.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                cursorColor: Colors.white70,
                decoration: InputDecoration(
                  hintText: 'Cari nama atau kode ruangan…',
                  hintStyle:
                      const TextStyle(color: Colors.white54, fontSize: 14),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: Colors.white60, size: 20),
                  suffixIcon: _query.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchCtrl.clear();
                            FocusScope.of(context).unfocus();
                          },
                          child: const Icon(Icons.close_rounded,
                              color: Colors.white54, size: 18),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          // ── Filter chip kategori ─────────────────────────────────────────
          Container(
            color: cardBg,
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _CategoryChip(
                    label: 'Semua',
                    isActive: _activeCategory == null,
                    color: isDark ? Colors.white54 : Colors.black54,
                    isDark: isDark,
                    onTap: () =>
                        setState(() => _activeCategory = null),
                  ),
                  const SizedBox(width: 8),
                  ...RoomCategory.values.map((cat) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _CategoryChip(
                          label: RoomColors.labelFromCategory(cat),
                          isActive: _activeCategory == cat,
                          color: RoomColors.fromCategory(cat),
                          isDark: isDark,
                          onTap: () => setState(() => _activeCategory =
                              _activeCategory == cat ? null : cat),
                        ),
                      )),
                ],
              ),
            ),
          ),

          // ── Divider + jumlah hasil ───────────────────────────────────────
          AnimatedBuilder(
            animation: _tabCtrl,
            builder: (context, child) {
              final count = _filteredRooms.length;
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                color: isDark
                    ? const Color(0xFF0F172A)
                    : const Color(0xFFF0F4FF),
                child: Row(
                  children: [
                    Icon(Icons.door_front_door_outlined,
                        size: 14,
                        color: isDark
                            ? Colors.white38
                            : Colors.black38),
                    const SizedBox(width: 6),
                    Text(
                      '$count ruangan ditemukan',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white38 : Colors.black38,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // ── Daftar ruangan ───────────────────────────────────────────────
          Expanded(
            child: AnimatedBuilder(
              animation: _tabCtrl,
              builder: (context, child) {
                final rooms = _filteredRooms;
                if (rooms.isEmpty) return _buildEmpty(isDark);
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
                  itemCount: rooms.length,
                  itemBuilder: (context, i) =>
                      _RoomCard(
                    room: rooms[i],
                    isDark: isDark,
                    onTap: () => _openDetail(context, rooms[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 56,
            color: isDark ? Colors.white24 : Colors.black26,
          ),
          const SizedBox(height: 14),
          Text(
            'Ruangan tidak ditemukan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Coba kata kunci atau filter lain',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Card tiap ruangan di daftar ───────────────────────────────────────────────
class _RoomCard extends StatelessWidget {
  final RoomModel room;
  final bool isDark;
  final VoidCallback onTap;

  const _RoomCard({
    required this.room,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textPrimary = isDark ? Colors.white : Colors.black87;
    final textSec = isDark ? Colors.white54 : Colors.black45;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        elevation: isDark ? 0 : 1.5,
        shadowColor: Colors.black.withValues(alpha: 0.07),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          splashColor: room.color.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Ikon kode
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: room.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      room.code,
                      style: TextStyle(
                        color: room.color,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Nama + kategori
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room.name,
                        style: TextStyle(
                          color: textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: room.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            RoomColors.labelFromCategory(room.category),
                            style: TextStyle(
                              color: textSec,
                              fontSize: 11.5,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.07)
                                  : Colors.black.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Lt. ${room.floor}',
                              style: TextStyle(
                                color: textSec,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: isDark ? Colors.white24 : Colors.black26,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Filter chip kategori ──────────────────────────────────────────────────────
class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isActive,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isActive
        ? color.withValues(alpha: 0.15)
        : (isDark
            ? Colors.white.withValues(alpha: 0.07)
            : Colors.black.withValues(alpha: 0.05));
    final border = isActive
        ? BorderSide(color: color.withValues(alpha: 0.5))
        : BorderSide(
            color: isDark
                ? Colors.white12
                : Colors.black.withValues(alpha: 0.1));
    final textColor = isActive
        ? color
        : (isDark ? Colors.white54 : Colors.black54);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.fromBorderSide(border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isActive) ...[
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight:
                    isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
