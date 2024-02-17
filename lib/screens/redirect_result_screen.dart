import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:solwoe/colors.dart';
import 'package:solwoe/screens/guided_care_screen.dart';
import 'package:solwoe/screens/self_care.dart';

class RedirectResultScreen extends StatelessWidget {
  final int total;
  final String result;
  final String suggestion;
  final List<dynamic> answers;
  const RedirectResultScreen(
      {super.key,
      required this.total,
      required this.result,
      required this.suggestion,
      required this.answers});

  Widget careCard(
      {required BuildContext context,
      required String care,
      required Widget screen,
      required String suggested}) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => screen),
        );
      },
      child: Card(
        elevation: 8.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        shadowColor: Colors.grey,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.4,
          height: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                care,
                style: GoogleFonts.quicksand(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Visibility(
                visible: suggested != '',
                child: Text(
                  'Suggested',
                  style: GoogleFonts.quicksand(
                      fontSize: 14, fontWeight: FontWeight.w300),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
            'Result',
          ),
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Text(
                "Insights",
                style: GoogleFonts.quicksand(
                  fontSize: 18,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AspectRatio(
                aspectRatio: 2,
                child: BarChart(
                  BarChartData(
                    barGroups: answers
                        .map(
                          (e) => BarChartGroupData(
                            x: int.parse(
                              e['number'].toString(),
                            ),
                            barRods: [
                              BarChartRodData(
                                toY: double.parse(
                                  e['value'].toString(),
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
                    borderData: FlBorderData(
                      border: const Border(
                        bottom: BorderSide(),
                        left: BorderSide(),
                      ),
                    ),
                    gridData: FlGridData(show: false),
                    backgroundColor: ConstantColors.primaryBackgroundColor,
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        axisNameWidget: Text('Questions -->'),
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            String text = '';
                            switch (value.toInt()) {
                              case 0:
                                text = 'Q1';
                                break;
                              case 1:
                                text = 'Q2';
                                break;
                              case 2:
                                text = 'Q3';
                                break;
                              case 3:
                                text = 'Q4';
                                break;
                              case 4:
                                text = 'Q5';
                                break;
                              case 5:
                                text = 'Q6';
                                break;
                              case 6:
                                text = 'Q7';
                                break;
                              case 7:
                                text = 'Q8';
                                break;
                              case 8:
                                text = 'Q9';
                                break;
                            }
                            return Text(text);
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        axisNameWidget: Text('Option -->'),
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                        ),
                      ),
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Card(
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  shadowColor: Colors.grey,
                  child: SizedBox(
                    width: 150,
                    height: 100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          result,
                          style: GoogleFonts.quicksand(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'Prediction',
                          style: GoogleFonts.quicksand(
                              fontSize: 14, fontWeight: FontWeight.w300),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  shadowColor: Colors.grey,
                  child: SizedBox(
                    width: 150,
                    height: 100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          total.toString(),
                          style: GoogleFonts.quicksand(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Score',
                          style: GoogleFonts.quicksand(
                              fontSize: 14, fontWeight: FontWeight.w300),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 40,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                careCard(
                    context: context,
                    care: 'Self Care',
                    screen: SelfCareScreen(),
                    suggested: suggestion == 'Self Care' ? suggestion : ''),
                careCard(
                    context: context,
                    care: 'Guided Care',
                    screen: GuidedCareScreen(),
                    suggested: suggestion == 'Guided Care' ? suggestion : ''),
              ],
            ),
            const SizedBox(
              height: 25,
            ),
            Text(
              'You can always choose the option that is not suggested.',
              style: GoogleFonts.quicksand(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ));
  }
}
