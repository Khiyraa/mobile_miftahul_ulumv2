import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mobile_miftahul_ulumv2/core/theme/app_theme.dart';
import 'package:mobile_miftahul_ulumv2/models/faq_model.dart';
import 'package:mobile_miftahul_ulumv2/services/api_service.dart';
import 'package:mobile_miftahul_ulumv2/screens/chat_screen.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> with TickerProviderStateMixin {
  // ── State ────────────────────────────────────────────────────────────────
  late Future<FaqResponse> _faqFuture;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _activeKategori = 'Semua';
  int? _expandedIndex;

  // ── Controllers animasi ──────────────────────────────────────────────────
  late final AnimationController _headerAnim;

  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..forward();
    _loadFaqs();
    _searchCtrl.addListener(() {
      setState(() {
        _searchQuery = _searchCtrl.text;
        _expandedIndex = null;
      });
    });
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Data ─────────────────────────────────────────────────────────────────
  void _loadFaqs() {
    setState(() {
      _faqFuture = ApiService().getFaqs();
      _expandedIndex = null;
    });
  }

  List<FaqModel> _applyFilters(List<FaqModel> all) {
    return all.where((f) {
      // Filter kategori
      final matchKat = _activeKategori == 'Semua' || f.kategori == _activeKategori;

      // Filter pencarian
      final q = _searchQuery.toLowerCase().trim();
      final matchSearch = q.isEmpty ||
          f.pertanyaan.toLowerCase().contains(q) ||
          f.jawaban.toLowerCase().contains(q) ||
          f.kategori.toLowerCase().contains(q);

      return matchKat && matchSearch;
    }).toList();
  }

  // ── UI ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 28),
                _buildHeroSection(),
                const SizedBox(height: 20),
                _buildSearchBar(),
                const SizedBox(height: 24),
                _buildFaqBody(),
                const SizedBox(height: 36),
                _buildContactCard(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── App Bar ──────────────────────────────────────────────────────────────
  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppTheme.surface.withValues(alpha: 0.85),
      elevation: 0,
      scrolledUnderElevation: 0,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(color: Colors.transparent),
        ),
      ),
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.help_outline_rounded, color: AppTheme.primary, size: 20),
          ),
          const SizedBox(width: 10),
          Text(
            'FAQ',
            style: AppTheme.headline.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              color: AppTheme.primary,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: AppTheme.primary),
          tooltip: 'Muat ulang',
          onPressed: _loadFaqs,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // ── Hero ─────────────────────────────────────────────────────────────────
  Widget _buildHeroSection() {
    return FadeTransition(
      opacity: _headerAnim,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
          CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'BANTUAN & INFORMASI',
                style: AppTheme.label.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: AppTheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Ada yang bisa\nkami bantu?',
              style: AppTheme.headline.copyWith(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                height: 1.1,
                letterSpacing: -1.0,
                color: AppTheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Temukan jawaban atas pertanyaan umum seputar Sistem Monitoring Santri.',
              style: AppTheme.body.copyWith(
                fontSize: 14,
                color: AppTheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Search Bar ───────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineVariant, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.onSurface.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchCtrl,
        style: AppTheme.body.copyWith(fontSize: 14, color: AppTheme.onSurface),
        decoration: InputDecoration(
          hintText: 'Cari pertanyaan atau topik…',
          hintStyle: AppTheme.body.copyWith(fontSize: 14, color: AppTheme.outline),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 14, right: 8),
            child: Icon(Icons.search_rounded, color: AppTheme.outline, size: 20),
          ),
          prefixIconConstraints: const BoxConstraints(),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppTheme.outline, size: 18),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
        ),
      ),
    );
  }

  // ── FAQ Body ─────────────────────────────────────────────────────────────
  Widget _buildFaqBody() {
    return FutureBuilder<FaqResponse>(
      future: _faqFuture,
      builder: (context, snapshot) {
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        // Error — tampilkan pesan + tombol retry
        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        final response = snapshot.data;
        final allFaqs = response?.data ?? [];

        // Filter lokal (pencarian + kategori)
        final filtered = _applyFilters(allFaqs);
        final kategoris = ['Semua', ...?response?.kategoris];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chip kategori (hanya jika ada data)
            if (allFaqs.isNotEmpty) ...[
              _buildKategoriChips(kategoris),
              const SizedBox(height: 20),
            ],

            // Judul seksi
            Row(
              children: [
                Expanded(
                  child: Text(
                    _searchQuery.isNotEmpty
                        ? 'Hasil pencarian "${_searchQuery}"'
                        : _activeKategori == 'Semua'
                            ? 'Semua Pertanyaan'
                            : _activeKategori,
                    style: AppTheme.headline.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.onSurface,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${filtered.length} FAQ',
                    style: AppTheme.label.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Kosong
            if (filtered.isEmpty) _buildEmptyState() else _buildAccordionList(filtered),
          ],
        );
      },
    );
  }

  // ── Kategori Chips ───────────────────────────────────────────────────────
  Widget _buildKategoriChips(List<String> kategoris) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: kategoris.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final kat = kategoris[i];
          final isActive = _activeKategori == kat;
          return GestureDetector(
            onTap: () => setState(() {
              _activeKategori = kat;
              _expandedIndex = null;
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? AppTheme.primary : AppTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? AppTheme.primary : AppTheme.outlineVariant,
                  width: 1.5,
                ),
              ),
              child: Text(
                kat,
                style: AppTheme.label.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isActive ? AppTheme.onPrimary : AppTheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Accordion List ───────────────────────────────────────────────────────
  Widget _buildAccordionList(List<FaqModel> faqs) {
    return Column(
      children: faqs.asMap().entries.map((entry) {
        final index = entry.key;
        final faq = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildAccordionItem(index: index, faq: faq),
        );
      }).toList(),
    );
  }

  Widget _buildAccordionItem({required int index, required FaqModel faq}) {
    final isExpanded = _expandedIndex == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isExpanded ? AppTheme.surfaceContainerLowest : AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isExpanded ? AppTheme.primary.withValues(alpha: 0.25) : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: isExpanded
            ? [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: isExpanded,
          onExpansionChanged: (expanded) {
            setState(() => _expandedIndex = expanded ? index : null);
          },
          tilePadding: const EdgeInsets.fromLTRB(18, 6, 14, 6),
          childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          shape: const RoundedRectangleBorder(side: BorderSide.none),
          collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
          // Ikon custom
          trailing: AnimatedRotation(
            turns: isExpanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 250),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: isExpanded
                    ? AppTheme.primary.withValues(alpha: 0.1)
                    : AppTheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: isExpanded ? AppTheme.primary : AppTheme.outline,
              ),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge kategori
              Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _kategoriColor(faq.kategori).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  faq.kategori.toUpperCase(),
                  style: AppTheme.label.copyWith(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: _kategoriColor(faq.kategori),
                  ),
                ),
              ),
              // Pertanyaan
              Text(
                faq.pertanyaan,
                style: AppTheme.headline.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isExpanded ? AppTheme.primary : AppTheme.onSurface,
                  height: 1.4,
                ),
              ),
            ],
          ),
          children: [
            // Divider tipis
            Container(
              height: 1,
              margin: const EdgeInsets.only(bottom: 14),
              color: AppTheme.outlineVariant.withValues(alpha: 0.5),
            ),
            // Jawaban
            Text(
              faq.jawaban,
              style: AppTheme.body.copyWith(
                fontSize: 14,
                color: AppTheme.onSurfaceVariant,
                height: 1.65,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── State Widgets ────────────────────────────────────────────────────────
  Widget _buildLoadingState() {
    return Column(
      children: List.generate(
        4,
        (i) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _SkeletonCard(delay: i * 80),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.errorContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.wifi_off_rounded, color: AppTheme.error, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat FAQ',
              style: AppTheme.headline.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Periksa koneksi internet lalu coba lagi.',
              style: AppTheme.body.copyWith(fontSize: 13, color: AppTheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _loadFaqs,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba Lagi'),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(Icons.search_off_rounded, color: AppTheme.outline, size: 36),
            ),
            const SizedBox(height: 14),
            Text(
              _searchQuery.isNotEmpty ? 'Tidak ditemukan' : 'Belum ada FAQ',
              style: AppTheme.headline.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Coba kata kunci lain atau ubah filter kategori.'
                  : 'FAQ untuk kategori ini belum tersedia.',
              style: AppTheme.body.copyWith(fontSize: 13, color: AppTheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Contact Card ─────────────────────────────────────────────────────────
  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: -30,
            right: -20,
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 110,
              color: AppTheme.onPrimary.withValues(alpha: 0.08),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.onPrimary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.support_agent_rounded, color: AppTheme.onPrimary, size: 24),
              ),
              const SizedBox(height: 14),
              Text(
                'Masih butuh bantuan?',
                style: AppTheme.headline.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.onPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tim kami siap membantu Anda kapan saja.',
                style: AppTheme.body.copyWith(
                  fontSize: 13,
                  color: AppTheme.onPrimary.withValues(alpha: 0.75),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChatScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Hubungi Kami',
                        style: AppTheme.headline.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward_rounded, size: 16, color: AppTheme.primary),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Color _kategoriColor(String kategori) {
    final palette = [
      AppTheme.primary,
      AppTheme.secondary,
      AppTheme.tertiary,
      const Color(0xFF1565C0), // blue
      const Color(0xFFB45309), // amber
      const Color(0xFF7B3F00), // brown
    ];
    int hash = 0;
    for (final c in kategori.codeUnits) {
      hash = c + ((hash << 5) - hash);
    }
    return palette[hash.abs() % palette.length];
  }
}

// ── Skeleton Loading Card ─────────────────────────────────────────────────
class _SkeletonCard extends StatefulWidget {
  final int delay;
  const _SkeletonCard({required this.delay});

  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        height: 86,
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 60, height: 10, decoration: BoxDecoration(color: AppTheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(6))),
            const SizedBox(height: 10),
            Container(width: double.infinity, height: 12, decoration: BoxDecoration(color: AppTheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(6))),
            const SizedBox(height: 6),
            Container(width: 180, height: 12, decoration: BoxDecoration(color: AppTheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(6))),
          ],
        ),
      ),
    );
  }
}
