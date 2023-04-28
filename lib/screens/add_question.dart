import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddQuestionPage extends StatefulWidget {
  const AddQuestionPage({super.key});

  @override
  _AddQuestionPageState createState() => _AddQuestionPageState();
}

class _AddQuestionPageState extends State<AddQuestionPage> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;

  String _question = '';
  final List<String> _options = [];
  final List<String> _values = [];
  final List<Map<String, dynamic>> _option = [];
  
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Question'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 10.0),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Question'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a question';
                    }
                    return null;
                  },
                  onSaved: (value) => _question = value.toString(),
                ),
                const SizedBox(height: 10.0),
                Column(
                  children: List.generate(
                    _options.length,
                    (index) => Row(
                      children: <Widget>[
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Option ${index + 1}',
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter an option';
                              }
                              return null;
                            },
                            onSaved: (value) =>
                                _options[index] = value.toString(),
                          ),
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        Expanded(
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Value ${index + 1}',
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter a value';
                              }
                              return null;
                            },
                            onSaved: (value) =>
                                _values[index] = value.toString(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              _options.removeAt(index);
                              _values.removeAt(index);
                              _option.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                ElevatedButton(
                  child: const Text('Add Option'),
                  onPressed: () {
                    setState(() {
                      _options.add('');
                      _values.add('');
                      _option.add({});
                    });
                  },
                ),
                const SizedBox(height: 10.0),
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (isValid) {
      _formKey.currentState!.save();
      if (_options.length != 0) {
        for (int i = 0; i < _options.length; i++) {
          _option[i] = {'option': _options[i], 'value': _values[i]};
        }

        var length = await _firestore.collection('questions').count().get();

        _firestore
            .collection('questions')
            .doc('question_${length.count + 1}')
            .set({
          'question': _question,
          'options': _option,
        });
        Future.delayed(const Duration(milliseconds: 100))
            .then((value) => Navigator.of(context).pop());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add atleast one option'),
          ),
        );
      }
    }
  }
}
