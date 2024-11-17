import 'package:flutter/material.dart';
import 'package:mymemberlink/auth/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  bool rememberme = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(style: TextStyle(fontSize: 20, color: Colors.blue, fontWeight: FontWeight.bold), "My Member Link"),
              //Image.asset('MemberLink-Icon-512.png'),
              const SizedBox(height: 20),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: TextFormField(
                controller: emailcontroller,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: "Email address",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email address';
                  }
                  return null;
                },
              ),),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: TextFormField(
                  controller: passwordcontroller,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: "Password",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Checkbox(value: rememberme, activeColor: Colors.blue, onChanged:(value) {
                      rememberme = value!;
                      setState(() {});
                    },),
                    const Text("Remember me"),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: MaterialButton(
                  elevation: 5,
                  minWidth: 400,
                  height: 50,
                  onPressed: onLogin,
                  color: Colors.blue,
                  child: const Text(
                    style: TextStyle(color: Colors.white),
                    "Login"),
                  ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: noAccount,
                      child: const Text(style: TextStyle(color: Colors.blue), "Don't have an account?"),
                    ),
                  ],
                ),
              ),
            ],
          )
        )
      ),
    );
  }
  
  onLogin() {
    if (emailcontroller.text.isEmpty || passwordcontroller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(style: TextStyle(color: Colors.white), "Please enter all credentials..."), backgroundColor: Colors.red, duration: Duration(seconds: 2),));
    }
    setState(() {});
  }


  void noAccount() {
    Navigator.push(context,
      MaterialPageRoute(builder: (context) => const RegisterScreen())
    );
  }
}