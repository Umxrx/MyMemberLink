// import 'dart:convert';
// import 'dart:developer';
// import 'package:mymemberlink/model/cart.dart';
// import 'package:mymemberlink/myconfig.dart';
// import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:mymemberlink/model/user.dart';
import 'package:mymemberlink/views/events/event_screen.dart';
import 'package:mymemberlink/views/newsletter/main_screen.dart';
import 'package:mymemberlink/views/products/products_screen.dart';

class MyDrawer extends StatelessWidget {
  final User user;
  const MyDrawer({super.key, required this.user});

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
                      MainScreen(
                        user: user,
                      ),
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
                      EventScreen(
                        user: user,
                      ),
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
          ListTile(
            title: const Text("Products"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      ProductsScreen(
                        user: user,
                        //cartList: loadCart(),
                      ),
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
            },
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

  // List<Cart> loadCart() {
  //   List<Cart> cartList = [];
  //   http
  //       .get(Uri.parse("${MyConfig.servername}/memberlink/api/load_cart.php?userid=${widget.user.userId.toString()}"))
  //       .then((response) {
  //     log(response.body.toString());
  //     if (response.statusCode == 200) {
  //       var data = jsonDecode(response.body);
  //       if (data['status'] == "success") {
  //         var result = data['data']['cart'];
  //         cartList.clear();
  //         for (var item in result) {
  //           Cart myproducts = Cart.fromJson(item);
  //           cartList.add(myproducts);
  //         }
  //       }
  //     }
  //   });
  //   return cartList;
  // }
}