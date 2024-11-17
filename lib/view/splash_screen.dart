import 'package:flutter/material.dart';
import 'package:mymemberlink/auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4), () {
      // ignore: use_build_context_synchronously
      Navigator.push(context,
        MaterialPageRoute(builder: (context) => const LoginScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(style: TextStyle(fontSize: 40, color: Colors.blue, fontWeight: FontWeight.bold), "My Member Link"),
            //Image.asset('assets/MemberLink-Icon-512.png'),
          SizedBox(height: 20,),
          CircularProgressIndicator(),],
        ),
      ),
    );
  }
}