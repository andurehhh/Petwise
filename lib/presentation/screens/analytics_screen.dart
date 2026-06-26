import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petwise/data/models/activity_model.dart';
import 'package:petwise/providers/activity_provider.dart';
import 'package:provider/provider.dart';
import 'package:petwise/providers/analytics_provider.dart';
import 'package:petwise/providers/pet_provider.dart';
import 'package:petwise/providers/user_provider.dart';
import 'package:petwise/contracts/analytics/pet_activity_health_analytics_response.dart';
import 'package:petwise/contracts/analytics/user_dashboard_analytics_response.dart';
import 'package:petwise/contracts/analytics/activity_timeline_slot.dart';
import 'package:petwise/data/models/pet_model.dart';
import 'package:petwise/utils/pet_theme.dart';
import '../widgets/petwise_Navbar.dart';
import '../widgets/petwise_app_bar.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Pet? _selectedPet;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;
    final userId = context.read<UserProvider>().user?.id;
    final pets = context.read<PetProvider>().pets;
    final analytics = context.read<AnalyticsProvider>();
    if (userId != null) await analytics.loadUserAnalytics(userId);
    if (pets.isNotEmpty) {
      final pet = _selectedPet ?? pets.first;
      setState(() => _selectedPet = pet);
      await analytics.loadPetAnalytics(pet.id);
    }
  }

  Future<void> _selectPet(Pet pet) async {
    setState(() => _selectedPet = pet);
    await context.read<AnalyticsProvider>().loadPetAnalytics(pet.id);
  }

  @override
  Widget build(BuildContext context) {
    final analytics = context.watch<AnalyticsProvider>();
    final pets = context.watch<PetProvider>().pets;

    return Scaffold(
      backgroundColor: const Color(0xffF8F7F6),
      appBar: const PetWiseAppBar(),
      bottomNavigationBar: const PetwiseNavbar(navbarIndex: 1),
      body: Column(
        children: [
          _TabBar(controller: _tabController),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _OverviewTab(
                  analytics: analytics,
                  isLoading: analytics.isLoading,
                ),
                _PetTab(
                  analytics: analytics,
                  pets: pets,
                  selectedPet: _selectedPet,
                  onSelectPet: _selectPet,
                  isLoading: analytics.isLoading,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  final TabController controller;
  const _TabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analytics',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          TabBar(
            controller: controller,
            labelColor: const Color(0xFFF7A433),
            unselectedLabelColor: const Color(0xFF94A3B8),
            indicatorColor: const Color(0xFFF7A433),
            indicatorWeight: 3,
            labelStyle: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
            unselectedLabelStyle: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Per Pet'),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final AnalyticsProvider analytics;
  final bool isLoading;

  const _OverviewTab({required this.analytics, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    final data = analytics.userAnalytics;

    if (isLoading && data == null) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFF7A433)),
      );
    }

    if (analytics.error != null && data == null) {
      return _ErrorState(message: analytics.error!);
    }

    if (data == null) {
      return _EmptyState(label: 'No overview data yet');
    }

    return RefreshIndicator(
      color: const Color(0xFFF7A433),
      onRefresh: () async {
        final userId = context.read<UserProvider>().user?.id;
        if (userId != null) {
          await context.read<AnalyticsProvider>().loadUserAnalytics(userId);
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionLabel('At a Glance'),
            const SizedBox(height: 12),
            _StatGrid(data: data),
            const SizedBox(height: 28),
            _SectionLabel('Medical Compliance'),
            const SizedBox(height: 12),
            _ComplianceCard(rate: data.medicalComplianceRate),
            const SizedBox(height: 28),
            _SectionLabel('Health Events Breakdown'),
            const SizedBox(height: 12),
            _DistributionCard(
              distribution: data.healthEventTypeDistribution,
              emptyLabel: 'No health events recorded',
            ),
            const SizedBox(height: 28),
            _SectionLabel('Activity Completion'),
            const SizedBox(height: 12),
            _ActivityBarChart(activities: context.read<ActivityProvider>().activities),
            const SizedBox(height: 28),
            _SectionLabel('Activity Recurrence'),
            const SizedBox(height: 12),
            _DistributionCard(
              distribution: data.activityRecurrenceDistribution,
              emptyLabel: 'No activities recorded',
            ),
            const SizedBox(height: 28),
            _SectionLabel('Activity Timeline'),
            const SizedBox(height: 12),
            _TimelineBarChart(slots: data.activityTimeline),
          ],
        ),
      ),
    );
  }
}

class _PetTab extends StatelessWidget {
  final AnalyticsProvider analytics;
  final List<Pet> pets;
  final Pet? selectedPet;
  final Future<void> Function(Pet) onSelectPet;
  final bool isLoading;

