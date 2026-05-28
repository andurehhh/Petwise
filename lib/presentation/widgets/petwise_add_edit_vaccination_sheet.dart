import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:petwise/providers/pet_provider.dart';
import 'package:provider/provider.dart';
import 'package:petwise/data/models/vaccination_model.dart';
import 'package:petwise/providers/vaccination_provider.dart';

class AddEditVaccinationSheet extends StatefulWidget {
  final int petId;
  final VaccinationModel? existing; // null = add, non-null = edit
  final String? prefillName;
  final DateTime? prefillDate;
  final DateTime? prefillExpiry;

  const AddEditVaccinationSheet({
    super.key,
    required this.petId,
    this.existing,
    this.prefillName,
    this.prefillDate,
    this.prefillExpiry,
  });

  @override
  State<AddEditVaccinationSheet> createState() =>
      _AddEditVaccinationSheetState();
}

class _AddEditVaccinationSheetState extends State<AddEditVaccinationSheet> {
  final _nameController = TextEditingController();
  DateTime _dateGiven = DateTime.now();
  DateTime? _expiryDate;
  bool _isSubmitting = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _nameController.text = widget.existing!.vaccineName;
      _dateGiven = widget.existing!.dateGiven;
      _expiryDate = widget.existing!.expiryDate;
    } else {
      // Pre-fill from health event sheet if provided
      if (widget.prefillName != null) {
        _nameController.text = widget.prefillName!;
      }
      if (widget.prefillDate != null) _dateGiven = widget.prefillDate!;
      if (widget.prefillExpiry != null) _expiryDate = widget.prefillExpiry;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isExpiry}) async {
    final initial = isExpiry ? (_expiryDate ?? DateTime.now()) : _dateGiven;
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
        _dateGiven = picked;
      }
    });
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty) return;
    setState(() => _isSubmitting = true);

    final provider = context.read<VaccinationProvider>();
    final petName = context.read<PetProvider>().getPetName(widget.petId);

    try {
      if (_isEdit) {
        await provider.updateVaccination(
          eventId: widget.existing!.id,
          petId: widget.petId,
          vaccineName: _nameController.text.trim(),
          dateGiven: _dateGiven,
          expiryDate: _expiryDate,
          petName: petName,
        );
      } else {
        await provider.addVaccination(
          petId: widget.petId,
          petName: petName,
          vaccineName: _nameController.text.trim(),
          dateGiven: _dateGiven,
          expiryDate: _expiryDate,
        );
      }
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                _isEdit ? 'Edit Vaccination' : 'Add Vaccination',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A2D40),
                ),
              ),
              const SizedBox(height: 24),

              // Vaccine name
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Vaccine Name',
                  hintText: 'e.g. Rabies, Distemper',
                  prefixIcon: const Icon(
                    Icons.vaccines_outlined,
                    color: Color(0xFFF7A433),
                  ),
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

              // Date given
              _DatePickerTile(
                label: 'Date Given',
                date: _dateGiven,
                icon: Icons.calendar_today_outlined,
                onTap: () => _pickDate(isExpiry: false),
              ),
              const SizedBox(height: 12),

              // Expiry date (optional)
              _DatePickerTile(
                label: _expiryDate == null
                    ? 'Expiry Date (optional)'
                    : 'Expiry Date',
                date: _expiryDate,
                icon: Icons.event_available_outlined,
                onTap: () => _pickDate(isExpiry: true),
                trailing: _expiryDate != null
                    ? GestureDetector(
                        onTap: () => setState(() => _expiryDate = null),
                        child: const Icon(
                          Icons.close,
                          size: 18,
                          color: Colors.grey,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 32),

              // Submit
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF7A433),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          _isEdit ? 'Save Changes' : 'Add Vaccination',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DatePickerTile extends StatelessWidget {
  final String label;
  final DateTime? date;
  final IconData icon;
  final VoidCallback onTap;
  final Widget? trailing;

  const _DatePickerTile({
    required this.label,
    required this.date,
    required this.icon,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                    ? DateFormat('MMM dd, yyyy').format(date!)
                    : label,
                style: GoogleFonts.plusJakartaSans(
                  color: date != null
                      ? const Color(0xFF1A2D40)
                      : Colors.grey.shade500,
                  fontWeight:
                      date != null ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
            trailing ?? Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
