import 'package:flutter/material.dart';
import 'tecnicos_screen.dart';
import '../widgets/solicitudes_list_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const SolicitudesListView(estado: 'Pendiente'),
    const TecnicosScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FixNow Admin"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: "Solicitudes"),
          BottomNavigationBarItem(icon: Icon(Icons.engineering), label: "Técnicos"),
        ],
      ),
    );
  }
}