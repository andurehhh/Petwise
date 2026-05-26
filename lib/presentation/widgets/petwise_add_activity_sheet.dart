import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:petwise/contracts/activity/create_activity_request.dart';
import 'package:petwise/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:petwise/providers/activity_provider.dart';
import 'package:petwise/providers/pet_provider.dart';
import 'package:petwise/data/models/activity_model.dart';

class AddActivitySheet extends StatefulWidget {
  final String userId;
  final DateTime? selectedDate;

  const AddActivitySheet({super.key, required this.userId, this.selectedDate});

  @override
  State<AddActivitySheet> createState() => _AddActivitySheetState();
}

class _AddActivitySheetState extends State<AddActivitySheet> {
  final _titleController = TextEditingController();
  int? _selectedPetId;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final petProvider = context.watch<PetProvider>();

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 32,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "New Activity",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: "Activity Title",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<int>(
            value: _selectedPetId,
            decoration: InputDecoration(
              labelText: "Assign to Pet",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            items: petProvider.pets
                .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
                .toList(),
            onChanged: (val) => setState(() => _selectedPetId = val),
          ),
          const SizedBox(height: 20),
          InkWell(
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(_selectedDate),
              );
              if (time != null) {
                setState(
                  () => _selectedDate = DateTime(
                    _selectedDate.year,
                    _selectedDate.month,
                    _selectedDate.day,
                    time.hour,
                    time.minute,
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Select Time",
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    DateFormat('hh:mm a').format(_selectedDate),
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFFF7A433),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF7A433),
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () async {
              if (_titleController.text.isNotEmpty && _selectedPetId != null) {
                try {
                  // 1. Format the time correctly for System.TimeOnly (HH:mm:ss)
                  final formattedTime = DateFormat('HH:mm:ss').format(_selectedDate);

                  // 2. Call the provider
                  await context.read<ActivityProvider>().addActivity(
                    CreateActivityRequest(
                      petId: _selectedPetId!,
                      title: _titleController.text,
                      description: "Time to take care of your pet!",
                      timeScheduled: formattedTime, // Pass only the time
                      recurrence: "None",
                    ),
                  );

                  // 3. Show success notification (Optional, since provider also schedules one)
                  // We use the singleton instance properly here
                  await NotificationService().showInstantNotification(
                      "Activity Scheduled",
                      "Task '${_titleController.text}' has been added."
                  );

                  // 4. Pop ONLY once and only if still mounted
                  if (mounted) {
                    Navigator.pop(context);
                  }
                } catch (e) {
                  // Handle potential errors (e.g., show a SnackBar)
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed to add activity: $e")),
                    );
                  }
                }
              }
            },
            child: Text(
              "Schedule Activity",
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
