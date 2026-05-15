import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petwise/contracts/pet/create_pet_request.dart';
import 'package:petwise/presentation/widgets/petwise_user_textField.dart';
import 'package:petwise/providers/pet_provider.dart';
import 'package:petwise/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class MedicalRecord {
  final String title;
  final String description;
  final DateTime date;

  MedicalRecord({
    required this.title,
    required this.description,
    required this.date,
  });
}

class AddPetProfileScreen extends StatefulWidget {
  const AddPetProfileScreen({super.key});

  @override
  State<AddPetProfileScreen> createState() => _AddPetProfileScreenState();
}

class _AddPetProfileScreenState extends State<AddPetProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  DateTime? _selectedBirthday;
  String _selectedSex = "Male";
  final List<MedicalRecord> _medicalRecords = [];

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _showAddMedicalDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "Add Medical Background",
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PetwiseUserTextfield(
                  textLabel: "Title",
                  textHint: "e.g. First Vaccination",
                  controller: titleController,
                  isEditable: true,
                ),
                PetwiseUserTextfield(
                  textLabel: "Description",
                  textHint: "Enter details",
                  controller: descController,
                  isEditable: true,
                ),
                const SizedBox(height: 10),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    "Date",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    DateFormat('MMMM dd, yyyy').format(selectedDate),
                  ),
                  trailing: const Icon(
                    Icons.calendar_today,
                    size: 20,
                    color: Color(0xFFF7A433),
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setDialogState(() => selectedDate = picked);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: GoogleFonts.plusJakartaSans(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF7A433),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  setState(() {
                    _medicalRecords.add(
                      MedicalRecord(
                        title: titleController.text,
                        description: descController.text,
                        date: selectedDate,
                      ),
                    );
                  });
                  Navigator.pop(context);
                }
              },
              child: Text(
                "Add",
                style: GoogleFonts.plusJakartaSans(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final petProvider = context.watch<PetProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(CupertinoIcons.back, color: Color(0xFF1A2D40)),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_outlined,
              color: Color(0xFF1A2D40),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    height: 140,
                    width: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFECEBE9),
                      border: Border.all(
                        color: const Color(0xFFDCDCDC),
                        width: 2,
                      ),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/SUA.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(0xFFF7A433),
                    child: Icon(
                      Icons.camera_alt,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _nameController.text.isEmpty
                    ? "Pet Name"
                    : _nameController.text,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A2D40),
                ),
              ),
              const SizedBox(height: 32),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "BASIC INFORMATION",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF92A1B7),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              PetwiseUserTextfield(
                textLabel: "Pet Name",
                textHint: "Enter name",
                controller: _nameController,
                isEditable: true,
              ),
              PetwiseUserTextfield(
                textLabel: "Breed",
                textHint: "Enter breed",
                controller: _breedController,
                isEditable: true,
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Sex",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A2D40),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFDCDCDC)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedSex,
                              isExpanded: true,
                              items: ["Male", "Female"].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) =>
                                  setState(() => _selectedSex = val!),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Birthday",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A2D40),
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setState(() => _selectedBirthday = picked);
                            }
                          },
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFDCDCDC),
                              ),
                            ),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _selectedBirthday == null
                                  ? "Select Date"
                                  : DateFormat(
                                      'MM/dd/yyyy',
                                    ).format(_selectedBirthday!),
                              style: GoogleFonts.plusJakartaSans(fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: PetwiseUserTextfield(
                      textLabel: "Age (Years)",
                      textHint: "0",
                      controller: _ageController,
                      isEditable: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: PetwiseUserTextfield(
                      textLabel: "Weight (kg)",
                      textHint: "0.0",
                      controller: _weightController,
                      isEditable: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "HEALTH & VITALITY",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF92A1B7),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    ..._medicalRecords.map(
                      (record) => Column(
                        children: [
                          _buildMedicalRecordTile(
                            title: record.title,
                            date: DateFormat(
                              'MMMM dd, yyyy',
                            ).format(record.date),
                            description: record.description,
                            icon: Icons.history,
                          ),
                          const Divider(height: 24, color: Color(0xFFF5F5F5)),
                        ],
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFFFF4E6),
                        child: Icon(Icons.add, color: Color(0xFFF7A433)),
                      ),
                      title: Text(
                        "Add Medical Background",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A2D40),
                        ),
                      ),
                      trailing: const Icon(
                        Icons.add_circle,
                        size: 24,
                        color: Color(0xFFDCDCDC),
                      ),
                      onTap: _showAddMedicalDialog,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: petProvider.isLoading
                    ? null
                    : () async {
                        if (_nameController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please enter your pet's name."),
                            ),
                          );
                          return;
                        }

                        if (_breedController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please enter your pet's breed."),
                            ),
                          );
                          return;
                        }

                        final currentUserId = authProvider.userId;

                        if (currentUserId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Error: User session not found."),
                            ),
                          );
                          return;
                        }

                        final request = CreatePetRequest(
                          name: _nameController.text.trim(),
                          species: _breedController.text.trim(),
                          breed: _breedController.text.trim(),
                          weight:
                              double.tryParse(_weightController.text) ?? 0.0,
                          birthday: _selectedBirthday ?? DateTime.now(),
                          sex: _selectedSex.toLowerCase(),
                          userId: currentUserId,
                        );

                        try {
                          await context.read<PetProvider>().createNewPet(
                            request,
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Pet profile added successfully!",
                                ),
                              ),
                            );
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error: ${e.toString()}")),
                            );
                          }
                        }
                      },
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  backgroundColor: const Color(0xFFF1A852),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: petProvider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        "Add Profile",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancel",
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF92A1B7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicalRecordTile({
    required String title,
    required String date,
    required String description,
    required IconData icon,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFFFF4E6),
        child: Icon(icon, color: const Color(0xFFF7A433), size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1A2D40),
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            date,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          if (description.isNotEmpty)
            Text(
              description,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: const Color(0xFF92A1B7),
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Color(0xFFDCDCDC),
      ),
      onTap: () {},
    );
  }
}