  const _PetTab({
    required this.analytics,
    required this.pets,
    required this.selectedPet,
    required this.onSelectPet,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final data = analytics.petAnalytics;

    if (pets.isEmpty) {
      return _EmptyState(label: 'Add a pet to see their analytics');
    }

    return RefreshIndicator(
      color: const Color(0xFFF7A433),
      onRefresh: () async {
        if (selectedPet != null) await onSelectPet(selectedPet!);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PetSelector(
              pets: pets,
              selected: selectedPet,
              onSelect: onSelectPet,
            ),
            const SizedBox(height: 24),
            if (isLoading && data == null)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: CircularProgressIndicator(color: Color(0xFFF7A433)),
                ),
              )
            else if (analytics.error != null && data == null)
              _ErrorState(message: analytics.error!)
            else if (data == null)
              _EmptyState(label: 'Select a pet to view analytics')
            else ...[
              _SectionLabel('Stats for ${selectedPet?.name ?? 'Pet'}'),
              const SizedBox(height: 12),
              _PetStatGrid(data: data),
              const SizedBox(height: 28),
              _SectionLabel('Medical Compliance'),
              const SizedBox(height: 12),
              _ComplianceCard(rate: data.medicalComplianceRate),
              const SizedBox(height: 28),
              _SectionLabel('Health Events Breakdown'),
              const SizedBox(height: 12),
              _DistributionCard(
                distribution: data.healthEventTypeDistribution,
                emptyLabel: 'No health events for this pet',
              ),
              const SizedBox(height: 28),
              _SectionLabel('Activity Recurrence'),
              const SizedBox(height: 12),
              _DistributionCard(
                distribution: data.activityRecurrenceDistribution,
                emptyLabel: 'No activities for this pet',
              ),
              const SizedBox(height: 28),
              _SectionLabel('Activity Timeline'),
              const SizedBox(height: 12),
              _TimelineBarChart(slots: data.activityTimeline),
            ],
          ],
        ),
      ),
    );
  }
}

class _PetSelector extends StatelessWidget {
  final List<Pet> pets;
  final Pet? selected;
  final Future<void> Function(Pet) onSelect;

