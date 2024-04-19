import 'dart:async';
import 'dart:developer';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:solwoe/auth.dart';
import 'package:solwoe/model/search.dart';
import 'package:solwoe/screens/guided_care_screen.dart';
import 'package:solwoe/screens/diary_screen.dart';
import 'package:solwoe/screens/manam_call_screen.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solwoe/colors.dart';
import 'package:solwoe/database.dart';
import 'package:solwoe/model/shared_preferences.dart';
import 'package:solwoe/model/user.dart';
import 'package:solwoe/screens/appointment_screen.dart';
import 'package:solwoe/screens/mood_tracker_screen.dart';
import 'package:solwoe/screens/questionnaire_screen.dart';
import 'package:solwoe/screens/search_activities.dart';
import 'package:solwoe/screens/search_doctors.dart';
import 'package:solwoe/screens/self_care.dart';
import 'package:solwoe/screens/show_videos.dart';
import 'package:solwoe/screens/view_profile_screen.dart';
import 'package:solwoe/screens/welcome_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:solwoe/screens/doctor_dashboard_screen.dart';

import 'package:solwoe/screens/emotion_chart.dart'; //dummy
class DashboardScreen extends StatefulWidget {
  final UserProfile? userProfile;
  const DashboardScreen({super.key, this.userProfile});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  late YoutubePlayerController _youtubePlayerController;

  SearchType currentSearchType = SearchType.selfCareActivities;

  final List<String> selfCareActivities = [
    'Meditation',
    'Yoga',
    'Music',
    'Diary',
  ];

  int _selectedIconIndex = -1;

  late String _greeting;
  late SharedPreferences prefs;
  final List<Map<String, dynamic>> _moods = [
    {
      "label": "Angry",
      "icon": Icons.sentiment_very_dissatisfied,
      "color": Colors.red,
      "value": -4,
    },
    {
      "label": "Sad",
      "icon": Icons.sentiment_dissatisfied,
      "color": Colors.blueGrey,
      "value": -2,
    },
    {
      "label": "Neutral",
      "icon": Icons.sentiment_neutral,
      "color": Colors.grey,
      "value": 0,
    },
    {
      "label": "Happy",
      "icon": Icons.sentiment_satisfied,
      "color": Colors.green,
      "value": 2,
    },
    {
      "label": "Excited",
      "icon": Icons.sentiment_very_satisfied,
      "color": Colors.orange,
      "value": 4,
    },
  ];

  String? videoLink;
  late List<String> _quotes;

  @override
  void initState() {
    super.initState();
    _greeting = _getGreeting();

    _hasSelectedMoodForToday().then((hasSelectedMood) {
      if (hasSelectedMood) {
        // get the selected mood from shared preferences
        SharedPreferencesService.getSharedPreferencesInstance().then((prefs) {
          String? selectedMood = prefs.getString(
              'mood_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}');
          // find the index of the selected mood in the _moods list
          int index =
          _moods.indexWhere((mood) => mood['label'] == selectedMood);
          if (index != -1) {
            _selectedIconIndex = index;
          }
        });
      }
    });
    _loadVideoLinks().then(((value) {
      if (videoLink!.isNotEmpty) {
        _youtubePlayerController = YoutubePlayerController(
          initialVideoId: YoutubePlayer.convertUrlToId(videoLink!)!,
          flags: const YoutubePlayerFlags(
            useHybridComposition: false,
            autoPlay: false,
          ),
        );
      }
    }));
    _deleteMoodsNotForToday();
    _loadQuotes();

    getSizeOfData();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  Future<bool> _hasSelectedMoodForToday() async {
    prefs = await SharedPreferencesService.getSharedPreferencesInstance();
    String today =
        'mood_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}';

    return prefs.getString(today) != null;
  }

  Future<void> _loadVideoLinks() async {
    final String videoLinksString =
    await rootBundle.loadString('assets/Videos.txt');

    videoLink = videoLinksString.split('\n')[0];
  }

  Future<void> _deleteMoodsNotForToday() async {
    final prefs = await SharedPreferencesService.getSharedPreferencesInstance();
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (!key.startsWith('mood_')) {
        continue; // skip keys that are not for mood
      }

      final dateStr =
      key.substring('mood_'.length); // extract the date from the key
      final today = DateFormat('dd-MM-yyyy').format(DateTime.now()).toString();
      log(dateStr);
      log(dateStr);
      log(today.toString());
      if (dateStr != today) {
        // Get the mood string and value as a string
        String? moodStringAndValue = prefs.getString(key);

        // Split the string into mood string and value int using the colon (:) separator
        List<String> moodStringAndValueList = moodStringAndValue!.split(':');
        String moodString = moodStringAndValueList[0];
        int moodValue = int.parse(moodStringAndValueList[1]);

        // store the last mood
        Database().saveMood(moodString, moodValue,
            DateFormat('dd-MM-yyyy').format(DateTime.now()).toString());
        prefs.remove(key); // delete the mood if it's not for today
      }
    }
  }

