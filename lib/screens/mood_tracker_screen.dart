import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solwoe/colors.dart';
import 'package:solwoe/database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:solwoe/model/shared_preferences.dart';
import 'package:intl/intl.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  List<MoodData> moodDataList = [];
  List<Color> gradientColors = [
    ConstantColors.primaryBackgroundColor,
    ConstantColors.primaryBackgroundColor,
  ];
  int _selectedIconIndex = -1;
  MoodData? _moodData;
  late SharedPreferences prefs;
  bool _selected = true;
  late String moodString;
  late int moodValue;
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

  @override
  void initState() {
    super.initState();
    _hasSelectedMoodForToday().then((value) {
      if (!value) {
        _selected = false;
      } else {
        String today =
            'mood_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}';
        String? moodStringAndValue = prefs.getString(today);

        // Split the string into mood string and value int using the colon (:) separator
        List<String> moodStringAndValueList = moodStringAndValue!.split(':');
        moodString = moodStringAndValueList[0];
        moodValue = int.parse(moodStringAndValueList[1]);
        _moodData = MoodData(4, moodString, moodValue);
      }
    });
    _asyncMethod();
  }

  Future<bool> _hasSelectedMoodForToday() async {
    prefs = await SharedPreferencesService.getSharedPreferencesInstance();
    String today =
        'mood_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}';
    return prefs.getString(today) != null;
  }

  _asyncMethod() async {
    int i = 0;

    await Database().getMood().then((value) {
      for (var doc in value.docs.reversed) {
        MoodData moodData = MoodData(i++, doc['mood'], doc['value']);
        moodDataList.add(moodData);
      }
      if (_selected) moodDataList.add(_moodData!);
    });
    setState(() {});
  }

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
          'Mood Tracker',
          style: GoogleFonts.sourceSerifPro(
            color: Colors.black,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _selected
          ? Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('Mood for the last 5 entries'),
                moodDataList.isNotEmpty
                    ? Expanded(
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: LineChart(
                              LineChartData(
                                titlesData: FlTitlesData(
                                  show: true,
                                  rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 30,
                                      interval: 1,
                                      getTitlesWidget: (value, meta) {
                                        return SideTitleWidget(
                                            axisSide: meta.axisSide,
                                            child: Text('${value.toInt()}'));
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      interval: 1,
                                      reservedSize: 60,
                                      getTitlesWidget: (value, meta) {
                                        String? text;
                                        switch (value.toInt()) {
                                          case -4:
                                            text = "Angry";
                                            break;
                                          case -2:
                                            text = "Sad";
                                            break;
                                          case 0:
                                            text = "Neutral";
                                            break;
                                          case 2:
                                            text = "Happy";
                                            break;
                                          case 4:
                                            text = "Excited";
                                            break;
                                          default:
                                            text = "";
                                        }
                                        return SideTitleWidget(
                                          axisSide: meta.axisSide,
                                          child: Text(text),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                minX: 0,
                                maxX: 4,
                                minY: -6,
                                maxY: 6,
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: moodDataList
                                        .map(
                                          (e) => FlSpot(e.id.toDouble(),
                                              e.value.toDouble()),
                                        )
                                        .toList(),
                                    isCurved: true,
                                    gradient: LinearGradient(
                                      colors: gradientColors,
                                    ),
                                    barWidth: 5,
                                    isStrokeCapRound: true,
                                    dotData: FlDotData(
                                      show: true,
                                    ),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      gradient: LinearGradient(
                                        colors: gradientColors
                                            .map((e) => e.withOpacity(0.3))
                                            .toList(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    : const Center(child: CircularProgressIndicator()),
              ],
            )
          : SizedBox(
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
                                onTap: () async {
                                  setState(() {
                                    _selected = true;
                                    _selectedIconIndex = index;
                                    MoodData moodData = MoodData(
                                        4,
                                        _moods[_selectedIconIndex]['label'],
                                        _moods[_selectedIconIndex]['value']);
                                    moodDataList.add(moodData);
                                    // save selected mood to shared preferences
                                    String today =
                                        'mood_${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}';
                                    prefs.setString(today,
                                        '${_moods[_selectedIconIndex]['label']}:${_moods[_selectedIconIndex]['value']}');
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
                                    const SizedBox(height: 5),
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
    );
  }
}

class MoodData {
  final int id;
  final String mood;
  final int value;

  MoodData(this.id, this.mood, this.value);
}
