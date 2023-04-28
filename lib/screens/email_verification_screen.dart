import 'dart:async';

import 'package:flutter/material.dart';
import 'package:solwoe/auth.dart';
import 'package:solwoe/screens/onboarding_screen.dart';
import 'package:solwoe/screens/welcome_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isEmailVerified = false;
  bool _canResendEmail = true;
  Timer? _timer;

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      final user = Auth().currentUser;
      if (user != null && user.emailVerified) {
        _timer?.cancel();
        setState(() {
          _isEmailVerified = true;
        });
      } else {
        reload();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _isEmailVerified = Auth().currentUser!.emailVerified;
    if (!_isEmailVerified) startTimer();
  }

  void reload() async {
    await Auth().currentUser!.reload();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future sendEmailVerification() async {
    try {
      await Auth().currentUser!.sendEmailVerification();
      setState(() {
        _canResendEmail = false;
      });
      await Future.delayed(
        const Duration(seconds: 5),
      );
      setState(() {
        _canResendEmail = true;
      });
    } catch (e) {
      SnackBar(
        content: Text(
          e.toString(),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return _isEmailVerified
        ? const OnboardingScreen()
        : Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              centerTitle: true,
              title: const Text('Verify Email'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'A verification email has been sent to your email.',
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (_canResendEmail) {
                        sendEmailVerification();
                      }
                    },
                    icon: const Icon(
                      Icons.email,
                      size: 32,
                    ),
                    label: const Text(
                      'Resend Email',
                      style: TextStyle(
                        fontSize: 24,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  TextButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    onPressed: () {
                      Auth().signOut().then((value) {
                        /* timer?.cancel(); */
                        _timer?.cancel();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const WelcomeScreen(),
                          ),
                        );
                      });
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
