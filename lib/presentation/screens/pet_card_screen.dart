import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:petwise/providers/pet_provider.dart';
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
                final String species = pet.species.toLowerCase();

                // Theme color fallback pairs by pet species type
                Color cardColor = const Color(0xFFABC4ED);
                Color detailColor = const Color(0xFF435B85);
                Color tileBackground = const Color(0xFFE3F2FD);

                if (species.contains('dog')) {
                  cardColor = const Color(0xFF97ACDA);
                  detailColor = const Color(0xFF5F76A7);
                  tileBackground = const Color(0xFFD9E9FE);
                } else if (species.contains('cat')) {
                  cardColor = const Color(0xFFAE9CEE);
                  detailColor = const Color(0xFF8D64AD);
                  tileBackground = const Color(0xFFE4D9FE);
                } else if (species.contains('rabbit')) {
                  cardColor = const Color(0xFFFF99CC);
                  detailColor = const Color(0xFF880E4F);
                  tileBackground = const Color(0xFFFCE4EC);
                } else if (species.contains('bird')) {
                  cardColor = const Color(0xFFF7A433);
                  detailColor = const Color(0xFFE1962D);
                  tileBackground = const Color(0xFFF7E6CE);
                }

                // Resolves either custom uploaded user avatars or fallback local asset
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
                      cardColor: cardColor,
                      detailColor: detailColor,
                      dataTileBackgroundColor: tileBackground,
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
