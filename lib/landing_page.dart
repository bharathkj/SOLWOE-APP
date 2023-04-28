import 'package:solwoe/auth.dart';
import 'package:solwoe/screens/email_verification_screen.dart';
import 'package:solwoe/screens/welcome_screen.dart';
import 'package:flutter/material.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            return const EmailVerificationScreen();
          } else {
            return const WelcomeScreen();
          }
        } else {
          // Show a loading indicator or some other temporary widget
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
