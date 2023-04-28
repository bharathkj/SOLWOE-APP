import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:solwoe/auth.dart';
import 'package:solwoe/colors.dart';
import 'package:solwoe/screens/page_reader_screen.dart';

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

  @override
  void initState() {
    super.initState();

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

  Future<void> _addPage({DocumentSnapshot? doc}) async {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm:ss');
    final String formattedDate = formatter.format(now);

    try {
      if (doc != null) {
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
        await FirebaseFirestore.instance
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
