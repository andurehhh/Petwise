import 'package:flutter/material.dart';
import '../widgets/petwise_pet_profile.dart';
import '../widgets/petwise_activity_card.dart';

class UserHomePageScreen extends StatefulWidget {
  const UserHomePageScreen({super.key});

  @override
  State<UserHomePageScreen> createState() => _UserHomePageScreenState();
}

class _UserHomePageScreenState extends State<UserHomePageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F7F6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset('assets/images/logo.png', height: 40),
                  Row(
                    children: const [
                      Icon(Icons.notifications_none, size: 28),
                      SizedBox(width: 15),
                      Icon(Icons.person_outline, size: 28),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 25),
              const Text(
                "Good morning, Mia!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Text(
                "They are having a great day so far.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Pets",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text("See all", style: TextStyle(color: Colors.orange)),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  PetCircle(
                    imagePath: 'assets/images/dog.png',
                    petName: 'Draeco',
                    petType: 'Pomeranian',
                  ),
                  PetCircle(
                    imagePath: 'assets/images/cat.png',
                    petName: 'Rence',
                    petType: 'British Shorthair',
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Upcoming Activities",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text("See all", style: TextStyle(color: Colors.orange)),
                ],
              ),
              const SizedBox(height: 15),
              const ActivityCard(
                title: 'Vet Appointment',
                subtitle: '10:00 AM',
                //status: 'Today',
              ),
              const ActivityCard(
                title: 'Grooming',
                subtitle: '2:00 PM',
                //status: 'Tomorrow', wag mo forget add tau sa card
              ),
            ],
          ),
        ),
      ),
    );
  }
}
