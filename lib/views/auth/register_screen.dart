import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mymemberlink/myconfig.dart';
//import 'package:mymemberlink/myconfig.dart';
//import 'package:mymemberlink/test/testconfig.dart' as tconfig;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController namecontroller = TextEditingController();
  TextEditingController phonecontroller = TextEditingController();
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  TextEditingController confirmpasswordcontroller = TextEditingController();
  RegExp get _emailRegex => RegExp(r'^\S+@\S+$');
  String password = '';

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
                    controller: namecontroller,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Fullname',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your fullname';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20,),
                  TextFormField(
                    controller: phonecontroller,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Phone',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      else if (value.length > 20) {
                        return 'Your phone is too long (max 20 characters)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20,),
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
                      else if (value.length > 100) {
                        return 'Your email is too long (max 100 characters)';
                      }
                      else if (isEmailExist(value) == 'existed') {
                        return 'Your email has been registered before';
                      }
                      else if (isEmailExist(value) == 'uri problem') {
                        return 'Something went wrong';
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
                      else if (value.length > 80) {
                        return 'Password is too long (max 80 characters)';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        password = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20,),
                  TextFormField(
                    controller: confirmpasswordcontroller,
                    obscureText: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Confirm password',
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red)
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      else if (value != password) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20,),
                  MaterialButton(
                    onPressed: onRegister,
                    elevation: 5,
                    minWidth: 400,
                    height: 50,
                    color: Colors.blue,
                    child: const Text(style: TextStyle(
                      color: Colors.white,
                    ), 'Register'),
                  ),
                  const SizedBox(height: 15,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Text(style: TextStyle(color: Colors.blue), 'Already have an account? Login'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          ),
        ),
      );
  }

  void onRegister() {
    if (_formKey.currentState!.validate()) {
      String username  = namecontroller.text;
      String email     = emailcontroller.text;
      String userphone = phonecontroller.text;
      String password  = passwordcontroller.text;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text(style: TextStyle(color: Colors.white), 'Processing'),
        backgroundColor: Colors.green[700],
        duration: const Duration(seconds: 2),
      ));
      //String host = await tconfig.TestConfig().getIp();
      http.post(
        //Uri.parse("$host/memberlink/api/user_register.php"),
        Uri.parse("${MyConfig.servername}/memberlink/api/user_register.php"),
        body: {"username": username, "email": email, "userphone": userphone, "password": password}).then((response) {
          if (response.statusCode == 200) {
            var data = jsonDecode(response.body);
            if (data['status'] == 'success') {
              _formKey.currentState?.reset();
              haveAccount();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text(style: TextStyle(color: Colors.white), 'Your account successfully created'),
                backgroundColor: Colors.green[700],
                duration: const Duration(seconds: 2),
              ));
            }
            else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text(style: TextStyle(color: Colors.white), 'Registration failed'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 2),
              ));
            }
          }
          else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(style: TextStyle(color: Colors.white), 'Something went wrong'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ));
          }
        });
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(style: TextStyle(color: Colors.white), 'Please fill out all fields correctly'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ));
    }
  }

  void haveAccount() {
    Navigator.pop(context);
  }

  String isEmailExist(String newEmail) {
    //String ipAdd = await tconfig.TestConfig().getIp();
    http.post(
      //Uri.parse("$ipAdd/memberlink/api/user_register.php"),
      Uri.parse("${MyConfig.servername}/memberlink/api/user_register.php"),
      body: {"email": newEmail}
    ).then((response) {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return 'existed';
        }
        else {
          return 'not exist';
        }
      }
      else {
        return 'uri problem';
      }
    });
    return '';
  }

  void userRegistration() {
    String username  = namecontroller.text;
    String email     = emailcontroller.text;
    String userphone = phonecontroller.text;
    String password  = passwordcontroller.text;
    //String host = await tconfig.TestConfig().getIp();
    http.post(
        //Uri.parse("$host/memberlink/api/user_register.php"),
        Uri.parse("${MyConfig.servername}/memberlink/api/user_register.php"),
        body: {"username": username, "email": email, "userphone": userphone, "password": password}).then((response) {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == "success") {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Registration Success"),
            backgroundColor: Color.fromARGB(255, 12, 12, 12),
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Registration Failed"),
            backgroundColor: Colors.red,
          ));
        }
      }
    });
  }
}