import 'dart:convert';
import 'dart:developer';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:solwoe/database.dart';
import 'package:solwoe/model/question.dart';
import 'package:solwoe/model/shared_preferences.dart';
import 'package:solwoe/screens/redirect_result_screen.dart';
import 'package:solwoe/services/notification_service.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  _QuestionnaireScreenState createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  PageController? _pageController;

  int _questionIndex = 0;
  int _totalQuestions = 0;

  final List<Map<String, String>> _answers = []; // to store all the answers
  bool _isEnglish = true;
  List<Question> _questions = [];
  final Map<int, dynamic> _selectedOptions = {};
  @override
  void initState() {
    super.initState();
    _fetchQuestions();
    _pageController = PageController(initialPage: 0);
  }

  _fetchQuestions() async {
    _questions = await QuestionCache.getQuestions('english');
    _totalQuestions = _questions.length;
    setState(() {});
  }

  _fetchQuestionsTamil() async {
    _questions = await QuestionCache.getQuestions('tamil');
    _totalQuestions = _questions.length;
    setState(() {});
  }

  _buildProgressIndicator() {
    if (_totalQuestions != 0) {
      return LinearProgressIndicator(
        minHeight: 10,
        color: const Color(0xffffb55c),
        backgroundColor: const Color(0xffe2e8f0),
        value: _questionIndex / (_totalQuestions - 1),
      );
    }
    return Container();
  }

  Widget _buildQuestion() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      width: double.infinity,
      child: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() {
          _questionIndex = index;
        }),
        children: List.generate(_questions.length, (index) {
          final question = _questions[index];
          return Card(
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(
                color: Colors.black,
                width: 2.0,
              ),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xffe2e8f0),
              ),
              child: SingleChildScrollView(
                child: Wrap(
                  alignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: _isEnglish
                          ? Text(
                              question.question.toString(),
                              style: const TextStyle(
                                  fontSize: 22, color: Colors.black),
                            )
                          : Text(
                              question.question,
                              style: GoogleFonts.notoSansTamil(
                                  fontSize: 20, color: Colors.black),
                            ),
                    ),
                    ...question.options.map((option) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RadioListTile(
                          activeColor: const Color(0xffffb55c),
                          value: option.value.toString(),
                          groupValue:
                              _selectedOptions[_questionIndex].toString(),
                          onChanged: (value) {
                            _onOptionSelected(value.toString());
                          },
                          title: _isEnglish
                              ? Text(
                                  option.option.toString(),
                                  style: const TextStyle(
                                      fontSize: 18, color: Colors.black),
                                  //style: const TextStyle(fontSize: 30),
                                )
                              : Text(
                                  option.option.toString(),
                                  style: GoogleFonts.notoSansTamil(
                                      fontSize: 16, color: Colors.black),
                                ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  void _onOptionSelected(String value) {
    setState(() {
      _selectedOptions[_questionIndex] = int.parse(value);
    });
  }

  void _onNext() {
    setState(() {
      _questionIndex++;
    });
    _pageController?.jumpToPage(
      _questionIndex,
    );
  }

  void _onPrevious() {
    setState(() {
      _questionIndex--;
    });
    _pageController?.jumpToPage(
      _questionIndex,
    );
  }

  void _onSubmitAnswers() async {
    bool allAnswered = true;
    allAnswered = _selectedOptions.length == _totalQuestions ? true : false;

    if (allAnswered) {
      final total =
          _selectedOptions.values.fold<num>(0, (prev, curr) => prev + curr);

      String severity = '';
      String suggestion = '';

      if (total == 0) {
        severity = 'No depression';
        suggestion = 'Self Care';
      } else if (total >= 1 && total <= 4) {
        severity = 'Minimal';
        suggestion = 'Self Care';
      } else if (total >= 5 && total <= 9) {
        severity = 'Mild';
        suggestion = 'Self Care';
      } else if (total >= 10 && total <= 14) {
        severity = 'Moderate';
        suggestion = 'Guided Care';
      } else if (total >= 15 && total <= 19) {
        severity = 'Moderately severe';
        suggestion = 'Guided Care';
      } else {
        severity = 'Severe';
        suggestion = 'Guided Care';
      }

      int i = 0;
      List<Question> _q = [];
      if (!_isEnglish) {
        _q = await QuestionCache.getQuestions('english');
      }
      _selectedOptions.forEach((key, value) {
        if (_isEnglish) {
          _answers.add({
            'number': i.toString(),
            'question': _questions[i].question,
            'option': _questions[i].options[_selectedOptions[i]].option,
            'value': _selectedOptions[i].toString()
          });
        } else {
          _answers.add({
            'number': i.toString(),
            'question': _q[i].question,
            'option': _q[i].options[_selectedOptions[i]].option,
            'value': _selectedOptions[i].toString()
          });
        }
        i++;
      });
      log(i.toString());
      final dateTime = DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now());
      final date = DateFormat('MMMM dd, yyyy').format(DateTime.now());
      final time = DateFormat('HH:mm').format(DateTime.now());
      await NotificationService.showNotification(
        title: 'SOLWOE',
        body: "Your assessment has been successfully submitted",
      );
      await Database()
          .saveAssessmentAnswers(_answers, total.toString(), severity, dateTime,
              date, time, suggestion)
          .then(
            (value) => Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => RedirectResultScreen(
                    total: total.toInt(),
                    result: severity,
                    suggestion: suggestion,
                    answers: _answers),
              ),
            ),
          );
      
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please answer all the questions"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            style: TextButton.styleFrom(backgroundColor: Colors.transparent),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Back',
              style: TextStyle(color: Color(0xffffb55c), fontSize: 16),
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _isEnglish = !_isEnglish;
              if (_isEnglish) {
                _fetchQuestions();
              } else {
                _fetchQuestionsTamil();
              }
            },
            icon: Icon(
              Icons.translate,
              color: Color(0xffffb55c),
            ),
          ),
        ],
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xff6146c6),
        title: const Text(
          'QUESTIONNAIRE',
          style: TextStyle(
            color: Color(0xffe2e8f0),
            fontSize: 18,
            letterSpacing: 2.0,
          ),
        ),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: const Color(0xff6146c6),
        child: _totalQuestions == 0
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const Text("Fetching Questions"),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: _isEnglish
                        ? Text(
                            "Question ${_questionIndex + 1} of $_totalQuestions",
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xffe2e8f0),
                            ),
                          )
                        : Text(
                            'கேள்வி ${_questionIndex + 1} of $_totalQuestions',
                            style: GoogleFonts.notoSansTamil(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xffe2e8f0),
                            ),
                          ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _buildProgressIndicator(),
                  ),
                  Expanded(
                    child: _buildQuestion(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffffb55c)),
                        onPressed: () {
                          if (_questionIndex != 0) {
                            _onPrevious();
                          }
                        },
                        child: const Text(
                          'Previous',
                          style: TextStyle(color: Color(0xff000000)),
                        ),
                      ),
                      _questionIndex == _questions.length - 1
                          ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xffffb55c)),
                              onPressed: () {
                                _onSubmitAnswers();
                              },
                              child: const Text(
                                'Submit',
                                style: TextStyle(color: Color(0xff000000)),
                              ),
                            )
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xffffb55c)),
                              onPressed: () {
                                _onNext();
                              },
                              child: const Text(
                                'Next',
                                style: TextStyle(color: Color(0xff000000)),
                              ),
                            ),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                ],
              ),
      ),
    );
  }
}

