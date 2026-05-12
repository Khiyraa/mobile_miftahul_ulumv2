import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mobile_miftahul_ulumv2/core/theme/app_theme.dart';

class JadwalShalatScreen extends StatefulWidget {
  const JadwalShalatScreen({super.key});

  @override
  State<JadwalShalatScreen> createState() => _JadwalShalatScreenState();
}

class _JadwalShalatScreenState extends State<JadwalShalatScreen> {
  Map<String, dynamic>? _prayerTimes;
  bool _isLoading = true;
  String _activePrayer = '';
  String _nextPrayerName = '';
  String _nextPrayerTime = '';
  Duration _timeUntilNext = Duration.zero;

  @override
  void initState() {
    super.initState();
    _fetchPrayerTimes();
  }

  Future<void> _fetchPrayerTimes() async {
    try {
      final response = await http.get(Uri.parse(
          'https://api.aladhan.com/v1/timingsByCity?city=Jember&country=Indonesia&method=2'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _prayerTimes = data['data']['timings'];
            _isLoading = false;
            _calculateNextPrayer();
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _calculateNextPrayer() {
    if (_prayerTimes == null) return;

    final now = DateTime.now();
    final timeFormat = DateFormat("HH:mm");
    
    // Ordered list of prayers
    final prayers = [
      {'name': 'Subuh', 'key': 'Fajr'},
      {'name': 'Dzuhur', 'key': 'Dhuhr'},
      {'name': 'Ashar', 'key': 'Asr'},
      {'name': 'Maghrib', 'key': 'Maghrib'},
      {'name': 'Isya', 'key': 'Isha'},
    ];

    DateTime? nextTime;
    String nextName = '';
    String activeName = '';

    for (int i = 0; i < prayers.length; i++) {
      final prayer = prayers[i];
      final timeString = _prayerTimes![prayer['key']];
      
      final parsedTime = timeFormat.parse(timeString);
      final prayerDateTime = DateTime(now.year, now.month, now.day, parsedTime.hour, parsedTime.minute);

      if (now.isBefore(prayerDateTime)) {
        nextTime = prayerDateTime;
        nextName = prayer['name']!;
        // Active prayer is the one before the next one (or Isya if Subuh is next)
        activeName = i > 0 ? prayers[i-1]['name']! : 'Isya';
        break;
      }
    }

    // If all prayers today have passed, next is Subuh tomorrow
    if (nextTime == null) {
      final timeString = _prayerTimes!['Fajr'];
      final parsedTime = timeFormat.parse(timeString);
      nextTime = DateTime(now.year, now.month, now.day + 1, parsedTime.hour, parsedTime.minute);
      nextName = 'Subuh';
      activeName = 'Isya';
    }

    setState(() {
      _nextPrayerName = nextName;
      _nextPrayerTime = _prayerTimes![prayers.firstWhere((p) => p['name'] == nextName)['key']];
      _activePrayer = activeName;
      _timeUntilNext = nextTime!.difference(now);
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateDisplay = DateFormat('dd MMMM yyyy').format(now);
    final timeDisplay = DateFormat('HH:mm').format(now);
    final dayDisplay = DateFormat('EEEE').format(now);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // TopAppBar
          SliverAppBar(
            pinned: true,
            backgroundColor: AppTheme.background.withValues(alpha: 0.8),
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
                    backgroundImage: AssetImage('assets/images/logo.png'),
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
                
                // Date Header Section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dayDisplay.toUpperCase(),
                          style: AppTheme.label.copyWith(
                            fontSize: 12,
                            letterSpacing: 2.4, // tracking-[0.2em]
                            color: AppTheme.outline,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Jadwal Shalat',
                          style: AppTheme.headline.copyWith(
                            fontSize: 28, // text-3xl
                            fontWeight: FontWeight.w800, // font-extrabold
                            letterSpacing: -0.5,
                            color: AppTheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateDisplay, // Mock Hijri date: 12 Syakban 1445 H
                          style: AppTheme.body.copyWith(
                            fontSize: 14,
                            color: AppTheme.outline,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          timeDisplay,
                          style: AppTheme.headline.copyWith(
                            fontSize: 20, // text-xl
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                        Text(
                          'CURRENT TIME',
                          style: AppTheme.label.copyWith(
                            fontSize: 10,
                            letterSpacing: 1.0,
                            color: AppTheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Main Prayer Card (Next Prayer Focal)
                Container(
                  clipBehavior: Clip.antiAlias,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(32), // rounded-[2rem]
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.2),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Blur circle
                      Positioned(
                        top: -80,
                        right: -80,
                        child: Container(
                          width: 192,
                          height: 192,
                          decoration: BoxDecoration(
                            color: AppTheme.onPrimary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      // Water drop icon decoration
                      Positioned(
                        bottom: -40,
                        right: -20,
                        child: Icon(
                          Icons.water_drop,
                          size: 120,
                          color: AppTheme.onPrimary.withValues(alpha: 0.2),
                        ),
                      ),
                      
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome, size: 14, color: AppTheme.onPrimary),
                              const SizedBox(width: 8),
                              Text(
                                'UPCOMING PRAYER',
                                style: AppTheme.label.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                  color: AppTheme.onPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _isLoading ? '...' : _nextPrayerName,
                            style: AppTheme.headline.copyWith(
                              fontSize: 48, // text-5xl
                              fontWeight: FontWeight.w900, // font-black
                              letterSpacing: -1.5,
                              color: AppTheme.onPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                _isLoading ? '--:--' : _nextPrayerTime,
                                style: AppTheme.headline.copyWith(
                                  fontSize: 24, // text-2xl
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.onPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isLoading 
                                    ? '' 
                                    : 'In ${_timeUntilNext.inHours}h ${_timeUntilNext.inMinutes % 60}m',
                                style: AppTheme.body.copyWith(
                                  fontSize: 14,
                                  color: AppTheme.onPrimary.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                // Prayer List Grid
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_prayerTimes == null)
                  const Center(child: Text('Gagal memuat data jadwal shalat.', style: TextStyle(color: Colors.grey)))
                else
                  Column(
                    children: [
                      _buildPrayerItem(
                        name: 'Subuh',
                        time: _prayerTimes!['Fajr'],
                        icon: Icons.brightness_3,
                      ),
                      _buildPrayerItem(
                        name: 'Dzuhur',
                        time: _prayerTimes!['Dhuhr'],
                        icon: Icons.wb_sunny,
                      ),
                      _buildPrayerItem(
                        name: 'Ashar',
                        time: _prayerTimes!['Asr'],
                        icon: Icons.cloud,
                      ),
                      _buildPrayerItem(
                        name: 'Maghrib',
                        time: _prayerTimes!['Maghrib'],
                        icon: Icons.wb_twilight,
                      ),
                      _buildPrayerItem(
                        name: 'Isya',
                        time: _prayerTimes!['Isha'],
                        icon: Icons.bedtime,
                      ),
                    ],
                  ),
                  
                const SizedBox(height: 48),

                // Location Context Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: AppTheme.surfaceContainerHigh,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.location_on, color: AppTheme.primary, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CURRENT LOCATION',
                              style: AppTheme.label.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                color: AppTheme.outline,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Pesantren Miftahul Ulum Kalisat',
                              style: AppTheme.headline.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primary,
                          textStyle: AppTheme.body.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Text('Ubah'),
                      )
                    ],
                  ),
                )
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerItem({
    required String name,
    required String time,
    required IconData icon,
  }) {
    final isActive = _activePrayer == name;
    
    // Status text logic: "Active", "Done", or blank (future)
    String statusText = '';
    if (isActive) {
      statusText = 'ACTIVE';
    } else {
      // Very basic logic: if this is before the active prayer, it's done. 
      // This is imperfect but creates the visual effect needed for the UI replication.
      final ordered = ['Subuh', 'Dzuhur', 'Ashar', 'Maghrib', 'Isya'];
      int thisIndex = ordered.indexOf(name);
      int activeIndex = ordered.indexOf(_activePrayer);
      if (thisIndex <= activeIndex) {
         statusText = 'SELESAI';
      }
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isActive ? null : AppTheme.surfaceContainerLowest,
        gradient: isActive ? LinearGradient(
          colors: [
            AppTheme.primaryContainer.withValues(alpha: 0.08),
            AppTheme.primaryFixedDim.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ) : null,
        borderRadius: BorderRadius.circular(isActive ? 32 : 24),
        border: isActive ? Border.all(color: AppTheme.primaryContainer.withValues(alpha: 0.1), width: 2) : null,
        boxShadow: isActive ? [
          BoxShadow(
            color: AppTheme.primaryContainer.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 4,
          )
        ] : null,
      ),
      transform: isActive ? Matrix4.diagonal3Values(1.02, 1.02, 1.0) : Matrix4.identity(),
      transformAlignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isActive ? AppTheme.primaryContainer : AppTheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: isActive ? AppTheme.onPrimary : AppTheme.outline,
                ),
              ),
              const SizedBox(width: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTheme.headline.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isActive ? AppTheme.primary : AppTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: AppTheme.body.copyWith(
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w400,
                      color: isActive ? AppTheme.primary.withValues(alpha: 0.7) : AppTheme.outline,
                    ),
                  ),
                ],
              )
            ],
          ),
          Row(
            children: [
              if (statusText == 'DONE')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    statusText,
                    style: AppTheme.label.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: AppTheme.outline,
                    ),
                  ),
                )
              else if (statusText == 'ACTIVE')
                Row(
                  children: [
                    Container(
                      width: 8, height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      statusText,
                      style: AppTheme.label.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              if (statusText != 'ACTIVE') ...[
                const SizedBox(width: 12),
                Icon(Icons.chevron_right, color: AppTheme.outline.withValues(alpha: 0.4)),
              ]
            ],
          )
        ],
      ),
    );
  }
}
