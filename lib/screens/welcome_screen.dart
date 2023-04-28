import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'login_registration_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int _currentPageIndex = 0;
  late PageController _controller;

  List<Walkthrough> walkThrough = [
    Walkthrough(
      title: 'Welcome to SOLWOE',
      assetImage: 'assets/selfCare.png',
      description:
          'SOLWOE is an app for managing mental health and well-being. It offers tools and resources to help reduce depression. Let\'s get started!',
    ),
    Walkthrough(
      title: 'Take Our Assessment',
      assetImage: 'assets/assessment.png',
      description:
          'The first step to managing your mental health is understanding your needs. Take our assessment to get personalized recommendations on how to improve your mental health and well-being.',
    ),
    Walkthrough(
      title: 'Manage Your Mental Health',
      assetImage: 'assets/guidedCare.png',
      description:
          'Solwoe offers self-care and guided care modules to manage mental health based on assessment results. Start today and take control of your mental health.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: _currentPageIndex);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: PageView.builder(
                physics: const BouncingScrollPhysics(),
                controller: _controller,
                onPageChanged: (value) =>
                    setState(() => _currentPageIndex = value),
                itemCount: walkThrough.length,
                itemBuilder: (context, i) {
                  return Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      children: [
                        Image.asset(
                          walkThrough[i].assetImage,
                          height:
                              (MediaQuery.of(context).size.height / 100) * 35,
                        ),
                        SizedBox(
                          height: (MediaQuery.of(context).size.height >= 840)
                              ? 40
                              : 15,
                        ),
                        Text(
                          walkThrough[i].title,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.sourceSerifPro(
                            fontWeight: FontWeight.w600,
                            fontSize: (MediaQuery.of(context).size.width <= 550)
                                ? 26
                                : 30,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          walkThrough[i].description,
                          style: GoogleFonts.sourceSerifPro(
                            fontWeight: FontWeight.w300,
                            fontSize: (MediaQuery.of(context).size.width <= 550)
                                ? 16
                                : 24,
                          ),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      walkThrough.length,
                      (int index) => _buildDots(
                        index: index,
                      ),
                    ),
                  ),
                  _currentPageIndex + 1 == walkThrough.length
                      ? Padding(
                          padding: const EdgeInsets.all(30),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => LoginRegistrationScreen(
                                      type: 'Registration'),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              padding: (MediaQuery.of(context).size.width <=
                                      550)
                                  ? const EdgeInsets.symmetric(
                                      horizontal: 100, vertical: 20)
                                  : EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                              0.2,
                                      vertical: 25),
                              textStyle: TextStyle(
                                  fontSize:
                                      (MediaQuery.of(context).size.width <= 550)
                                          ? 13
                                          : 17),
                            ),
                            child: Text(
                              "GET STARTED",
                              style: GoogleFonts.rubik(),
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () {
                                  _controller
                                      .jumpToPage(walkThrough.length - 1);
                                },
                                style: TextButton.styleFrom(
                                  elevation: 0,
                                  textStyle: GoogleFonts.rubik(
                                    fontWeight: FontWeight.w600,
                                    fontSize:
                                        (MediaQuery.of(context).size.width <=
                                                550)
                                            ? 13
                                            : 17,
                                  ),
                                ),
                                child: Text(
                                  "SKIP",
                                  style: GoogleFonts.rubik(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  _controller.nextPage(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeIn,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  elevation: 0,
                                  padding:
                                      (MediaQuery.of(context).size.width <= 550)
                                          ? const EdgeInsets.symmetric(
                                              horizontal: 30, vertical: 20)
                                          : const EdgeInsets.symmetric(
                                              horizontal: 30, vertical: 25),
                                  textStyle: TextStyle(
                                      fontSize:
                                          (MediaQuery.of(context).size.width <=
                                                  550)
                                              ? 13
                                              : 17),
                                ),
                                child: Text(
                                  "NEXT",
                                  style: GoogleFonts.rubik(),
                                ),
                              ),
                            ],
                          ),
                        ),
                  Visibility(
                    visible: _currentPageIndex + 1 == walkThrough.length
                        ? true
                        : false,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account ? ',
                          style: GoogleFonts.rubik(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LoginRegistrationScreen(
                                type: 'Login',
                              ),
                            ),
                          ),
                          child: Text(
                            'Login',
                            style: GoogleFonts.rubik(
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  AnimatedContainer _buildDots({
    int? index,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(50),
        ),
        color: Color(0xFF000000),
      ),
      margin: const EdgeInsets.only(right: 5),
      height: 10,
      curve: Curves.easeInOut,
      width: _currentPageIndex == index ? 20 : 10,
    );
  }
}

class Walkthrough {
  final String title;
  final String assetImage;
  final String description;

  Walkthrough(
      {required this.title,
      required this.assetImage,
      required this.description});
}
