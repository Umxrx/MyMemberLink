import 'package:flutter/material.dart';
import 'package:mymemberlink/views/auth/register_screen.dart';
import 'package:mymemberlink/test/testconfig.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  RegExp get _emailRegex => RegExp(r'^\S+@\S+$');
  bool rememberme = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(style: TextStyle(fontSize: 20, color: Colors.blue, fontWeight: FontWeight.bold), "My Member Link"),
                  const SizedBox(height: 40,),
                  TextFormField(
                    controller: emailcontroller,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email address',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email address';
                      }
                      else if (!_emailRegex.hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20,),
                  TextFormField(
                    controller: passwordcontroller,
                    obscureText: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      else if (value.length < 8) {
                        return 'Password must be at least 8 characters long';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Checkbox(value: rememberme, onChanged: checked, activeColor: Colors.blue,),
                      const Text("Remember me"),
                    ],
                  ),
                  const SizedBox(height: 10,),
                  MaterialButton(
                    onPressed: onLogin,
                    elevation: 5,
                    minWidth: 400,
                    height: 50,
                    color: Colors.blue,
                    child: const Text(style: TextStyle(
                      color: Colors.white,
                    ), 'Login'),
                  ),
                  const SizedBox(height: 15,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                            MaterialPageRoute(builder: (context) => const RegisterScreen())
                          );
                        },
                        child: const Text(style: TextStyle(color: Colors.blue), 'Don\'t have an account? Register'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          ),
        ),
    );
  }
  
  onLogin() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text(style: TextStyle(color: Colors.white), 'Processing'),
        backgroundColor: Colors.green[700],
        duration: const Duration(seconds: 2),
      ));
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(style: TextStyle(color: Colors.white), 'Please fill out all fields correctly'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
    }
  }

  void checked(bool? value) {
    setState(() {
      rememberme = value!;
    });
  }

  void testConfig() {
    TestConfig().printIps();
  }
}