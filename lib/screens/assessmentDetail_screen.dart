import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solwoe/auth.dart';
import 'package:solwoe/colors.dart';
import 'package:solwoe/screens/questionnaire_screen.dart';
import 'package:solwoe/screens/redirect_result_screen.dart';

class AssessmentDetailScreen extends StatefulWidget {
  const AssessmentDetailScreen({super.key});

  @override
  State<AssessmentDetailScreen> createState() => _AssessmentDetailScreenState();
}

class _AssessmentDetailScreenState extends State<AssessmentDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 30,
        ),

        /* Assessment Container */
        SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 10.0,
                ),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "Assessment",
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  shadowColor: Colors.grey,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Take an Assessment",
                                style: GoogleFonts.rubik(
                                  color: ConstantColors.primaryBackgroundColor,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Answer a few questions about your mental well-being.",
                                style: GoogleFonts.rubik(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const QuestionnaireScreen(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 30),
                                  backgroundColor:
                                      ConstantColors.primaryBackgroundColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                                child: Text(
                                  "START",
                                  style: GoogleFonts.rubik(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Image.asset('assets/personThinking.png'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 30,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10.0, bottom: 10.0),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              "Assessment History",
              style: GoogleFonts.rubik(
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(Auth().currentUser!.email)
                .collection('assessment')
                .orderBy('date', descending: true)
                .orderBy('time', descending: true)
                .limit(4)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              var assessmentHistoryDocs = snapshot.data!.docs;
              if (assessmentHistoryDocs.isEmpty) {
                return Center(
                  child: Text('No assessment found.'),
                );
              }
              return ListView.builder(
                itemCount: assessmentHistoryDocs.length,
                itemBuilder: (context, index) {
                  var assessmentHistoryDoc = assessmentHistoryDocs[index];
                  return Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: ListTile(
                      horizontalTitleGap: 0,
                      leading: const Icon(Icons.description_outlined),
                      iconColor: Colors.black,
                      title: Text('Date: ${assessmentHistoryDoc['date']}'),
                      subtitle: Text(
                          'Time: ${assessmentHistoryDoc['time']}\nResult: ${assessmentHistoryDoc['result']}\nSuggestion: ${assessmentHistoryDoc['suggestion']}'),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () {
                        showModalBottomSheet(
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            context: context,
                            builder: (BuildContext context) {
                              return Container(
                                padding: const EdgeInsets.all(16.0),
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Assessment Details',
                                            style: GoogleFonts.rubik(
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          OutlinedButton(
                                              onPressed: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        RedirectResultScreen(
                                                      total: int.parse(
                                                        assessmentHistoryDoc[
                                                            'total_score'],
                                                      ),
                                                      result:
                                                          assessmentHistoryDoc[
                                                              'result'],
                                                      suggestion:
                                                          assessmentHistoryDoc[
                                                              'suggestion'],
                                                      answers:
                                                          assessmentHistoryDoc[
                                                              'answers'],
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Text('View Result'))
                                        ],
                                      ),
                                      const SizedBox(height: 16.0),
                                      for (int i = 0;
                                          i <
                                              assessmentHistoryDoc['answers']
                                                  .length;
                                          i++)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Question ${i + 1}: ${assessmentHistoryDoc['answers'][i]['question']}',
                                                style: GoogleFonts.rubik(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              const SizedBox(height: 8.0),
                                              Text(
                                                'Answer: ${assessmentHistoryDoc['answers'][i]['option']}',
                                                style: GoogleFonts.rubik(),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            });
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
