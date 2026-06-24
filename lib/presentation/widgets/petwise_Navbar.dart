import 'package:flutter/material.dart';
import 'package:petwise/routes/app_route.dart';

class PetwiseNavbar extends StatelessWidget {
  final int navbarIndex;

  const PetwiseNavbar({super.key, required this.navbarIndex});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      elevation: 18,
      shadowColor: Colors.black,
      notchMargin: 8,
      color: Colors.white,
      shape: const AutomaticNotchedShape(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        ),
        CircleBorder(),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: () {
              final route = ModalRoute.of(context)?.settings.name;
              if (route != AppRoute.userHomePage) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoute.userHomePage,
                  (r) => false,
                );
              }
            },
            icon: Icon(
              Icons.home,
              color: navbarIndex == 0 ? const Color(0xFFF7A433) : const Color(0xFF94A3B8),
            ),
          ),
          IconButton(
            onPressed: () {
              final route = ModalRoute.of(context)?.settings.name;
              if (route != AppRoute.analyticsScreen) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoute.analyticsScreen,
                  (r) => false,
                );
              }
            },
            icon: Icon(
              Icons.bar_chart,
              color: navbarIndex == 1 ? const Color(0xFFF7A433) : const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(width: 50),
          IconButton(
            onPressed: () {
              final route = ModalRoute.of(context)?.settings.name;
              if (route != AppRoute.petActivityPlanner) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoute.petActivityPlanner,
                  (r) => false,
                );
              }
            },
            icon: Icon(
              Icons.calendar_month_rounded,
              color: navbarIndex == 2 ? const Color(0xFFF7A433) : const Color(0xFF94A3B8),
            ),
          ),
          IconButton(
            onPressed: () {
              final route = ModalRoute.of(context)?.settings.name;
              if (route != AppRoute.petCardScreen) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoute.petCardScreen,
                  (r) => false,
                );
              }
            },
            icon: Icon(
              Icons.pets,
              color: navbarIndex == 3 ? const Color(0xFFF7A433) : const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}
