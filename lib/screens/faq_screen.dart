import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mobile_miftahul_ulumv2/core/theme/app_theme.dart';
import 'package:mobile_miftahul_ulumv2/models/faq_model.dart';
import 'package:mobile_miftahul_ulumv2/services/api_service.dart';
import 'package:mobile_miftahul_ulumv2/widgets/animated_press_button.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  // To track which accordion is open
  int? _expandedIndex;
  late Future<List<FaqModel>> _faqFuture;

  // Fallback data lokal saat API belum tersedia
  final List<FaqModel> _fallbackFaqs = [
    FaqModel(
      id: '1',
      category: 'akademik',
      question: "How do I track my child's daily prayer attendance?",
      answer: "You can view the daily prayer logs in the Prayer tab located in the bottom navigation bar. Each prayer is timestamped and verified by the local Musyrif.",
    ),
    FaqModel(
      id: '2',
      category: 'administrasi',
      question: "What is the procedure for weekend leave?",
      answer: "Weekend leave requests must be submitted through the 'Permissions' section under the 'More' menu at least 48 hours in advance. Approval will be granted based on the student's current disciplinary standing and academic progress.",
    ),
    FaqModel(
      id: '3',
      category: 'kegiatan',
      question: "Can I communicate directly with the Musyrif?",
      answer: "Yes, use the Chat tab to start a secure conversation with your child's supervisor.",
    ),
    FaqModel(
      id: '4',
      category: 'akademik',
      question: "How often are academic reports updated?",
      answer: "Academic grades and memorization (Tahfizh) progress are updated every Friday after the final session of the week.",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _faqFuture = ApiService().getFaqList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: CustomScrollView(
        slivers: [
          // TopAppBar
          SliverAppBar(
            pinned: true,
            backgroundColor: AppTheme.surface.withValues(alpha: 0.8),
            elevation: 0,
            scrolledUnderElevation: 0,
            flexibleSpace: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(color: Colors.transparent),
              ),
            ),
            title: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.primaryContainer.withValues(alpha: 0.2), width: 2),
                  ),
                  child: const CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuAcfGoGbxfjZ1k9XgXAP4gCAZMIEYnf0mztt4ZKWyG97qqo5nGiqQWL4SLMMpV84epf3GhzajQBinfp5M6NDvSnk74Z9J23L3EMCJ5kCwrS954uRXFwOrsO72f6pHCncHTXvJF6N3PSAPCBEarrQiSZlPqJILV8dHoSoMJyXREPGdZPV-1OBc8d1PwZ6ZMJ_VrXDLjv0bmQ0PIpHA5unDS_XxrLhwcelxr5EetU2fbPHCLlcov6eMvEnxVaoS41v6RvxdZmXiF9yLx5',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Miftahul Ulum Kalisat',
                  style: AppTheme.headline.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: -1,
                    color: AppTheme.primary,
                  ),
                )
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none, color: AppTheme.primary),
                style: IconButton.styleFrom(
                  hoverColor: AppTheme.surfaceContainerLow,
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Main Content
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                
                // Hero Section
                Text(
                  'How can we help?',
                  style: AppTheme.headline.copyWith(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.0,
                    color: AppTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Find answers to common questions about the Santri Monitoring System.',
                  style: AppTheme.body.copyWith(
                    fontSize: 18,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 48),

                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search for topics...',
                      hintStyle: AppTheme.body.copyWith(color: AppTheme.outline),
                      prefixIcon: const Icon(Icons.search, color: AppTheme.outline),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    style: AppTheme.body.copyWith(color: AppTheme.onSurface),
                  ),
                ),
                const SizedBox(height: 40),

                // FAQ Categories Bento
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.account_balance, color: AppTheme.primary, size: 32),
                            const SizedBox(height: 32),
                            Text(
                              'Academic Policies',
                              style: AppTheme.headline.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.onSecondaryContainer,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.payments_outlined, color: AppTheme.outline, size: 32),
                            const SizedBox(height: 32),
                            Text(
                              'Tuition & Fees',
                              style: AppTheme.headline.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.onSurface,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),

                // Accordion Section — FutureBuilder
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'Common Questions',
                    style: AppTheme.headline.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                FutureBuilder<List<FaqModel>>(
                  future: _faqFuture,
                  builder: (context, snapshot) {
                    // Tentukan data FAQ yang akan ditampilkan
                    List<FaqModel> faqList;

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      faqList = snapshot.data!;
                    } else {
                      // Gunakan fallback lokal jika API belum terhubung
                      faqList = _fallbackFaqs;
                    }

                    return Column(
                      children: faqList.asMap().entries.map((entry) {
                        final index = entry.key;
                        final faq = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildAccordionItem(
                            index: index,
                            title: faq.question,
                            content: faq.answer,
                            category: faq.category,
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 48),

                // Contact Support Card
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.primaryContainer],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        bottom: -40,
                        right: -40,
                        child: Icon(
                          Icons.stars,
                          size: 120,
                          color: AppTheme.onPrimary.withValues(alpha: 0.1),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Still need help?',
                            style: AppTheme.headline.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.onPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Our support team is available 24/7 for critical inquiries.',
                            style: AppTheme.body.copyWith(
                              color: AppTheme.onPrimary.withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(height: 24),
                          AnimatedPressButton(
                            onPressed: () {},
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(32),
                              ),
                              child: Text(
                                'Contact Us',
                                style: AppTheme.headline.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccordionItem({
    required int index,
    required String title,
    required String content,
    String? category,
  }) {
    bool isExpanded = _expandedIndex == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isExpanded ? AppTheme.surfaceContainerLowest : AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: isExpanded ? Border.all(color: AppTheme.surfaceContainerHigh) : null,
        boxShadow: isExpanded ? [
          BoxShadow(
            color: const Color(0xFF191C1B).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ] : null,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: isExpanded,
          onExpansionChanged: (expanded) {
            setState(() {
              _expandedIndex = expanded ? index : null;
            });
          },
          tilePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          childrenPadding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (category != null && category.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      category.toUpperCase(),
                      style: AppTheme.label.copyWith(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ),
              Text(
                title,
                style: AppTheme.headline.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurface,
                ),
              ),
            ],
          ),
          iconColor: AppTheme.primary,
          collapsedIconColor: AppTheme.outline,
          children: [
            if (isExpanded) const Divider(color: AppTheme.surfaceContainerLow, height: 1),
            if (isExpanded) const SizedBox(height: 16),
            Text(
              content,
              style: AppTheme.body.copyWith(
                color: AppTheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
