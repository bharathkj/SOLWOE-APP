import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solwoe/auth.dart';
import 'package:solwoe/colors.dart';
import 'package:solwoe/screens/page_editor_screen.dart';
import 'package:solwoe/screens/page_reader_screen.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({Key? key}) : super(key: key);

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  int pageLimit = 8;
  bool isAddingPageDisabled = false;

  Widget noteCard(DocumentSnapshot doc) {
    return Card(
      color: ConstantColors.diaryCardsColor[doc['color_id']],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PageReaderScreen(doc),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                doc["page_title"],
                style: GoogleFonts.rubik(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4.0),
              Text(
                doc["creation_date"],
                style: GoogleFonts.rubik(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.0),
              Text(
                doc["page_content"],
                style: GoogleFonts.rubik(
                  fontSize: 16.0,
                  fontWeight: FontWeight.normal,
                ),
                overflow: TextOverflow.clip,
                maxLines: 3,
              ),
              SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PageEditorScreen(doc: doc),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Confirm Delete"),
                            content: Text(
                                "Are you sure you want to delete this page?"),
                            actions: [
                              TextButton(
                                child: Text("Cancel"),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              TextButton(
                                child: Text("Delete"),
                                onPressed: () {
                                  // Delete page and close dialog
                                  FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(Auth().currentUser!.email)
                                      .collection('diary')
                                      .doc(doc.id)
                                      .delete();
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
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
          'Diary',
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Your recent Pages",
                style: GoogleFonts.roboto(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              SizedBox(height: 20.0),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(Auth().currentUser!.email)
                      .collection('diary')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Error: ${snapshot.error}",
                          style: GoogleFonts.rubik(
                            fontSize: 16.0,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      );
                    } else if (snapshot.hasData &&
                        snapshot.data!.docs.isNotEmpty) {
                      final pages = snapshot.data!.docs;
                      isAddingPageDisabled = pages.length >= pageLimit;
                      return ListView.builder(
                        physics: BouncingScrollPhysics(),
                        itemCount: pages.length,
                        itemBuilder: (context, index) {
                          return noteCard(pages[index]);
                        },
                      );
                    } else {
                      return Center(
                        child: Text(
                          "You don't have any pages yet. Add a new one!",
                          style: GoogleFonts.rubik(
                            fontSize: 16.0,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
              SizedBox(height: 20)
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isAddingPageDisabled
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PageEditorScreen(),
                  ),
                );
              },
        icon: Icon(Icons.add),
        label: Text('Add Page'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
