import 'package:flutter/material.dart';
import 'package:mymemberlink/views/events/event_screen.dart';
import 'package:mymemberlink/views/newsletter/main_screen.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
                // You can add color or other styling here if needed
                ),
            child: Text('Drawer Header'),
          ),
          ListTile(
            onTap: () {
              // Define onTap actions here if needed
              Navigator.pop(context);
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const MainScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0); // Slide in from the right
                    const end = Offset.zero;
                    const curve = Curves.ease;

                    var tween = Tween(begin: begin, end: end)
                        .chain(CurveTween(curve: curve));
                    var offsetAnimation = animation.drive(tween);
                    
                    return SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    );
                  },
                ),
              );

              //  Navigator.push(context,
              //   MaterialPageRoute(builder: (content) => const MainScreen()));
            },
            title: const Text("Newsletter"),
          ),
          ListTile(
            title: const Text("Events"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const EventScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0); // Slide in from the right
                    const end = Offset.zero;
                    const curve = Curves.ease;

                    var tween = Tween(begin: begin, end: end)
                        .chain(CurveTween(curve: curve));
                    var offsetAnimation = animation.drive(tween);

                    return SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    );
                  },
                ),
              );

              // Navigator.push(context,
              //     MaterialPageRoute(builder: (content) => const EventScreen()));
            },
          ),
          const ListTile(
            title: Text("Members"),
          ),
          const ListTile(
            title: Text("Payments"),
          ),
          const ListTile(
            title: Text("Products"),
          ),
          const ListTile(
            title: Text("Vetting"),
          ),
          const ListTile(
            title: Text("Settings"),
          ),
          const ListTile(
            title: Text("Logout"),
          ),
        ],
      ),
    );
  }
}