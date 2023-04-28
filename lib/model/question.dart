import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:solwoe/model/option.dart';

class Question {
  final String question;
  final List<Option> options;

  Question({required this.question, required this.options});

  factory Question.fromSnapshot(DocumentSnapshot snapshot) {
    final optionsData = snapshot['options'];

    List<Option> options;

    if (optionsData is List) {
      options = optionsData
          .map(
            (option) => Option(
              option: (option['option'] ?? '').toString(),
              value: (option['value'] ?? '').toString(),
            ),
          )
          .toList();
    } else {
      options = [];
    }

    return Question(
      question: snapshot['question'],
      options: options,
    );
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    final optionsData = json['options'];

    List<Option> options;

    if (optionsData is List) {
      options = optionsData
          .map(
            (option) => Option(
              option: (option['option'] ?? '').toString(),
              value: (option['value'] ?? '').toString(),
            ),
          )
          .toList();
    } else {
      options = [];
    }

    return Question(
      question: json['question'] ?? '',
      options: options,
    );
  }

  Map<String, dynamic> toJson() {
    return {'question': question, 'options': options};
  }
}