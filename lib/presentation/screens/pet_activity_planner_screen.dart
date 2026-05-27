import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:petwise/providers/activity_provider.dart';
import 'package:petwise/providers/user_provider.dart';
import 'package:petwise/providers/pet_provider.dart';
import 'package:petwise/presentation/widgets/petwise_dynamic_activity_card.dart';
import 'package:petwise/presentation/widgets/petwise_add_activity_sheet.dart';

class PlannerScreen extends StatefulWidget {
  final DateTime? initialDate;

  const PlannerScreen({super.key, this.initialDate});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.initialDate ?? DateTime.now();
    _selectedDay = widget.initialDate ?? DateTime.now();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final petProvider = context.read<PetProvider>();
      final activityProvider = context.read<ActivityProvider>();

      if (petProvider.pets.isEmpty) {
        final userProvider = context.read<UserProvider>();
        final userId = userProvider.user?.id;
        if (userId != null) {
          await petProvider.loadUserPets(userId);
        }
      }

      if (!mounted) return;
      final petIds = petProvider.pets.map((p) => p.id).toList();
      if (petIds.isNotEmpty) {
        activityProvider.loadAllActivities(petIds);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final activityProvider = context.watch<ActivityProvider>();
    final userProvider = context.watch<UserProvider>();
    final userId = userProvider.user?.id;

    final dailyActivities = activityProvider.activities
        .where((a) => isSameDay(a.scheduledDate, _selectedDay))
        .toList();

    final pendingCount = dailyActivities.where((a) => !a.isCompleted).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A2D40)),
        title: Text(
          "Schedule Board",
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF1A2D40),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TableCalendar(
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: (day) => activityProvider.activities
                  .where((a) => isSameDay(a.scheduledDate, day))
                  .toList(),
              onDaySelected: (selectedDay, focusedDay) {
                Future.microtask(() {
                  if (mounted) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  }
                });
              },
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarStyle: const CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Color(0xFFF7A433),
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Color(0x4DF7A433),
                  shape: BoxShape.circle,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isEmpty) return const SizedBox();
                  final allDone = events.every(
                    (e) => (e as dynamic).isCompleted,
                  );
                  return Positioned(
                    bottom: 1,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: allDone ? Colors.green : const Color(0xFFF7A433),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Activities",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (dailyActivities.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: pendingCount == 0
                              ? Colors.green.withOpacity(0.1)
                              : const Color(0xFFFFF4E6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          pendingCount == 0 ? "Done" : "$pendingCount Pending",
                          style: GoogleFonts.plusJakartaSans(
                            color: pendingCount == 0
                                ? Colors.green
                                : const Color(0xFFF7A433),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                if (activityProvider.error != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.redAccent,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            activityProvider.error!,
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.redAccent,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              context.read<ActivityProvider>().clearError(),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (activityProvider.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: CircularProgressIndicator(
                        color: Color(0xFFF7A433),
                      ),
                    ),
                  )
                else if (dailyActivities.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Text(
                        "No activities for this day",
                        style: GoogleFonts.roboto(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ...dailyActivities.map(
                    (activity) => DynamicActivityCard(
                      key: ObjectKey(activity),
                      activity: activity,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFF7A433),
        onPressed: () {
          Future.microtask(() {
            if (!mounted) return;
            if (userId != null) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => AddActivitySheet(
                  userId: userId,
                  selectedDate: _selectedDay,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("User session not found.")),
              );
            }
          });
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
