import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:solwoe/auth.dart';
import 'package:solwoe/colors.dart';
import 'package:solwoe/screens/page_reader_screen.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class PageEditorScreen extends StatefulWidget {
  final DocumentSnapshot? doc;

  PageEditorScreen({this.doc});

  @override
  _PageEditorScreenState createState() => _PageEditorScreenState();
}

class _PageEditorScreenState extends State<PageEditorScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  late String _pageTitle;
  late String _pageContent;
  late int _colorId;
  String serverIpAddress = ''; // Initial IP address

  @override
  void initState() {
    super.initState();
    fetchServerIpAddress(); // Fetch IP address when the widget initializes

    if (widget.doc != null) {
      // Update page
      _pageTitle = widget.doc!['page_title'];
      _pageContent = widget.doc!['page_content'];
      _colorId = widget.doc!['color_id'];

      _titleController.text = _pageTitle;
      _contentController.text = _pageContent;
    } else {
      // Add new page
      _pageTitle = "";
      _pageContent = "";
      _colorId = Random().nextInt(ConstantColors.diaryCardsColor.length);
    }
  }

  // Method to fetch IP address from Firestore
  Future<void> fetchServerIpAddress() async {
    final docSnapshot = await FirebaseFirestore.instance.collection('config').doc('server').get();
    if (docSnapshot.exists) {
      setState(() {
        serverIpAddress = docSnapshot.data()?['bert'] ?? ''; // Get IP address from 'bert' field
      });
    } else {
      print('Server document does not exist!');
    }
  }


  Future<void> _addPage({DocumentSnapshot? doc}) async {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm:ss');
    final String formattedDate = formatter.format(now);

    try {
      if (doc != null) {
        // Update existing page
        await FirebaseFirestore.instance
            .collection('users')
            .doc(Auth().currentUser!.email)
            .collection('diary')
            .doc(doc.id)
            .update({
          'page_title': _pageTitle,
          'page_content': _pageContent,
          'color_id': _colorId,
          'last_edit_date': formattedDate,
        });
      } else {
        // Add new page
        final addedDocRef = await FirebaseFirestore.instance
            .collection('users')
            .doc(Auth().currentUser!.email)
            .collection('diary')
            .add({
          'page_title': _pageTitle,
          'page_content': _pageContent,
          'color_id': _colorId,
          'creation_date': formattedDate,
          'last_edit_date': formattedDate,
        });

        // Send text input to Flask server
        await sendToFlaskServer(_pageTitle, _pageContent, addedDocRef.id);
      }
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add page'),
        ),
      );
    }

    Navigator.pop(context);
  }

  Future<void> sendToFlaskServer(String title, String content, String documentId) async {
    final String flaskServerUrl = '$serverIpAddress/analyze-emotion'; // Replace with your Flask server URL
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final Map<String, String> payload = {
        'text_data': content,
        'user_name': user.email ?? "Unknown",
      };

      try {
        final response = await http.post(
          Uri.parse(flaskServerUrl),
          headers: {'Content-Type': 'application/json'},  // Set Content-Type header
          body: jsonEncode(payload),  // Encode payload as JSON
        );

        if (response.statusCode == 200) {
          print('Text input sent to Flask server successfully');
        } else {
          print('Failed to send text input to Flask server. Status code: ${response.statusCode}');
        }
      } catch (error) {
        print('Error sending text input to Flask server: $error');
      }
    } else {
      print('User not authenticated. Unable to send text input to Flask server.');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstantColors.diaryCardsColor[_colorId],
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text(
          widget.doc != null ? 'Edit Page' : 'New Page',
          style: GoogleFonts.rubik(
            color: Colors.black,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(Icons.done),
            onPressed: () {
              _pageTitle = _titleController.text;
              _pageContent = _contentController.text;
              _addPage(doc: widget.doc);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Title',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
              ),
              style: GoogleFonts.rubik(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: TextField(
                controller: _contentController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Write something...',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500,
                  ),
                  border: InputBorder.none,
                ),
                style: GoogleFonts.rubik(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