class QuestionCache {
  static Map<String, List<Question>> cache = {};
  static const String _keyPrefix = 'question_cache_';

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferencesService.getSharedPreferencesInstance();
  }

  static Future<List<Question>> getQuestions(String language) async {
    await init();
    final cacheKey = _keyPrefix + language;
    if (cache[cacheKey] != null) {
      // return cached questions if available
      log('Retrieving questions from cache');
      return cache[cacheKey]!;
    } else {
      // fetch questions from Firebase or cache
      final questionsJson = _prefs.getString(cacheKey);
      if (questionsJson != null) {
        log('Retrieving questions from Shared Preferences');
        final questions = _parseQuestions(questionsJson);
        cache[cacheKey] = questions;
        return questions;
      } else {
        log('Fetching questions from Firebase');
        QuerySnapshot snapshot;
        if (language == 'english') {
          snapshot =
              await FirebaseFirestore.instance.collection('questions').get();
          log('read');
        } else if (language == 'tamil') {
          snapshot = await FirebaseFirestore.instance
              .collection('questionsTamil')
              .get();
          log('read');
        } else {
          throw ArgumentError('Invalid language');
        }

        // cache questions for future use
        final documents = snapshot.docs;
        final questions =
            documents.map((doc) => Question.fromSnapshot(doc)).toList();
        cache[cacheKey] = questions;
        _prefs.setString(cacheKey, json.encode(questions));
        return questions;
      }
    }
  }

  static List<Question> _parseQuestions(String jsonString) {
    final parsed = json.decode(jsonString);
    return parsed
        .map<Question>((question) => Question.fromJson(question))
        .toList();
  }
}
