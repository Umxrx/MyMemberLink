import 'dart:convert';
import 'dart:developer';

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
  bool _emailTaken = false;
  String password = '';
  DateTime loginClickTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
  _formKey.currentState?.validate();
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
                        return 'Your phone number is too long (max 20 characters)';
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
                      else if (!_emailTaken) {
                        return 'Email is already taken';
                        //http.post(
                        //  Uri.parse("${MyConfig.servername}/memberlink/api/email_exist.php"),
                        //  body: {"email": value,},
                        //).then((response) {
                        //  if (response.statusCode == 200) {
                        //    var data = jsonDecode(response.body);
                        //    if (data['status'] == 'success') {
                        //      print('existed');
                        //      return 'This email has been registered before';
                        //    }
                        //    else {
                        //      print('not exist');
                        //      return null;
                        //    }
                        //  }
                        //  else {
                        //    print('uri problem');
                        //    return 'Something went wrong';
                        //  }
                        //});
                      }
                      else {
                        return null;
                      }
                    },
                    onChanged: (value) {
                      _checkEmail(value);
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
                          haveAccount();
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
      String userPassword  = passwordcontroller.text;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text(style: TextStyle(color: Colors.white), 'Processing'),
        backgroundColor: Colors.green[700],
        duration: const Duration(seconds: 2),
      ));
      //String host = await tconfig.TestConfig().getIp();
      http.post(
        //Uri.parse("$host/memberlink/api/user_register.php"),
        Uri.parse("${MyConfig.servername}/memberlink/api/user_register.php"),
        body: {"username": username, "email": email, "userphone": userphone, "password": userPassword})
        .then((response) {
          if (response.statusCode == 200) {
            var data = jsonDecode(response.body);
            if (data['status'] == 'success') {
              setState(() {
                _formKey.currentState?.reset();
              });
              
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

  Future<String> isEmailExist(String newEmail) async {
    if (newEmail != '') {
      //String ipAdd = await tconfig.TestConfig().getIp();
      
      return 'objective null';
    }
    else {
      return 'null';
    }
  }

  bool isRedundentClick(DateTime currentTime) {
    log('diff is ${currentTime.difference(loginClickTime).inSeconds}');
    if (currentTime.difference(loginClickTime).inSeconds < 5) {
      // set this difference time in seconds
      return true;
    }

    loginClickTime = currentTime;
    return false;
  }

  _checkEmail(String emailCheck) {
    http.post(
      Uri.parse("${MyConfig.servername}/memberlink/api/email_exist.php"),
      body: {"email": emailCheck,},
    ).then((response) {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          print('existed');
          //return 'This email has been registered before';
          setState(() {
            _emailTaken = false;
          });
        }
        else {
          print('not exist');
          //return null;
          setState(() {
            _emailTaken = true;
          });
        }
      }
      else {
        print('uri problem');
        //return 'Something went wrong';
        setState(() {
          _emailTaken = false;
        });
      }
    });
  }
}