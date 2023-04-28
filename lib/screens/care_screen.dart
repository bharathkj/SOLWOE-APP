import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solwoe/screens/guided_care_screen.dart';
import 'package:solwoe/screens/self_care.dart';

class CareScreen extends StatefulWidget {
  const CareScreen({super.key});

  @override
  State<CareScreen> createState() => _CareScreenState();
}

class _CareScreenState extends State<CareScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const Center(
          child: Text(
            "CHOOSE YOUR PATH",
            style: TextStyle(
              fontFamily: 'Rowdies',
              fontWeight: FontWeight.w900,
              fontSize: 24,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(
          height: 30,
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const SelfCareScreen(),
              ),
            );
          },
          child: Container(
            height: 182,
            width: 232,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: AssetImage('assets/selfCare.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Text(
              'Self Care',
              style:
                  GoogleFonts.rubik(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
        const SizedBox(
          height: 30,
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const GuidedCareScreen(),
              ),
            );
          },
          child: Container(
            height: 182,
            width: 232,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: AssetImage('assets/guidedCare.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Text(
              'Guided Care',
              style:
                  GoogleFonts.rubik(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
        const SizedBox(
          height: 30,
        ),
      ],
    );
  }
}
