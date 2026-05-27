import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:petwise/providers/health_event_provider.dart';
import 'package:petwise/providers/pet_provider.dart';
import 'package:petwise/providers/vaccination_provider.dart';
import 'package:petwise/contracts/health_event/create_health_event_request.dart';

class AddHealthEventSheet extends StatefulWidget {
  final int? preselectedPetId;

  const AddHealthEventSheet({super.key, this.preselectedPetId});

  @override
  State<AddHealthEventSheet> createState() => _AddHealthEventSheetState();
}

class _AddHealthEventSheetState extends State<AddHealthEventSheet> {
  final _eventNameController = TextEditingController();
  int? _selectedPetId;
  DateTime _selectedDate = DateTime.now();
  String _selectedType = 'checkup';
  bool _isSubmitting = false;

  // Vaccination-specific extras (shown inline when type == vaccination)
  DateTime? _expiryDate;

  final List<String> _types = ['checkup', 'vaccination', 'illness', 'other'];

  @override
  void initState() {
    super.initState();
    _selectedPetId = widget.preselectedPetId;
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isExpiry}) async {
    final initial = isExpiry ? (_expiryDate ?? DateTime.now()) : _selectedDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFFF7A433)),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isExpiry) {
        _expiryDate = picked;
      } else {
        _selectedDate = picked;
      }
    });
  }

  Future<void> _submit() async {
    if (_eventNameController.text.trim().isEmpty || _selectedPetId == null) {
      return;
    }
    setState(() => _isSubmitting = true);

    // Vaccination type: save via VaccinationProvider so it appears in the
    // vaccination UI with expiry/validity tracking.
    if (_selectedType == 'vaccination') {
      try {
        await context.read<VaccinationProvider>().addVaccination(
          petId: _selectedPetId!,
          vaccineName: _eventNameController.text.trim(),
          dateGiven: _selectedDate,
          expiryDate: _expiryDate,
        );
        if (!mounted) return;
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save vaccination: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
      return;
    }

    final request = CreateHealthEventRequest(
      petId: _selectedPetId!,
      eventName: _eventNameController.text.trim(),
      eventDate: _selectedDate,
      type: _selectedType,
    );

    try {
      await context.read<HealthEventProvider>().createNewHealthEvent(request);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add health event: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final petProvider = context.watch<PetProvider>();
    final isVaccination = _selectedType == 'vaccination';

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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "New Health Event",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A2D40),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _eventNameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: isVaccination ? "Vaccine Name" : "Event Name",
                hintText: isVaccination
                    ? "e.g. Rabies, Distemper"
                    : "e.g. Annual Checkup",
                prefixIcon: isVaccination
                    ? const Icon(Icons.vaccines_outlined,
                        color: Color(0xFFF7A433))
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFFF7A433),
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              initialValue: _selectedPetId,
              decoration: InputDecoration(
                labelText: "Assign to Pet",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              items: petProvider.pets
                  .map(
                    (p) => DropdownMenuItem(value: p.id, child: Text(p.name)),
                  )
                  .toList(),
              onChanged: (val) => setState(() => _selectedPetId = val),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedType,
              decoration: InputDecoration(
                labelText: "Event Type",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              items: _types
                  .map(
                    (t) => DropdownMenuItem(
                      value: t,
                      child: Row(
                        children: [
                          Icon(
                            _iconForType(t),
                            size: 18,
                            color: t == 'vaccination'
                                ? const Color(0xFFF7A433)
                                : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(t[0].toUpperCase() + t.substring(1)),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (val) => setState(() {
                _selectedType = val ?? 'checkup';
                // Reset expiry when switching away from vaccination
                if (_selectedType != 'vaccination') _expiryDate = null;
              }),
            ),
            const SizedBox(height: 16),

            // Date given / event date
            _buildDateTile(
              label: isVaccination ? "Date Given" : "Event Date",
              date: _selectedDate,
              icon: Icons.calendar_today_outlined,
              onTap: () => _pickDate(isExpiry: false),
            ),

            // Expiry date — only shown for vaccination
            if (isVaccination) ...[
              const SizedBox(height: 12),
              _buildDateTile(
                label: _expiryDate == null
                    ? "Expiry Date (optional)"
                    : "Expiry Date",
                date: _expiryDate,
                icon: Icons.event_available_outlined,
                onTap: () => _pickDate(isExpiry: true),
                trailing: _expiryDate != null
                    ? GestureDetector(
                        onTap: () => setState(() => _expiryDate = null),
                        child: const Icon(Icons.close,
                            size: 18, color: Colors.grey),
                      )
                    : null,
              ),
              const SizedBox(height: 8),
              // Hint banner
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4E6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        size: 15, color: Color(0xFFF7A433)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "This will also appear in the Vaccination tracker with validity status.",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: const Color(0xFFF7A433),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF7A433),
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      isVaccination ? "Save Vaccination" : "Save Health Event",
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
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'vaccination':
        return Icons.vaccines_outlined;
      case 'checkup':
        return Icons.monitor_heart_outlined;
      case 'illness':
        return Icons.sick_outlined;
      default:
        return Icons.medical_services_outlined;
    }
  }

  Widget _buildDateTile({
    required String label,
    required DateTime? date,
    required IconData icon,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFF7A433), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                date != null
                    ? DateFormat('MMM dd, yyyy').format(date)
                    : label,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight:
                      date != null ? FontWeight.w600 : FontWeight.normal,
                  color: date != null
                      ? const Color(0xFF1A2D40)
                      : Colors.grey.shade500,
                ),
              ),
            ),
            trailing ??
                Icon(Icons.chevron_right,
                    color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }
}
