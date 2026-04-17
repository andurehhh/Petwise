import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:petwise/data/models/pet_model.dart';
import 'package:petwise/presentation/widgets/petwise_user_textField.dart';
import 'package:petwise/providers/PetProvider.dart';
import 'package:petwise/routes/app_route.dart';
import 'package:provider/provider.dart';


class EditPetProfileScreen extends StatefulWidget {
  const EditPetProfileScreen({super.key});

  @override
  State<EditPetProfileScreen> createState() => _EditPetProfileScreenState();
}

class _EditPetProfileScreenState extends State<EditPetProfileScreen> {
  late TextEditingController _petNameController;
  late TextEditingController _petSpeciesController;
  late TextEditingController _petAgeController;
  late TextEditingController _petWeightController;

  @override
  void initState() {
    super.initState();
    final pet = context.read<PetProvider>().selectedPet;

    _petNameController = TextEditingController(text: pet?.name ?? "");
    _petSpeciesController = TextEditingController(text: pet?.species?? "");
    _petAgeController = TextEditingController(text: pet?.age.toString()?? "0");
    _petWeightController = TextEditingController(text: pet?.sex?? "");
  }

  @override
    void dispose() {
    _petAgeController.dispose();
    _petNameController.dispose();
    _petSpeciesController.dispose();
    _petWeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pet = context.watch<PetProvider>().selectedPet;

    return
      Scaffold(
        backgroundColor: Color(0xFFF8F7F6),
        extendBody: true,
        appBar: AppBar(
          leading:
          IconButton(
              onPressed: (){
                Navigator.pop(context);
              },
              icon: Icon(CupertinoIcons.back)),
        ),
        body: SingleChildScrollView(
            child: SizedBox(
              width: double.infinity,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 72,
                          backgroundColor: Color(0xFFF7A433),
                          child: CircleAvatar(
                            radius: 70,
                            backgroundImage: AssetImage(
                                'assets/images/doggie.gif'),
                            child: CircleAvatar(
                              backgroundColor: Colors.black26,
                              radius: 70,
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                      width: 40,
                    ),
                    Text("${pet?.name}",
                      style: GoogleFonts.plusJakartaSans(fontSize: 23, fontWeight: FontWeight.bold, letterSpacing: -1.5),
                    ),
                    SizedBox(
                      width: 10,
                      height: 5,
                    ),
                    Container(
                      width: 150,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCDCDC),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                      width: 40,
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                          maxWidth: 1000
                      ),
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          // color: Colors.pink,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text("BASIC INFORMATION",
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: Color(0xFF92A1B7),

                              ),
                            ),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                  ),
                                  PetwiseUserTextfield(textLabel: "Pet Name",textHint:  "Enter Pet Name here", controller: _petNameController, isEditable: true,),
                                  PetwiseUserTextfield(textLabel: "Breed",textHint:  "Enter pet Breed here", controller: _petSpeciesController, isEditable: true,),

                                  ConstrainedBox(
                                    constraints:
                                    BoxConstraints(
                                      maxWidth: 800,
                                    ),
                                    child:
                                    Row(
                                      children: [
                                        Expanded(child:
                                        PetwiseUserTextfield(textLabel: "Age (in Years)",textHint:  "${pet?.age}", controller: _petAgeController,),
                                        ),
                                        Expanded(child:
                                        PetwiseUserTextfield(textLabel: "Weight (Kg)",textHint:  "${pet?.sex}", controller: _petWeightController)
                                        ),
                                      ],
                                    ),
                                  ),

                                  ConstrainedBox(
                                      constraints: BoxConstraints(
                                          maxWidth: 800,
                                          minWidth: 40
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 50,
                                            height: 30,
                                          ),
                                          FilledButton(
                                              onPressed: () {
                                                print("DEBUG Controller First: ${_petNameController.text}");

                                                String newPetName = _petNameController.text;
                                                String newPetSpecies = _petSpeciesController.text;
                                                String newPetAge = _petAgeController.text;
                                                String newPetWeight = _petWeightController.text;


                                                context.read<PetProvider>().updatePetInfo(newPetName, newPetSpecies);

                                                ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                      content: Text("Pet Info Updated!"),
                                                      backgroundColor: Colors.lightGreen,)
                                                );
                                                Navigator.pop(context);
                                              },
                                              style: FilledButton.styleFrom(
                                                  minimumSize: const Size(
                                                      300, 50),
                                                  backgroundColor: Color(
                                                      0xFFF7A433),
                                                  side: const BorderSide(
                                                    color: Color(0xFFDA9B44),
                                                    width: 2,
                                                  )
                                              ),
                                              child: Text("SAVE CHANGES",
                                                  style: GoogleFonts
                                                      .plusJakartaSans(
                                                      color: Color(0xFFFFFFFF),
                                                      fontWeight: FontWeight
                                                          .bold)
                                              )
                                          ),
                                          SizedBox(
                                            width: 50,
                                            height: 15,
                                          ),
                                          OutlinedButton(
                                              onPressed: () {
                                                Navigator.pop(context);

                                              },
                                              style: OutlinedButton.styleFrom(
                                                  minimumSize: const Size(
                                                      300, 50),
                                                  side: const BorderSide(
                                                      color: Color(0xFFF7A433),
                                                      width: 2
                                                  )
                                              ),
                                              child: Text("CANCEL",
                                                style: GoogleFonts
                                                    .plusJakartaSans(
                                                    color: Color(0xFFF7A433),
                                                    fontWeight: FontWeight
                                                        .bold),
                                              )
                                          ),
                                        ],
                                      ))

                                ]
                            ),
                          ],
                        ),
                      ),
                    )



                  ]
              ),
            )
        ),

        // floatingActionButton: FloatingActionButton(
        //   onPressed: (){
        //
        //   },
        //   backgroundColor: Color(0xFFF7A433),
        //   shape: CircleBorder(),
        //   child: Icon(Icons.add, color: Colors.white,)
        // ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        // bottomNavigationBar: PetwiseNavbar(navbarIndex: 4)
      );
  }
}