  Future<void> _loadQuotes() async {
    final String quotesString =
    await rootBundle.loadString('assets/Quotes.txt');

    setState(() {
      _quotes = quotesString.split('\n');
      _isLoading = false;
    });
  }

  Future<void> getSizeOfData() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    int size = 0;

    for (final key in keys) {
      final value = prefs.get(key);
      size += value.toString().length;
    }

    log('Size of data stored in shared preferences: $size bytes');

    log('Keys of data stored in shared preferences: $keys');
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

  Widget tipsCard(String link, String image, String label) {
    return InkWell(
      onTap: () async {
        await launchUrl(
          Uri.parse(link),
        );
      },
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        shadowColor: Colors.grey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: Image.asset(
                    image,
                  ),
                ),
              ),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.rubik(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget space(double size) {
    return SizedBox(height: size);
  }

  Widget featureCard(Widget screen, String image, String label) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.4,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => screen,
            ),
          );
        },
        child: Card(
          elevation: 10,
          shadowColor: Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image.asset(
                image,
                height: 64,
                width: 64,
              ),
              Text(
                label,
                style: GoogleFonts.quicksand(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget selfCareCard(String label, Widget screen) {
    return Card(
      elevation: 10,
      shadowColor: Colors.grey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        height: 150,
        width: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: ConstantColors.cardColor,
        ),
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => screen,
            ));
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.rubik(color: Colors.black, fontSize: 18),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget plainCard(String title, String label, IconData icon, Widget screen) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 10.0,
            ),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                title,
                style: GoogleFonts.rubik(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 12,
              right: 12,
              top: 5,
              bottom: 5,
            ),
            child: Card(
              elevation: 10,
              shadowColor: Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => screen));
                },
                child: Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: ConstantColors.cardColor,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          label,
                          style: GoogleFonts.rubik(
                              color: Colors.black, fontSize: 24),
                        ),
                        Icon(
                          icon,
                          size: 36,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    //bool isSpecialUser = true;

    bool isSpecialUser = widget.userProfile!.role == "Parent"; //checking conditional to see if user is doctor or not to determine building button

    return SafeArea(
      child: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.15,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: ConstantColors.primaryBackgroundColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [

                  Positioned(
                    top: 10,
                    left: 0,
                    child: Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(
                          Icons.menu,
                          color: Colors.white,
                          size: 24,
                        ),
                        onPressed: () =>
                            Scaffold.of(context).openDrawer(),
                      ),
                    ),
                  ),

                  Positioned(
                    top: 10,
                    right: 0,
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => const ManamCallScreen()));
                          },
                          child: Image.asset(
                            'assets/sos.png',
                            height: 36,
                            width: 36,
                          ),
                        ),
                        PopupMenuButton(
                          icon: const Icon(
                            Icons.person_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                          itemBuilder: (context) {
                            return [
                              const PopupMenuItem<int>(
                                value: 0,
                                child: Text('My Profile'),
                              ),
                              const PopupMenuItem<int>(
                                value: 1,
                                child: Text('Log Out'),
                              ),
                            ];
                          },
                          onSelected: (value) {
                            if (value == 0) {
                              Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => ViewProfileScreen(
                                          userProfile:
                                          widget.userProfile)));
                            } else {
                              signOut(context);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 10,
                    child: Text(
                      'SOLWOE',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 32,
                          letterSpacing: 2,
                          color: Colors.white),
                    ),
                  ),
                  Positioned(
                    top: 15,
                    left: 65,  // Adjust the left position based on your design
                    child: Visibility(
                      visible: isSpecialUser,  // Only build and show if the user is special
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => DoctorDashboardScreen(currentUserDisplayName: widget.userProfile!.name)));
                        },
                        child: CircleAvatar(
                          backgroundImage: AssetImage('assets/docdashboard.png'), // Replace with your dashboard icon
                          radius: 20,  // Adjust the size based on your design
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    child: Container(
                      height: 40,
                      width: MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              // Show popup menu to select search type
                              showMenu(
                                context: context,
                                position:
                                RelativeRect.fromLTRB(0, 40, 0, 0),
                                items: [
                                  PopupMenuItem(
                                    value: SearchType.selfCareActivities,
                                    child: Text('Self Care Activities'),
                                  ),
                                  PopupMenuItem(
                                    value: SearchType.doctors,
                                    child: Text('Doctors'),
                                  ),
                                ],
                              ).then((value) {
                                if (value != null) {
                                  setState(() {
                                    currentSearchType = value;
                                  });
                                }
                              });
                            },
                            child: Padding(
                              padding:
                              EdgeInsets.symmetric(horizontal: 10),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  padding: EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1, color: Colors.black)),
                                  child: Text(
                                    currentSearchType ==
                                        SearchType.selfCareActivities
                                        ? 'Activities'
                                        : 'Doctors',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              // Show search delegate
                              dynamic result = await showSearch(
                                context: context,
                                delegate: currentSearchType ==
                                    SearchType.selfCareActivities
                                    ? SearchActivities(selfCareActivities)
                                    : SearchDoctors(),
                              );
                              if (result != null) {
                                // handle search result
                              }
                            },
                            child: Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: Row(
                                children: [
                                  Icon(Icons.search),
                                  space(10),
                                  Text(
                                    currentSearchType ==
                                        SearchType.selfCareActivities
                                        ? 'Search for activities'
                                        : 'Search for doctors',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 10.0,
                right: 10.0,
                top: 15.0,
              ),
              child: Text(
                '$_greeting, ${widget.userProfile!.name}!',
                style: GoogleFonts.rubik(
                  fontSize: 22,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(
                left: 10.0,
                right: 10.0,
                bottom: 5.0,
              ),
              child: Divider(
                thickness: 2,
              ),
            ),
            /* How are you feeling container */
            SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 10.0,
                      bottom: 10.0,
                    ),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "How are you feeling today?",
                        style: GoogleFonts.rubik(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _moods
                        .asMap()
                        .map((index, mood) => MapEntry(
                      index,
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            if (_selectedIconIndex == index) {
                              // unselect the icon
                              _selectedIconIndex = -1;
                            } else {
                              // select the icon
                              _selectedIconIndex = index;
                              // save selected mood to shared preferences
                              String today =
                                  'mood_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}';
                              prefs.setString(today,
                                  '${_moods[_selectedIconIndex]['label']}:${_moods[_selectedIconIndex]['value']}');
                              int value =
                              _moods[_selectedIconIndex]
                              ['value'];
                              showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (BuildContext
                                  builderContext) {
                                    return AlertDialog(
                                      title: const Text(
                                          'Your Response is Recorded'),
                                      content: value <= -2
                                          ? const Text(
                                          'Try counselling')
                                          : value == 0
                                          ? const Text(
                                          'Take an assessment')
                                          : const Text(
                                          'Try a activity'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop();
                                          },
                                          child: Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop();
                                            if (value <= -2) {
                                              Navigator.of(
                                                  context)
                                                  .push(
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                  const GuidedCareScreen(),
                                                ),
                                              );
                                            } else if (value ==
                                                0) {
                                              Navigator.of(
                                                  context)
                                                  .push(
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                  const QuestionnaireScreen(),
                                                ),
                                              );
                                            } else {
                                              Navigator.of(
                                                  context)
                                                  .push(
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                  const SelfCareScreen(),
                                                ),
                                              );
                                            }
                                          },
                                          child: Text('Proceed'),
                                        ),
                                      ],
                                    );
                                  });
                            }
                          });
                        },
                        child: Column(
                          children: [
                            CircleAvatar(
                              backgroundColor:
                              _selectedIconIndex == index
                                  ? mood['color']
                                  : Colors.transparent,
                              child: Icon(
                                mood["icon"],
                                color: _selectedIconIndex == index
                                    ? Colors.black
                                    : mood['color'],
                                size: 30,
                              ),
                            ),
                            space(5),
                            Text(
                              mood["label"],
                              style: TextStyle(
                                color: _selectedIconIndex == index
                                    ? mood['color']
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ))
                        .values
                        .toList(),
                  ),
                ],
              ),
            ),
            space(30),

            /* Assessment Container */
            SizedBox(
              width: double.infinity,
              child: CarouselSlider(
                options: CarouselOptions(
                    autoPlay: true,
                    autoPlayCurve: Curves.easeInOut,
                    enableInfiniteScroll: true,
                    autoPlayAnimationDuration:
                    const Duration(seconds: 10),
                    viewportFraction: 0.8,
                    enlargeCenterPage: true),
                items: [
                  tipsCard(
                      'https://sites.google.com/view/solwoe/tip1',
                      'assets/tip1.png',
                      '5 tips to encourage your loved one to start counselling'),
                  tipsCard(
                      'https://sites.google.com/view/solwoe/tip2',
                      'assets/tip2.png',
                      'Learn to differentiate between counselling and plain advice'),
                  tipsCard(
                      'https://sites.google.com/view/solwoe/tip3',
                      'assets/tip3.png',
                      'Psychological impact of the covid 19 pandemic'),
                ],
              ),
            ),
            space(30),
            //Featured Container
            SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 10.0,
                    ),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Featured",
                        style: GoogleFonts.rubik(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 200,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        featureCard(QuestionnaireScreen(),
                            'assets/questionnaire.png', "Assessment"),
                        featureCard(AppointmentScreen(),
                            'assets/examination.png', "Appointment"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            space(30),

            /* Quote of the day container */
            SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 10.0,
                    ),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Quotes",
                        style: GoogleFonts.rubik(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 12,
                      right: 12,
                      top: 5,
                      bottom: 5,
                    ),
                    child: Card(
                      elevation: 10,
                      shadowColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: 150,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: ConstantColors.cardColor),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Center(
                            child: AnimatedTextKit(
                              animatedTexts: _quotes
                                  .map(
                                    (str) => TypewriterAnimatedText(
                                  str,
                                  textStyle: GoogleFonts.rubik(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  speed: const Duration(
                                      milliseconds: 300),
                                  textAlign: TextAlign.center,
                                ),
                              )
                                  .toList(),
                              repeatForever: true,
                              pause: const Duration(milliseconds: 3000),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            space(30),
            /* Mood tracker container */
            plainCard(
              'Mood tracker',
              'Check insights',
              Icons.show_chart,
              MoodTrackerScreen(),
            ),

            space(30),

            /*Immediate help container*/
            plainCard(
              'Helpline',
              'Call for immediate help',
              Icons.phone_rounded,
              ManamCallScreen(),
            ),

            space(30),
            /* Self care container */
            SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 10.0,
                    ),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Self-care",
                        style: GoogleFonts.rubik(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 12,
                      right: 12,
                      top: 5,
                      bottom: 5,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceEvenly,
                          children: [
                            selfCareCard(
                              'Meditation',
                              ShowVideosScreen(title: 'Meditation'),
                            ),
                            selfCareCard(
                              'Music',
                              ShowVideosScreen(title: 'Music'),
                            ),
                          ],
                        ),
                        space(30),
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceEvenly,
                          children: [
                            selfCareCard(
                              'Diary',
                              DiaryScreen(),
                            ),
                            selfCareCard(
                              'Explore all',
                              SelfCareScreen(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            space(30),

            /* Videos container */
            SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 10.0,
                      right: 10.0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Videos",
                            textAlign: TextAlign.left,
                            style: GoogleFonts.rubik(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ShowVideosScreen(
                                    title: 'Videos'),
                              ),
                            );
                          },
                          child: Text(
                            "View all",
                            style: GoogleFonts.rubik(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              decoration: TextDecoration.underline,
                              decorationStyle: TextDecorationStyle.solid,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 12,
                      right: 12,
                    ),
                    child: Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      shadowColor: Colors.grey,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: YoutubePlayer(
                            controller: _youtubePlayerController,
                            showVideoProgressIndicator: true,
                            progressIndicatorColor:
                            ConstantColors.primaryBackgroundColor,
                            bottomActions: [
                              CurrentPosition(),
                              ProgressBar(
                                isExpanded: true,
                                colors: const ProgressBarColors(
                                  playedColor: ConstantColors
                                      .primaryBackgroundColor,
                                  handleColor: ConstantColors
                                      .primaryBackgroundColor,
                                ),
                              ),
                              const PlaybackSpeedButton(),
                            ],
                            onReady: () {
                              log('player ready');
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            space(30),
          ],
        ),
      ),
    );
  }
}