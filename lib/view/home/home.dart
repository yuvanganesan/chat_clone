import 'package:flutter/material.dart';
import '../screens/call_list.dart' show CallList;
import '../screens/people_list.dart';
import '../screens/settings.dart';
import '../screens/chat_list.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var _selectedIndex = 1;
  final List<Widget> screens = const [
    ChatList(),
    CallList(),
    PeopleList(),
    Settings()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
        'Chat Clone',
        style: TextStyle(color: Color(0xff263b43)),
      )),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.call), label: 'Call'),
          BottomNavigationBarItem(icon: Icon(Icons.contacts), label: 'People'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings')
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xfff2c40f),
        unselectedItemColor: const Color(0xff263b43),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
