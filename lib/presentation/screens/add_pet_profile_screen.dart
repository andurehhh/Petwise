import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petwise/contracts/pet/create_pet_request.dart';
import 'package:petwise/contracts/health_event/create_health_event_request.dart';
import 'package:petwise/presentation/widgets/petwise_user_textField.dart';
import 'package:petwise/presentation/widgets/petwise_image_picker_sheet.dart';
import 'package:petwise/providers/pet_provider.dart';
import 'package:petwise/providers/auth_provider.dart';
import 'package:petwise/providers/health_event_provider.dart';
import 'package:petwise/presentation/widgets/petwise_confirmation_dialog.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class MedicalRecord {
  final String title;
  final String description;
  final DateTime date;
  final String type;

  MedicalRecord({
    required this.title,
    required this.description,
    required this.date,
    this.type = 'checkup',
  });
}

class AddPetProfileScreen extends StatefulWidget {
  const AddPetProfileScreen({super.key});

  @override
  State<AddPetProfileScreen> createState() => _AddPetProfileScreenState();
}

class _AddPetProfileScreenState extends State<AddPetProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _speciesController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  DateTime? _selectedBirthday;
  String _selectedSex = "Male";
  String? _pickedImagePath;
  final String _defaultAssetPath =
      'https://i.pinimg.com/736x/54/34/81/543481c0ca5a909bd4d23863c6262339.jpg';
  final List<MedicalRecord> _medicalRecords = [];

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onNameChanged);
  }

  void _onNameChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _speciesController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _openPetwiseImagePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PetwiseImagePickerSheet(
        currentImageUrl: _pickedImagePath ?? _defaultAssetPath,
        onImageSelected: (String newImageUrl) {
          setState(() {
            _pickedImagePath = newImageUrl;
          });
        },
      ),
    );
  }

  void _showAddMedicalDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    DateTime dialogSelectedDate = DateTime.now();
    String dialogSelectedType = 'checkup';
    final List<String> types = ['checkup', 'vaccination', 'illness', 'other'];

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
                DropdownButtonFormField<String>(
                  value: dialogSelectedType,
                  decoration: InputDecoration(
                    labelText: "Type",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: types
                      .map(
                        (t) => DropdownMenuItem(
                          value: t,
                          child: Text(
                            t[0].toUpperCase() + t.substring(1),
                            style: GoogleFonts.plusJakartaSans(fontSize: 14),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setDialogState(
                    () => dialogSelectedType = val ?? 'checkup',
                  ),
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
                    DateFormat('MMMM dd, yyyy').format(dialogSelectedDate),
                  ),
                  trailing: const Icon(
                    Icons.calendar_today,
                    size: 20,
                    color: Color(0xFFF7A433),
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: dialogSelectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setDialogState(() => dialogSelectedDate = picked);
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
                final cleanedTitle = titleController.text.trim();
                if (cleanedTitle.isNotEmpty) {
                  final newRecord = MedicalRecord(
                    title: cleanedTitle,
                    description: descController.text.trim(),
                    date: dialogSelectedDate,
                    type: dialogSelectedType,
                  );
                  Navigator.pop(context);
                  setState(() {
                    _medicalRecords.add(newRecord);
                  });
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

  ImageProvider _getAvatarImage() {
    final path = _pickedImagePath ?? _defaultAssetPath;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return NetworkImage(path);
    }
    return AssetImage(path);
  }

  Future<void> _submitPetProfile() async {
    if (_nameController.text.trim().isEmpty ||
        _speciesController.text.trim().isEmpty ||
        _breedController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill out Name, Species, and Breed."),
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final currentUserId = authProvider.userId;

    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: User session not found.")),
      );
      return;
    }

    final request = CreatePetRequest(
      name: _nameController.text.trim(),
      species: _speciesController.text.trim(),
      breed: _breedController.text.trim(),
      weight: double.tryParse(_weightController.text) ?? 0.0,
      birthday: _selectedBirthday ?? DateTime.now(),
      sex: _selectedSex.toLowerCase(),
      userId: currentUserId,
      image_url: _pickedImagePath ?? _defaultAssetPath,
    );

    try {
      await context.read<PetProvider>().createNewPet(request);

      if (_medicalRecords.isNotEmpty) {
        final petProvider = context.read<PetProvider>();
        final newPetId = petProvider.pets.isNotEmpty
            ? petProvider.pets.last.id
            : null;

        if (newPetId != null) {
          final healthEventProvider = context.read<HealthEventProvider>();
          for (final record in _medicalRecords) {
            await healthEventProvider.createNewHealthEvent(
              CreateHealthEventRequest(
                petId: newPetId,
                eventName: record.title,
                eventDate: record.date,
                type: record.type,
              ),
            );
          }
        }
      }

      if (mounted) {
        Navigator.pop(context);
        await PetwiseConfirmationDialog.show(
          context: context,
          success: true,
          title: 'Pet Added',
          message: '${_nameController.text.trim()} has been added to your profile.',
        );
      }
    } catch (e) {
      if (mounted) {
        await PetwiseConfirmationDialog.show(
          context: context,
          success: false,
          title: 'Failed to Add Pet',
          message: e.toString().replaceAll('Exception: ', ''),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final petProvider = context.watch<PetProvider>();

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
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _openPetwiseImagePicker,
                  child: Stack(
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
                          image: DecorationImage(
                            image: _getAvatarImage(),
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
                  textLabel: "Species",
                  textHint: "e.g. Dog, Cat",
                  controller: _speciesController,
                  isEditable: true,
                ),
                PetwiseUserTextfield(
                  textLabel: "Breed",
                  textHint: "Enter breed",
                  controller: _breedController,
                  isEditable: true,
                ),
                // Birthday field in its own row, styled like PetwiseUserTextfield
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Birthday",
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedBirthday ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() => _selectedBirthday = picked);
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.all(5),
                          padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              width: 1.5,
                              color: const Color(0xFFDCDCDC),
                            ),
                          ),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _selectedBirthday == null
                                ? "Select Date"
                                : DateFormat('MM/dd/yyyy').format(_selectedBirthday!),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              color: const Color(0xFF1A2D40),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: PetwiseUserTextfield(
                        textLabel: "Weight (kg)",
                        textHint: "0.0",
                        controller: _weightController,
                        isEditable: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Sex",
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: ['Male', 'Female'].map((sex) {
                          final isSelected = _selectedSex == sex;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedSex = sex),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                margin: EdgeInsets.only(
                                  right: sex == 'Male' ? 8 : 0,
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? (sex == 'Male'
                                          ? const Color(0xFFDEEAFF)
                                          : const Color(0xFFFFDEF0))
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: isSelected
                                        ? (sex == 'Male'
                                            ? const Color(0xFF5B8DEF)
                                            : const Color(0xFFEF5BAD))
                                        : const Color(0xFFDCDCDC),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      sex == 'Male' ? Icons.male : Icons.female,
                                      size: 20,
                                      color: isSelected
                                          ? (sex == 'Male'
                                              ? const Color(0xFF5B8DEF)
                                              : const Color(0xFFEF5BAD))
                                          : const Color(0xFF94A3B8),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      sex,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: isSelected
                                            ? (sex == 'Male'
                                                ? const Color(0xFF5B8DEF)
                                                : const Color(0xFFEF5BAD))
                                            : const Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
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
                              type: record.type,
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
                  onPressed: petProvider.isLoading ? null : _submitPetProfile,
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
                          "Add Pet To Profile",
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
      ),
    );
  }

  Widget _buildMedicalRecordTile({
    required String title,
    required String date,
    required String description,
    required String type,
  }) {
    IconData icon;
    switch (type.toLowerCase()) {
      case 'vaccination':
        icon = Icons.vaccines_outlined;
        break;
      case 'illness':
        icon = Icons.sick_outlined;
        break;
      default:
        icon = Icons.monitor_heart_outlined;
    }

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
    );
  }
}
