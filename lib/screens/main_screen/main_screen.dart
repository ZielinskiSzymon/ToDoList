import 'package:flutter/material.dart';
import 'package:to_do_list/screens/profile_screen/profile_screen.dart';
import 'package:to_do_list/screens/to_do_list_screen/to_do_list.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> bottomNavigationBarScreen = [ToDoListScreen(), ProfileScreen()];

  final List<BottomNavigationBarItem> bottomNavigationBarItems = [
    BottomNavigationBarItem(icon: Icon(Icons.list), label: "ToDo List"),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
    body: bottomNavigationBarScreen[_currentIndex],
    bottomNavigationBar:  BottomNavigationBar(
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
        print(index);
      },
      items: bottomNavigationBarItems,
      currentIndex: _currentIndex,
    ),
  );
}
