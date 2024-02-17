import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solwoe/colors.dart';
import 'package:solwoe/screens/diary_screen.dart';
import 'package:solwoe/screens/show_videos.dart';

class SelfCareScreen extends StatefulWidget {
  const SelfCareScreen({super.key});

  @override
  State<SelfCareScreen> createState() => _SelfCareScreenState();
}

class _SelfCareScreenState extends State<SelfCareScreen> {
  final List<Map<String, Widget>> _activities = const [
    {
      'Meditation': ShowVideosScreen(title: 'Meditation'),
    },
    {
      'Music': ShowVideosScreen(title: 'Music'),
    },
    {
      'Diary': DiaryScreen(),
    },
    {
      'Yoga': ShowVideosScreen(title: 'Yoga'),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstantColors.secondaryBackgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        elevation: 3,
        backgroundColor: ConstantColors.secondaryBackgroundColor,
        title: Text(
          'Self Care',
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(
              left: 10.0,
            ),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                "List of Activities",
                style: GoogleFonts.rubik(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              physics: BouncingScrollPhysics(),
                itemCount: _activities.length,
                itemBuilder: (context, index) {
                  final activity = _activities[index];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    shadowColor: Colors.grey,
                    child: ListTile(
                      title: Text(activity.keys.first),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => activity.values.first),
                        );
                      },
                      trailing: Icon(Icons.arrow_forward_ios),
                    ),
                  );
                }),
          ),
        ],
      )),
    );
  }
}
