// import 'package:flutter/material.dart';
//
// void main(){
//   runApp(
//     const MaterialApp(
//       title: 'My app',
//       home: SafeArea(
//         child: MyScaffold(),
//       ),
//     ),
//   );
// }
//
// class MyAppBar extends StatelessWidget {
//   const MyAppBar({required this.title, super.key});
//
//   // field in a Widget subclass are always marked "final".
//   final Widget title;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 56, //in local pixels
//       padding: const EdgeInsets.symmetric(horizontal: 8),
//       decoration: BoxDecoration(color: Colors.blue[500]),
//
//       // row is a horizontal, linear layout
//       child: Row(
//         children: [
//           IconButton(
//               onPressed: (){
//
//               },
//               icon: Icon(Icons.menu),
//               tooltip: 'Navigation menu',
//           ),
//           // Expanded expands its child
//           // to fill the available space
//           Expanded(
//             child: title,
//           ),
//           const IconButton(
//               onPressed: null,
//               icon: Icon(Icons.search),
//               tooltip: 'Search',
//           )
//         ],
//       ),
//     );
//   }
// }
//
// class MyScaffold extends StatelessWidget {
//   const MyScaffold({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     // Material is a conceptual piece
//     // of paper on which the UI appears.
//     return Material(
//       child: Column(
//         children: [
//           MyAppBar(
//             title: Text(
//               'Example title',
//               style: Theme.of(context)
//                 .primaryTextTheme
//                 .titleLarge,
//             ),
//           ),
//           const Expanded(
//             child: Center(
//               child: Text("Hello, world!"),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//


import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const appTitle = 'Drawer Demo';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: appTitle,
      home: MyHomePage(title: appTitle),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: Home',
      style: optionStyle,
    ),
    Text(
      'Index 1: Business',
      style: optionStyle,
    ),
    Text(
      'Index 2: School',
      style: optionStyle,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: _widgetOptions[_selectedIndex],
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Drawer Header'),
            ),
            ListTile(
              title: const Text('Home'),
              selected: _selectedIndex == 0,
              onTap: () {
                // Update the state of the app
                _onItemTapped(0);
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Business'),
              selected: _selectedIndex == 1,
              onTap: () {
                // Update the state of the app
                _onItemTapped(1);
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('School'),
              selected: _selectedIndex == 2,
              onTap: () {
                // Update the state of the app
                _onItemTapped(2);
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}