import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solwoe/auth.dart';
import 'package:flutter/material.dart';
import 'package:solwoe/colors.dart';
import 'package:solwoe/model/user.dart';
import 'package:solwoe/screens/about_screen.dart';
import 'package:solwoe/screens/assessmentDetail_screen.dart';
import 'package:solwoe/screens/care_screen.dart';
import 'package:solwoe/screens/dashboard_screen.dart';
import 'package:solwoe/screens/manam_call_screen.dart';
import 'package:solwoe/screens/welcome_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final User? user = Auth().currentUser;
  UserProfile? _userProfile;

  late final List<Widget> _screens;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _asyncMethod();
    _screens = [
      FutureBuilder<UserProfile?>(
        future: UserProfile.getUserProfile(),
        builder: (BuildContext context, AsyncSnapshot<UserProfile?> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return DashboardScreen(userProfile: snapshot.data);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      const AssessmentDetailScreen(),
      const CareScreen(),
    ];
  }

  Future<void> _asyncMethod() async {
    _userProfile = await UserProfile.getUserProfile();
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

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstantColors.secondaryBackgroundColor,
      resizeToAvoidBottomInset: false,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              padding: EdgeInsets.zero,
              decoration: BoxDecoration(
                color: ConstantColors.primaryBackgroundColor,
              ),
              child: Center(
                child: Text(
                  'Menu',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 3,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.phone_rounded,
              ),
              title: const Text(
                'Helpline',
              ),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ManamCallScreen()));
              },
            ),
           
            ListTile(
              leading: const Icon(Icons.info_rounded),
              title: const Text('About'),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AboutScreen()));
              },
            ),
          ],
        ),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomAppBar(
        elevation: 10,
        color: ConstantColors.bottomAppBarColor,
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InkWell(
              onTap: () {
                onTabTapped(0);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.home_rounded,
                    color: _currentIndex == 0
                        ? ConstantColors.primaryBackgroundColor
                        : null,
                  ),
                  Text(
                    'Home',
                    style: GoogleFonts.rubik(
                      color: _currentIndex == 0
                          ? ConstantColors.primaryBackgroundColor
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                onTabTapped(1);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.assessment_rounded,
                    color: _currentIndex == 1
                        ? ConstantColors.primaryBackgroundColor
                        : null,
                  ),
                  Text(
                    'Assessment',
                    style: GoogleFonts.rubik(
                      color: _currentIndex == 1
                          ? ConstantColors.primaryBackgroundColor
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                onTabTapped(2);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.medical_services_rounded,
                    color: _currentIndex == 2
                        ? ConstantColors.primaryBackgroundColor
                        : null,
                  ),
                  Text(
                    'Care',
                    style: GoogleFonts.rubik(
                      color: _currentIndex == 2
                          ? ConstantColors.primaryBackgroundColor
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
