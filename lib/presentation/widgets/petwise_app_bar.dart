import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:petwise/providers/activity_provider.dart';
import 'package:petwise/data/models/activity_model.dart';
import 'package:petwise/routes/app_route.dart';

class PetWiseAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PetWiseAppBar({super.key});

  void _showNotifications(BuildContext context) {
    final activityProvider = context.read<ActivityProvider>();
    final now = DateTime.now();
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final upcoming = activityProvider.activities
        .where(
          (a) =>
              !a.isCompleted &&
              !a.scheduledDate.isBefore(
                now.subtract(const Duration(minutes: 30)),
              ) &&
              !a.scheduledDate.isAfter(todayEnd),
        )
        .toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _NotificationPanel(upcoming: upcoming),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final todayPendingCount = context
        .watch<ActivityProvider>()
        .activities
        .where(
          (a) =>
              !a.isCompleted &&
              !a.scheduledDate.isBefore(
                now.subtract(const Duration(minutes: 30)),
              ) &&
              !a.scheduledDate.isAfter(todayEnd),
        )
        .length;

    return AppBar(
      backgroundColor: const Color(0xffF8F7F6),
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 13,
      title: Row(
        children: [
          Image.asset('assets/images/logo.png', height: 35),
          const SizedBox(width: 5),
          Padding(
            padding: const EdgeInsets.only(top: 9.0),
            child: Text(
              'PetWise',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.black,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
      actions: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () => _showNotifications(context),
              icon: const Icon(
                Icons.notifications_none,
                color: Colors.black,
                size: 25,
              ),
            ),
            if (todayPendingCount > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF7A433),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      todayPendingCount > 9 ? '9+' : '$todayPendingCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        IconButton(
          onPressed: () => Navigator.pushNamed(context, AppRoute.userProfile),
          icon: const Icon(Icons.person_outline, color: Colors.black, size: 25),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _NotificationPanel extends StatelessWidget {
  final List<ActivityModel> upcoming;

  const _NotificationPanel({required this.upcoming});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Color(0xffF8F7F6),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Upcoming Activities',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1A2D40),
                    ),
                  ),
                  if (upcoming.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7A433).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${upcoming.length} pending',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFF7A433),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: upcoming.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 52,
                            color: Colors.green.shade300,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'All caught up!',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.grey,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: controller,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      itemCount: upcoming.length,
                      itemBuilder: (_, i) =>
                          _NotifTile(activity: upcoming[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final ActivityModel activity;

  const _NotifTile({required this.activity});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isToday = activity.scheduledDate.year == now.year &&
        activity.scheduledDate.month == now.month &&
        activity.scheduledDate.day == now.day;
    final isSoon = activity.scheduledDate
        .difference(now)
        .inMinutes
        .abs() <= 60 && isToday;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isSoon
            ? Border.all(color: const Color(0xFFF7A433).withValues(alpha: 0.5))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSoon
                  ? const Color(0xFFF7A433).withValues(alpha: 0.15)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isSoon ? Icons.alarm : Icons.event_note_outlined,
              size: 20,
              color: isSoon ? const Color(0xFFF7A433) : Colors.grey,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A2D40),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isToday
                      ? 'Today · ${DateFormat('hh:mm a').format(activity.scheduledDate)}'
                      : DateFormat('MMM d · hh:mm a')
                            .format(activity.scheduledDate),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (isSoon)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFF7A433).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Soon',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFF7A433),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
