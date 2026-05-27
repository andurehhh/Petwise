import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:petwise/providers/pet_provider.dart';
import 'package:petwise/utils/pet_theme.dart';
import '../widgets/petwise_app_bar.dart';
import '../widgets/petwise_petcard.dart';
import 'package:intl/intl.dart';
import '../widgets/petwise_Navbar.dart';
import 'package:petwise/presentation/screens/pet_profile_screen.dart';

class PetCardScreen extends StatelessWidget {
  const PetCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final petList = context.watch<PetProvider>().pets;

    return Scaffold(
      backgroundColor: const Color(0xffF8F7F6),
      appBar: const PetWiseAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              itemCount: petList.length,
              itemBuilder: (context, index) {
                final pet = petList[index];

                final String displayImage =
                    (pet.image_url != null && pet.image_url!.isNotEmpty)
                    ? pet.image_url!
                    : 'assets/images/doggie.gif';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: GestureDetector(
                    onTap: () {
                      context.read<PetProvider>().selectPet(pet);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PetProfileScreen(),
                        ),
                      );
                    },
                    child: PetCard(
                      id: pet.id,
                      name: pet.name,
                      species: pet.species,
                      birthday: DateFormat('MM-dd-yyyy').format(pet.birthday),
                      sex: pet.sex,
                      cardColor: PetTheme.cardColor(pet.species),
                      detailColor: PetTheme.detailColor(pet.species),
                      dataTileBackgroundColor: PetTheme.tileBackground(pet.species),
                      imagePath: displayImage,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/AddPetProfileScreen');
        },
        backgroundColor: const Color(0xFFF7A433),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const PetwiseNavbar(navbarIndex: 3),
    );
  }
}