  const _PetSelector({
    required this.pets,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: pets.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final pet = pets[i];
          final isActive = selected?.id == pet.id;
          final color = PetTheme.cardColor(pet.species);
          return GestureDetector(
            onTap: () => onSelect(pet),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isActive ? color : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isActive ? color : Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              child: Text(
                pet.name,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: isActive ? Colors.white : const Color(0xFF64748B),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  final UserDashboardAnalyticsResponse data;
  const _StatGrid({required this.data});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _StatCard(
          label: 'Total Pets',
          value: '${data.totalPets}',
          icon: Icons.pets,
          color: const Color(0xFF97ACDA),
        ),
        _StatCard(
          label: 'Scheduled',
          value: '${data.totalScheduledActivities}',
          icon: Icons.event_note_outlined,
          color: const Color(0xFFF7A433),
        ),
        _StatCard(
          label: 'Active Routines',
          value: '${data.totalActiveRoutines}',
          icon: Icons.repeat_rounded,
          color: const Color(0xFFAE9CEE),
        ),
        _StatCard(
          label: 'Health Events',
          value: '${data.totalHealthEvents}',
          icon: Icons.monitor_heart_outlined,
          color: const Color(0xFFFF99CC),
        ),
      ],
    );
  }
}

class _PetStatGrid extends StatelessWidget {
  final PetActivityHealthAnalyticsResponse data;
  const _PetStatGrid({required this.data});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _StatCard(
          label: 'Scheduled',
          value: '${data.totalScheduledActivities}',
          icon: Icons.event_note_outlined,
          color: const Color(0xFFF7A433),
        ),
        _StatCard(
          label: 'Active Routines',
          value: '${data.totalActiveRoutines}',
          icon: Icons.repeat_rounded,
          color: const Color(0xFFAE9CEE),
        ),
        _StatCard(
          label: 'Health Events',
          value: '${data.totalHealthEvents}',
          icon: Icons.monitor_heart_outlined,
          color: const Color(0xFFFF99CC),
        ),
        _StatCard(
          label: 'Compliance',
          value: '${data.medicalComplianceRate.toStringAsFixed(0)}%',
          icon: Icons.verified_outlined,
          color: const Color(0xFF97ACDA),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1A2D40),
                    height: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ComplianceCard extends StatelessWidget {
  final double rate;
  const _ComplianceCard({required this.rate});

  @override
  Widget build(BuildContext context) {
    final clamped = rate.clamp(0.0, 100.0);
    final color = clamped >= 80
        ? Colors.green
        : clamped >= 50
        ? Colors.orange
        : Colors.redAccent;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${clamped.toStringAsFixed(1)}%',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  clamped >= 80
                      ? 'On Track'
                      : clamped >= 50
                      ? 'Needs Attention'
                      : 'At Risk',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: clamped / 100,
              minHeight: 10,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Medical events completed on schedule',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}

class _DistributionCard extends StatelessWidget {
  final Map<String, int> distribution;
  final String emptyLabel;

  const _DistributionCard({
    required this.distribution,
    required this.emptyLabel,
  });

  @override
  Widget build(BuildContext context) {
    final entries = distribution.entries
        .where((e) => e.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (entries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            emptyLabel,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
        ),
      );
    }

    final total = entries.fold<int>(0, (sum, e) => sum + e.value);
    final palette = [
      const Color(0xFFF7A433),
      const Color(0xFF97ACDA),
      const Color(0xFFAE9CEE),
      const Color(0xFFFF99CC),
      const Color(0xFF6EE7B7),
      const Color(0xFFFCA5A5),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(entries.length, (i) {
          final entry = entries[i];
          final pct = total > 0 ? entry.value / total : 0.0;
          final color = palette[i % palette.length];
          final label = entry.key[0].toUpperCase() + entry.key.substring(1);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          label,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A2D40),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${entry.value}  (${(pct * 100).toStringAsFixed(0)}%)',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 7,
                    backgroundColor: Colors.grey.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _TimelineBarChart extends StatelessWidget {
  final List<ActivityTimelineSlot> slots;
  const _TimelineBarChart({required this.slots});

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            'No timeline data',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
        ),
      );
    }

    final maxCount = slots.map((s) => s.count).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 110,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: slots.map((slot) {
                final fraction = maxCount > 0 ? slot.count / maxCount : 0.0;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (slot.count > 0)
                          Text(
                            '${slot.count}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFF7A433),
                            ),
                          ),
                        const SizedBox(height: 2),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOut,
                          height: (fraction * 80).clamp(4, 80),
                          decoration: BoxDecoration(
                            color: slot.count > 0
                                ? const Color(0xFFF7A433)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: slots.map((slot) {
              return Expanded(
                child: Text(
                  slot.timeSlot,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    color: const Color(0xFF94A3B8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF1A2D40),
        letterSpacing: -0.3,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String label;
  const _EmptyState({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bar_chart_rounded, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.grey,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 12),
            Text(
              message.replaceAll('Exception: ', ''),
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityBarChart extends StatelessWidget {
  final List<ActivityModel> activities;
  const _ActivityBarChart({required this.activities});

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) return const SizedBox.shrink();

    final Map<String, int> totalMap = {};
    final Map<String, int> doneMap = {};

    for (final a in activities) {
      final key = a.title.trim();
      totalMap[key] = (totalMap[key] ?? 0) + 1;
      if (a.isCompleted) doneMap[key] = (doneMap[key] ?? 0) + 1;
    }

    final sorted = totalMap.entries.toList()
      ..sort((x, y) => (doneMap[y.key] ?? 0).compareTo(doneMap[x.key] ?? 0));

    final top = sorted.take(6).toList();
    if (top.isEmpty) return const SizedBox.shrink();

    final maxVal = top
        .map((e) => e.value)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Most Completed Activities',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A2D40),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Based on all recorded activities',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final barWidth =
              ((constraints.maxWidth - (top.length - 1) * 10) / top.length)
                  .clamp(28.0, 64.0);
              const chartH = 120.0;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: top.map((entry) {
                  final done = (doneMap[entry.key] ?? 0).toDouble();
                  final total = entry.value.toDouble();
                  final doneH =
                  maxVal > 0 ? (done / maxVal) * chartH : 0.0;
                  final pendingH =
                  maxVal > 0 ? ((total - done) / maxVal) * chartH : 0.0;
                  final pct =
                  total > 0 ? ((done / total) * 100).round() : 0;

                  return SizedBox(
                    width: barWidth,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$pct%',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: pct >= 70
                                ? Colors.green
                                : pct >= 40
                                ? const Color(0xFFF7A433)
                                : Colors.redAccent,
                          ),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          height: chartH,
                          width: barWidth,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (pendingH > 0)
                                Container(
                                  height: pendingH,
                                  width: barWidth,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF7A433)
                                        .withValues(alpha: 0.25),
                                    borderRadius: doneH > 0
                                        ? BorderRadius.zero
                                        : BorderRadius.circular(6),
                                  ),
                                ),
                              if (doneH > 0)
                                Container(
                                  height: doneH,
                                  width: barWidth,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(
                                          pendingH > 0 ? 0 : 6),
                                      topRight: Radius.circular(
                                          pendingH > 0 ? 0 : 6),
                                      bottomLeft: const Radius.circular(6),
                                      bottomRight: const Radius.circular(6),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          entry.key,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A2D40),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _Legend(color: Colors.green, label: 'Completed'),
              const SizedBox(width: 16),
              _Legend(
                color: const Color(0xFFF7A433).withValues(alpha: 0.4),
                label: 'Pending',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      const SizedBox(width: 5),
      Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
        ),
      ),
    ],
  );
}

