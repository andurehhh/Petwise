import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petwise/contracts/pet/update_pet_request.dart';
import 'package:petwise/presentation/widgets/petwise_user_textField.dart';
import 'package:petwise/providers/pet_provider.dart';
import 'package:provider/provider.dart';
import 'package:petwise/presentation/widgets/petwise_image_picker_sheet.dart';

class EditPetProfileScreen extends StatefulWidget {
  const EditPetProfileScreen({super.key});

  @override
  State<EditPetProfileScreen> createState() => _EditPetProfileScreenState();
}

class _EditPetProfileScreenState extends State<EditPetProfileScreen> {
  late TextEditingController _petNameController;
  late TextEditingController _petSpeciesController;
  late TextEditingController _petBreedController;
  late TextEditingController _petAgeController;
  late TextEditingController _petWeightController;
  late String image_url;

  @override
  void initState() {
    super.initState();
    final pet = context.read<PetProvider>().selectedPet;

    _petNameController = TextEditingController(text: pet?.name ?? "");
    _petSpeciesController = TextEditingController(text: pet?.species ?? "");
    _petBreedController = TextEditingController(text: pet?.breed ?? "");
    _petAgeController = TextEditingController(text: pet?.age.toString() ?? "0");
    _petWeightController = TextEditingController(
      text: pet?.weight?.toString() ?? "0.1",
    );

    image_url = pet?.image_url ?? 'assets/images/doggie.gif';
  }

  @override
  void dispose() {
    _petAgeController.dispose();
    _petNameController.dispose();
    _petSpeciesController.dispose();
    _petBreedController.dispose();
    _petWeightController.dispose();
    super.dispose();
  }

  // Opens your custom URL picker bottom sheet
  void _openImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return PetwiseImagePickerSheet(
          currentImageUrl: image_url,
          onImageSelected: (newUrl) {
            setState(() {
              image_url = newUrl;
            });
          },
        );
      },
    );
  }

  ImageProvider _getProfileImage() {
    if (image_url.startsWith('http://') || image_url.startsWith('https://')) {
      return NetworkImage(image_url);
    }
    return AssetImage(image_url);
  }

  @override
  Widget build(BuildContext context) {
    final petProvider = context.watch<PetProvider>();
    final pet = petProvider.selectedPet;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F6),
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(CupertinoIcons.back, color: Color(0xFF1A2D40)),
        ),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // WIRED IMAGE PICKER WRAPPER
              GestureDetector(
                onTap: _openImagePickerSheet,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 72,
                      backgroundColor: const Color(0xFFF7A433),
                      child: CircleAvatar(
                        radius: 70,
                        backgroundImage: _getProfileImage(),
                      ),
                    ),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: const BoxDecoration(
                            color: Colors.black26,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "${pet?.name}",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                width: 150,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCDCDC),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 20),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "BASIC INFORMATION",
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: const Color(0xFF92A1B7),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          PetwiseUserTextfield(
                            textLabel: "Pet Name",
                            textHint: "Enter Pet Name here",
                            controller: _petNameController,
                            isEditable: true,
                          ),
                          PetwiseUserTextfield(
                            textLabel: "Species",
                            textHint: "e.g. Dog, Cat",
                            controller: _petSpeciesController,
                            isEditable: true,
                          ),
                          PetwiseUserTextfield(
                            textLabel: "Breed",
                            textHint: "Enter pet Breed here",
                            controller: _petBreedController,
                            isEditable: true,
                          ),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 800),
                            child: Row(
                              children: [
                                Expanded(
                                  child: PetwiseUserTextfield(
                                    textLabel: "Age (in Years)",
                                    textHint: "${pet?.age}",
                                    controller: _petAgeController,
                                    isEditable: true,
                                  ),
                                ),
                                Expanded(
                                  child: PetwiseUserTextfield(
                                    textLabel: "Weight (Kg)",
                                    textHint: "${pet?.weight}",
                                    controller: _petWeightController,
                                    isEditable: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: 800,
                              minWidth: 40,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 30),
                                FilledButton(
                                  onPressed: petProvider.isLoading
                                      ? null
                                      : () async {
                                          final currentPet =
                                              petProvider.selectedPet;
                                          final petId =
                                              petProvider.selectedPet?.id;
                                          if (currentPet == null ||
                                              petId == null)
                                            return;

                                          String? formatSex(String? sex) {
                                            if (sex == null ||
                                                sex.trim().isEmpty)
                                              return null;
                                            final clean = sex
                                                .trim()
                                                .toLowerCase();
                                            return clean[0].toUpperCase() +
                                                clean.substring(1);
                                          }

                                          final request = UpdatePetRequest(
                                            name: _petNameController.text
                                                .trim(),
                                            species: _petSpeciesController.text
                                                .trim(),
                                            breed: _petBreedController.text
                                                .trim(),
                                            weight:
                                                double.tryParse(
                                                  _petWeightController.text,
                                                ) ??
                                                0.0,
                                            birthday: currentPet.birthday,
                                            sex: formatSex(currentPet.sex),
                                            image_url: image_url,
                                          );
                                          debugPrint(
                                            "DEBUG JSON: ${request.toJson()}",
                                          );

                                          bool success = await context
                                              .read<PetProvider>()
                                              .updatePet(petId, request);

                                          if (success && mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Pet Info Updated!",
                                                ),
                                                backgroundColor:
                                                    Colors.lightGreen,
                                              ),
                                            );
                                            Navigator.pop(context);
                                          } else if (mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  petProvider.errorMessage ??
                                                      "Failed to update pet",
                                                ),
                                                backgroundColor:
                                                    Colors.redAccent,
                                              ),
                                            );
                                          }
                                        },
                                  style: FilledButton.styleFrom(
                                    minimumSize: const Size(300, 50),
                                    backgroundColor: const Color(0xFFF7A433),
                                    side: const BorderSide(
                                      color: Color(0xFFDA9B44),
                                      width: 2,
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
                                          "SAVE CHANGES",
                                          style: GoogleFonts.plusJakartaSans(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                                const SizedBox(height: 15),
                                OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(300, 50),
                                    side: const BorderSide(
                                      color: Color(0xFFF7A433),
                                      width: 2,
                                    ),
                                  ),
                                  child: Text(
                                    "CANCEL",
                                    style: GoogleFonts.plusJakartaSans(
                                      color: const Color(0xFFF7A433),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
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
