import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:solwoe/colors.dart';

class ManamCallScreen extends StatelessWidget {
  const ManamCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstantColors.secondaryBackgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        elevation: 3,
        backgroundColor: ConstantColors.secondaryBackgroundColor,
        title: RichText(
          text: TextSpan(
            text: 'Ma',
            style: GoogleFonts.rubik(color: Colors.red, fontSize: 20),
            children: [
              TextSpan(
                text: 'Na',
                style: GoogleFonts.rubik(color: Colors.green),
              ),
              TextSpan(
                text: 'M',
                style: GoogleFonts.rubik(color: Colors.blue),
              ),
            ],
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Container(
                height: 220,
                width: 200,
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                  image: DecorationImage(
                    image: AssetImage('assets/tamilNaduLogo.png'),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: '"',
                  style: GoogleFonts.rubik(
                      color: Colors.black, fontSize: 24, height: 2),
                  children: [
                    TextSpan(
                      text: 'Ma',
                      style: GoogleFonts.rubik(color: Colors.red),
                    ),
                    TextSpan(
                      text: 'Na',
                      style: GoogleFonts.rubik(color: Colors.green),
                    ),
                    TextSpan(
                      text: 'M',
                      style: GoogleFonts.rubik(color: Colors.blue),
                    ),
                    TextSpan(
                      text: '"',
                      style: GoogleFonts.rubik(),
                    ),
                    TextSpan(
                      text: '\nMa',
                      style: GoogleFonts.rubik(color: Colors.red, fontSize: 20),
                    ),
                    TextSpan(
                      text: 'nanala ',
                      style: GoogleFonts.rubik(fontSize: 20),
                    ),
                    TextSpan(
                      text: 'Na',
                      style:
                          GoogleFonts.rubik(color: Colors.green, fontSize: 20),
                    ),
                    TextSpan(
                      text: 'llaatharavu ',
                      style: GoogleFonts.rubik(fontSize: 20),
                    ),
                    TextSpan(
                      text: 'M',
                      style:
                          GoogleFonts.rubik(color: Colors.blue, fontSize: 20),
                    ),
                    TextSpan(
                      text: 'andram',
                      style: GoogleFonts.rubik(fontSize: 20),
                    ),
                    TextSpan(
                      text: '\nBy',
                      style: GoogleFonts.rubik(fontSize: 16),
                    ),
                    TextSpan(
                      text: '\nThe Government of Tamil Nadu',
                      style: GoogleFonts.rubik(fontSize: 20),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              InkWell(
                onTap: () async {
                  
                  await FlutterPhoneDirectCaller.callNumber('14416');
                },
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListTile(
                    leading: Image.asset('assets/manamLogo.png'),
                    title: const Text('Call Now'),
                    subtitle: const Text('Tap to Call'),
                    trailing: const Icon(Icons.phone_rounded),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
