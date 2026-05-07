import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petwise/presentation/widgets/petwise_pet_activity_log.dart';
import 'package:petwise/presentation/widgets/petwise_pet_upcoming_medical_pill.dart';
import 'package:petwise/providers/pet_provider.dart';
import 'package:petwise/routes/app_route.dart';
import 'package:provider/provider.dart';

class PetProfileScreen extends StatefulWidget {
  const PetProfileScreen({super.key});

  @override
  State<PetProfileScreen> createState() => _PetProfileScreenState();
}

class _PetProfileScreenState extends State<PetProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final petProvider = context.watch<PetProvider>();
    final pet = petProvider.selectedPet;
    return Scaffold(
      backgroundColor: Color(0xFFDA9799),
      // backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.4, 0.4],
            colors: [
              Color(0xFFDA9799), //bg color
              Colors.white,
            ],
          ),
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              stretch: true,
              expandedHeight: 300,
              pinned: true,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              clipBehavior: Clip.none,
              actions: [
                IconButton(
                  onPressed: () {
                    /*insert favorite function here*/
                  },
                  icon: Icon(Icons.favorite_border),
                ),
                IconButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoute.editPetProfile),
                  icon: Icon(Icons.edit),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: Color(0xFFDA9799),
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        bottom: -50,
                        child: CircleAvatar(
                          radius: 120,
                          backgroundColor: Colors.grey.shade400,
                          child: CircleAvatar(
                            radius: 119,
                            backgroundColor: Colors.white,
                            backgroundImage: AssetImage(
                              'assets/images/dog.png',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Container(
                // transform: Matrix4.translationValues(0, -50, 0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 20, 30, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pet!.name,
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.black,
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -1.5,
                            ),
                          ),
                          Text(
                            pet.species,
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.grey,
                              fontSize: 16,
                              letterSpacing: -1.5,
                            ),
                          ),
                          Text(
                            "${pet.age} years old",
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.grey,
                              fontSize: 16,
                              letterSpacing: -1.5,
                            ),
                          ),
                        ],
                      ), //Pet Name and short details
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Upcoming Medical",
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.black,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 20),
                          PetwiseUpcomingMedicalPill(),
                          PetwiseUpcomingMedicalPill(),
                          PetwiseUpcomingMedicalPill(),

                          SizedBox(height: 20),
                          Text(
                            "Recent Activity",
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.black,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 20),

                          PetwisePetActivityLog(),
                          PetwisePetActivityLog(),
                          PetwisePetActivityLog(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
