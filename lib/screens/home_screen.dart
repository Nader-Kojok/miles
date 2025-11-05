import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'new_catalog_screen.dart';
import 'new_orders_screen.dart';
import 'assistance_screen.dart';
import 'favorites_screen.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/vehicle_selector_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    const NewCatalogScreen(),
    const NewOrdersScreen(),
    const AssistanceScreen(),
    const FavoritesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Open vehicle selector sheet from bottom to top
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const VehicleSelectorSheet(),
          );
        },
        backgroundColor: Colors.black,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SvgPicture.asset(
            'assets/icon_only_logo_miles.svg',
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
