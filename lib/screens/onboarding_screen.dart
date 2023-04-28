import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:solwoe/auth.dart';
import 'package:solwoe/database.dart';
import 'package:solwoe/model/user.dart';

import 'package:solwoe/screens/home_screen.dart';
import 'package:solwoe/screens/welcome_screen.dart';
import 'package:csc_picker/csc_picker.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool isOnboardingDone = false;

  bool loader = true;
  final formKey = GlobalKey<FormState>();

  final TextEditingController _dateOfBirth = TextEditingController();

  String _email = '';

  String _name = '';

  String _gender = '';

  String _role = '';

  String _countryValue = '';

  String _stateValue = '';

  String _cityValue = '';

  @override
  void initState() {
    super.initState();
    _email = Auth().currentUser!.email.toString();
    _asyncMethod();
  }

  _asyncMethod() async {
    await Database().isOnboardingDone(_email).then((value) {
      setState(() {
        isOnboardingDone = value['onboarding'];
        loader = false;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> signOut(BuildContext context) async {
    await Auth().signOut().then(
          (value) => Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => const WelcomeScreen(),
            ),
          ),
        );
  }

  Future _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _dateOfBirth.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> onSubmit(Map<String, dynamic> json) async {
    await Database().setProfile(json);
  }

  @override
  Widget build(BuildContext context) {
    return loader
        ? Container(
            height: double.infinity,
            width: double.infinity,
            color: Colors.white,
            child: const Center(
                child: CircularProgressIndicator(
              backgroundColor: Colors.white,
            )),
          )
        : isOnboardingDone
            ? const HomeScreen()
            : Scaffold(
                resizeToAvoidBottomInset: false,
                drawerEnableOpenDragGesture: false,
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  centerTitle: true,
                  title: const Text(
                    'Set Profile',
                  ),
                  leading: Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(
                        Icons.menu,
                      ),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                ),
                drawer: Drawer(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.2,
                        child: const DrawerHeader(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                          ),
                          child: Center(
                            child: Text(
                              'SOLWOE',
                            ),
                          ),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.logout_rounded,
                        ),
                        title: const Text(
                          'Sign Out',
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          signOut(context);
                        },
                      ),
                    ],
                  ),
                ),
                body: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Form(
                        key: formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 10.0,
                                right: 10.0,
                                top: 10.0,
                              ),
                              child: TextFormField(
                                keyboardType: TextInputType.name,
                                onChanged: (value) {
                                  setState(() {
                                    _name = value;
                                  });
                                },
                                maxLength: 30,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(0),
                                  icon: Icon(
                                    Icons.person,
                                    color: Colors.black,
                                  ),
                                  labelText: 'Full Name',
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Enter your full name';
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 10.0,
                                right: 10.0,
                                top: 10.0,
                              ),
                              child: TextFormField(
                                keyboardType: TextInputType.datetime,
                                autocorrect: false,
                                controller: _dateOfBirth,
                                onSaved: (value) {
                                  _dateOfBirth.text = value.toString();
                                },
                                onTap: () {
                                  _selectDate();
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                },
                                maxLines: 1,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Choose Date';
                                  } else {
                                    return null;
                                  }
                                },
                                readOnly: true,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(0),
                                  labelText: 'Date of Birth',
                                  //filled: true,
                                  icon: Icon(Icons.calendar_today),
                                ),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(
                                    top: 20.0,
                                    bottom: 5.0,
                                    left: 50.0,
                                  ),
                                  child: Text(
                                    "Gender",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.only(
                                          top: 10.0, bottom: 10.0, left: 36.0),
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.08,
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      child: Row(
                                        children: [
                                          Radio(
                                            value: "Male",
                                            groupValue: _gender,
                                            onChanged: (value) {
                                              setState(() {
                                                _gender = value.toString();
                                              });
                                            },
                                          ),
                                          const Text(
                                            "Male",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          Radio(
                                            value: "Female",
                                            groupValue: _gender,
                                            onChanged: (value) {
                                              setState(() {
                                                _gender = value.toString();
                                              });
                                            },
                                          ),
                                          const Text(
                                            "Female",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(
                                    top: 20.0,
                                    bottom: 5.0,
                                    left: 50.0,
                                  ),
                                  child: Text(
                                    "Role",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.only(
                                          top: 10.0, bottom: 10.0, left: 36.0),
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.08,
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      child: Row(
                                        children: [
                                          Radio(
                                            value: "Self",
                                            groupValue: _role,
                                            onChanged: (value) {
                                              setState(() {
                                                _role = value.toString();
                                              });
                                            },
                                          ),
                                          const Text(
                                            "Self",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          Radio(
                                            value: "Parent",
                                            groupValue: _role,
                                            onChanged: (value) {
                                              setState(() {
                                                _role = value.toString();
                                              });
                                            },
                                          ),
                                          const Text(
                                            "Ward's Parent",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.25,
                              width: MediaQuery.of(context).size.width * 0.8,
                              padding: const EdgeInsets.only(
                                top: 10.0,
                                left: 10.0,
                                right: 20.0,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  const Text(
                                    "Location",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20.0,
                                  ),
                                  CSCPicker(
                                    ///placeholders for dropdown search field
                                    countrySearchPlaceholder: "Country",
                                    stateSearchPlaceholder: "State",
                                    citySearchPlaceholder: "City",

                                    onCountryChanged: (value) {
                                      setState(() {
                                        _countryValue = value.toString();
                                      });
                                    },
                                    onStateChanged: (value) {
                                      setState(() {
                                        _stateValue = value.toString();
                                      });
                                    },
                                    onCityChanged: (value) {
                                      setState(() {
                                        _cityValue = value.toString();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          final isValid = formKey.currentState!.validate();
                          FocusScope.of(context).unfocus();
                          if (isValid) {
                            formKey.currentState!.save();
                            if (_name.isNotEmpty &&
                                _dateOfBirth.text.isNotEmpty &&
                                _gender.isNotEmpty &&
                                _role.isNotEmpty &&
                                _countryValue.isNotEmpty &&
                                _stateValue != 'null' &&
                                _cityValue != 'null') {
                              final user = UserProfile(
                                onboarding: true,
                                email: _email,
                                name: _name,
                                dateOfBirth: _dateOfBirth.text,
                                gender: _gender,
                                role: _role,
                                country: _countryValue,
                                state: _stateValue,
                                city: _cityValue,
                              );
                              final json = user.toJson();

                              onSubmit(json).then(
                                (value) =>
                                    Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => const HomeScreen(),
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please Enter all Fields'),
                                ),
                              );
                            }
                          }
                        },
                        child: const Text("Submit"),
                      ),
                    ],
                  ),
                ),
              );
  }
}
