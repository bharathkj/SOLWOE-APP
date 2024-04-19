import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solwoe/auth.dart';
import 'package:solwoe/colors.dart';
import 'package:solwoe/screens/email_verification_screen.dart';
import 'package:solwoe/screens/forgot_password_screen.dart';

class LoginRegistrationScreen extends StatefulWidget {
  String type;
  LoginRegistrationScreen({Key? key, required this.type}) : super(key: key);

  @override
  State<LoginRegistrationScreen> createState() =>
      _LoginRegistrationScreenState();
}

class _LoginRegistrationScreenState extends State<LoginRegistrationScreen> {
  final formKey = GlobalKey<FormState>();
  String? type;
  bool _obscureText = true;
  String errorMessage = '';
  bool isLogin = true;
  String _emailController = '';
  String _passwordController = '';
  bool _loading = false;
  int _selectedIndex = 0;
  List<String> _userTypes = ['Patient', 'Doctor'];
  bool shouldProceedWithLogin = true; // Add this variable

  @override
  void initState() {
    super.initState();
    type = widget.type;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth()
          .signInWithEmailAndPassword(
        email: _emailController.trim(),
        password: _passwordController.trim(),
      )
          .then((message) async {
        if (shouldProceedWithLogin && message == 'Logged in') {
          // Fetch user's role from Firestore
          final userDoc = await FirebaseFirestore.instance.collection('users').doc(_emailController.trim()).get();
          if (userDoc.exists) {
            final userRole = userDoc.data()?['role'];
            if ((_selectedIndex == 0 && userRole == 'Self') ||
                (_selectedIndex == 1 && userRole == 'Parent')) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => const EmailVerificationScreen(),
                ),
              );
            } else {
              // Reset the page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginRegistrationScreen(type: type ?? '')),
              );

              // Show a dialog indicating wrong login
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Wrong Login'),
                    content: Text('Please make sure you have selected the correct user type.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('OK'),
                      ),
                    ],
                  );
                },
              );
            }
          } else {
            // User document does not exist, proceed with login
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => const EmailVerificationScreen(),
              ),
            );
          }
        } else {
          setState(() {
            errorMessage = message.toString();
            _loading = false;
          });
        }
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message.toString();
      });
    }
  }


  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Auth()
          .createUserWithEmailAndPassword(
        email: _emailController.trim(),
        password: _passwordController.trim(),
      )
          .then(
        (message) {
          if (message == 'Verification Link sent to Email') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message as String),
              ),
            );
            setState(() {
              type = 'Login';
              _loading = false;
            });
          } else {
            setState(() {
              errorMessage = message.toString();
              _loading = false;
            });
          }
        },
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstantColors.secondaryBackgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(type == 'Login' ? 'Login' : 'Registration'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 15.0,
                    right: 15.0,
                    top: 20,
                    bottom: 20,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        type == 'Login'
                            ? "Hey there, welcome back!"
                            : 'Create an Account',
                      ),
                      Text(
                        type == 'Login'
                            ? "Glad to have you here with us"
                            : "Register to become a part of our community",
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Form(
                        key: formKey,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 10.0,
                            right: 10.0,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              TextFormField(
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (value) {
                                  setState(() {
                                    _emailController = value;
                                  });
                                },
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.email,
                                  ),
                                  labelText: 'Enter E-mail ID',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  const pattern =
                                      r'(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)';
                                  final regExp = RegExp(pattern);

                                  if (value!.isEmpty) {
                                    return 'Enter an email';
                                  } else if (!regExp.hasMatch(value)) {
                                    return 'Enter a valid email';
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              TextFormField(
                                keyboardType: TextInputType.visiblePassword,
                                obscureText: _obscureText,
                                onChanged: (value) {
                                  setState(() {
                                    _passwordController = value;
                                  });
                                },
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(
                                    Icons.lock,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscureText
                                        ? Icons.visibility_off
                                        : Icons.visibility),
                                    onPressed: () {
                                      setState(() {
                                        _obscureText = !_obscureText;
                                      });
                                    },
                                  ),
                                  labelText: 'Enter Password',
                                  border: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value!.length < 7) {
                                    return 'Password must contain at least 7 characters';
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      Visibility(
                        visible: type == 'Login',
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 10.0,
                            right: 10.0,
                          ),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: TextButton(
                              child: Text(
                                'Forgot password ?',
                                style: GoogleFonts.rubik(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                    const ForgotPasswordScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 40.0,
                          right: 40.0,
                        ),
                        child: GestureDetector(
                          onTap: _loading
                              ? null
                              : () {
                            final isValid =
                            formKey.currentState!.validate();
                            FocusScope.of(context).unfocus();
                            if (isValid) {
                              formKey.currentState!.save();
                              if (_emailController.isNotEmpty &&
                                  _passwordController.isNotEmpty) {
                                setState(() {
                                  _loading = true;
                                });
                                type == 'Login'
                                    ? signInWithEmailAndPassword()
                                    : createUserWithEmailAndPassword();
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 80, vertical: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: ConstantColors.primaryBackgroundColor,
                            ),
                            child: _loading
                                ? const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ))
                                : Center(
                              child: Text(
                                type == 'Login' ? 'LOGIN' : 'REGISTER',
                                style: GoogleFonts.rubik(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: Visibility(
                          visible: errorMessage.isNotEmpty,
                          child: Text(
                            errorMessage,
                            style: GoogleFonts.rubik(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            type == 'Login'
                                ? 'Don\'t have an account yet ? '
                                : 'Already have an account ?',
                            style: GoogleFonts.rubik(
                                color: Colors.grey,
                                fontStyle: FontStyle.italic),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                if (type == 'Login') {
                                  type = 'Registration';
                                } else {
                                  type = 'Login';
                                }
                              });
                            },
                            child: Text(
                              type == 'Login' ? 'Register' : 'Login',
                              style: GoogleFonts.rubik(
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              ),
            ),
            BottomNavigationBar(
              items: _userTypes.map((type) {
                return BottomNavigationBarItem(
                  icon: Icon(Icons.account_circle),
                  label: type,
                );
              }).toList(),
              currentIndex: _selectedIndex,
              selectedItemColor: ConstantColors.primaryBackgroundColor,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}



/*
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: ConstantColors.secondaryBackgroundColor,
    resizeToAvoidBottomInset: false,
    appBar: AppBar(
      title: Text(type == 'Login' ? 'Login' : 'Registration'),
    ),
    body: SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 15.0,
                  right: 15.0,
                  top: 20,
                  bottom: 20,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      type == 'Login'
                          ? "Hey there, welcome back!"
                          : 'Create an Account',
                    ),
                    Text(
                      type == 'Login'
                          ? "Glad to have you here with us"
                          : "Register to become a part of our community",
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    Form(
                      key: formKey,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 10.0,
                          right: 10.0,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              onChanged: (value) {
                                setState(() {
                                  _emailController = value;
                                });
                              },
                              decoration: const InputDecoration(
                                prefixIcon: Icon(
                                  Icons.email,
                                ),
                                labelText: 'Enter E-mail ID',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                              ),
                              validator: (value) {
                                const pattern =
                                    r'(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)';
                                final regExp = RegExp(pattern);

                                if (value!.isEmpty) {
                                  return 'Enter an email';
                                } else if (!regExp.hasMatch(value)) {
                                  return 'Enter a valid email';
                                } else {
                                  return null;
                                }
                              },
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            TextFormField(
                              keyboardType: TextInputType.visiblePassword,
                              obscureText: _obscureText,
                              onChanged: (value) {
                                setState(() {
                                  _passwordController = value;
                                });
                              },
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Icons.lock,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscureText
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                  onPressed: () {
                                    setState(() {
                                      _obscureText = !_obscureText;
                                    });
                                  },
                                ),
                                labelText: 'Enter Password',
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value!.length < 7) {
                                  return 'Password must contain at least 7 characters';
                                } else {
                                  return null;
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Visibility(
                      visible: type == 'Login',
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 10.0,
                          right: 10.0,
                        ),
                        child: Align(
                          alignment: Alignment.topRight,
                          child: TextButton(
                            child: Text(
                              'Forgot password ?',
                              style: GoogleFonts.rubik(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                  const ForgotPasswordScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 40.0,
                        right: 40.0,
                      ),
                      child: GestureDetector(
                        onTap: _loading
                            ? null
                            : () {
                          final isValid =
                          formKey.currentState!.validate();
                          FocusScope.of(context).unfocus();
                          if (isValid) {
                            formKey.currentState!.save();
                            if (_emailController.isNotEmpty &&
                                _passwordController.isNotEmpty) {
                              setState(() {
                                _loading = true;
                              });
                              type == 'Login'
                                  ? signInWithEmailAndPassword()
                                  : createUserWithEmailAndPassword();
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 80, vertical: 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: ConstantColors.primaryBackgroundColor,
                          ),
                          child: _loading
                              ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ))
                              : Center(
                            child: Text(
                              type == 'Login' ? 'LOGIN' : 'REGISTER',
                              style: GoogleFonts.rubik(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: Visibility(
                        visible: errorMessage.isNotEmpty,
                        child: Text(
                          errorMessage,
                          style: GoogleFonts.rubik(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          type == 'Login'
                              ? 'Don\'t have an account yet ? '
                              : 'Already have an account ?',
                          style: GoogleFonts.rubik(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              if (type == 'Login') {
                                type = 'Registration';
                              } else {
                                type = 'Login';
                              }
                            });
                          },
                          child: Text(
                            type == 'Login' ? 'Register' : 'Login',
                            style: GoogleFonts.rubik(
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            ),
          ),
          BottomNavigationBar(
            items: _userTypes.map((type) {
              return BottomNavigationBarItem(
                icon: Icon(Icons.account_circle),
                label: type,
              );
            }).toList(),
            currentIndex: _selectedIndex,
            selectedItemColor: ConstantColors.primaryBackgroundColor,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ],
      ),
    ),
  );
}
}
*/