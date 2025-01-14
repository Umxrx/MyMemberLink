import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:mymemberlink/model/user.dart';
import 'package:mymemberlink/myconfig.dart';
import 'package:mymemberlink/views/newsletter/main_screen.dart';
import 'package:mymemberlink/views/auth/register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

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
  bool _isEmailExist = false;
  bool rememberme = false;

  @override
  void initState() {
    super.initState();

    loadPref();
  }

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
                  const Text(style: TextStyle(fontSize: 20,color: Colors.blue,fontWeight: FontWeight.bold),
                    "My Member Link"
                  ),
                  const SizedBox(height: 40,),
                  TextFormField(controller: emailcontroller,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Email address',),
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
                      else if (!_isEmailExist) {
                        return 'This email has not been registered yet';
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
                      return null;
                    },
                  ),
                  const SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Checkbox(value: rememberme, onChanged: _checked, activeColor: Colors.blue,),
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
                        onTap: () async {
                          // ignore: unused_local_variable
                          final what = await Navigator.push(context,
                            MaterialPageRoute(builder: (context) => const RegisterScreen())
                          ).then((value) {
                            setState(() {
                              loadPref();
                            });
                          },);
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
      String email         = emailcontroller.text;
      String userPassword  = passwordcontroller.text;
      http.post(
        //Uri.parse("$host/memberlink/api/user_login.php"),
        Uri.parse("${MyConfig.servername}/memberlink/api/user_login.php"),
        body: {"email": email, "password": userPassword}).then((response) {
          if (response.statusCode == 200) {
            var data = jsonDecode(response.body);
            if (data['status'] == 'success') {
              User user = User.fromJson(data['data']);
              setState(() {
                _formKey.currentState?.reset();
              });
              Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (context) => MainScreen(
                  user: user,
                )), (_) => false);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text(style: TextStyle(color: Colors.white), 'Login successful'),
                backgroundColor: Colors.green[700],
                duration: const Duration(seconds: 2),
              ));
            }
            else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text(style: TextStyle(color: Colors.white), 'Incorrect password'),
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

  void _checked(bool? value) {
    setState(() {
      String email = emailcontroller.text;
      String pass = passwordcontroller.text;
      if (value!) {
        if (email.isNotEmpty && pass.isNotEmpty) {
          storeSharedPrefs(value, email, pass);
        } else {
          rememberme = false;
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(
            content: Text(style: TextStyle(color: Colors.white), "Please enter your credentials"),
            backgroundColor: Colors.red,
          ));
          return;
        }
      } else {
        email = "";
        pass = "";
        storeSharedPrefs(value, email, pass);
      }
      rememberme = value;
      setState(() {});
    });
  }

  Future<void> storeSharedPrefs(bool value, String email, String pass) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value) {
      prefs.setString("email", email);
      prefs.setString("password", pass);
      prefs.setBool("rememberme", value);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Preferences Stored"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ));
    } else {
      prefs.setString("email", email);
      prefs.setString("password", pass);
      prefs.setBool("rememberme", value);
      emailcontroller.text = "";
      passwordcontroller.text = "";
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Preferences Removed"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 1),
      ));
    }
  }

  Future<void> loadPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String savedEmail = prefs.getString("email") ?? "";
    bool savedRememberMe = prefs.getBool("rememberme") ?? false;
    emailcontroller.text = savedEmail;
    passwordcontroller.text = prefs.getString("password") ?? "";
    rememberme = savedRememberMe;
    savedRememberMe != true
    ? setState(() {})
    : setState(() {
      _checkEmail(savedEmail);
    });
  }

  _checkEmail(String emailCheck) {
    String trimmed = emailCheck.trim();
    http.post(
      Uri.parse("${MyConfig.servername}/memberlink/api/email_exist.php"),
      body: {"email": trimmed,},
    ).then((response) {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          log('$emailCheck exist');
          //return 'This email has been registered';
          if (mounted) {
            setState(() {
              _isEmailExist = true;
            });
          }
        }
        else {
          log('$emailCheck not exist');
          //return null;
          setState(() {
            _isEmailExist = false;
          });
        }
      }
      else {
        log('uri problem');
        //return 'Something went wrong';
        setState(() {
          _isEmailExist = false;
        });
      }
    });
  }
}