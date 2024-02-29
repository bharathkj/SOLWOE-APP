import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solwoe/colors.dart';
import 'package:solwoe/model/user.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io'; // Add this import for File class


class ViewProfileScreen extends StatefulWidget {
  final UserProfile? userProfile;
  const ViewProfileScreen({super.key, this.userProfile});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();

}

class _ViewProfileScreenState extends State<ViewProfileScreen> {

  late DatabaseReference _databaseReference;

  List<String> patients = [];
  String selectedPatient = '';

  File? _selectedImage;

  void _onPatientSelected(String patientUsername) {
  }

  void _grantPermission() {
    final caretakerUsername = FirebaseAuth.instance.currentUser!.displayName;
    if (caretakerUsername != null && selectedPatient.isNotEmpty) {
      _databaseReference
          .child('users/$selectedPatient/caretakerperm')
          .push()
          .set(caretakerUsername);

      // Optionally, you can also update the caretaker's profile with the selected patient
      _databaseReference
          .child('users/$caretakerUsername/patients')
          .push()
          .set(selectedPatient);

      // Provide feedback to the user if needed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Permission granted to view $selectedPatient\'s data'),
        ),
      );
    }
  }




  Future<void> _uploadImageToFirebase(XFile pickedFile) async {
    final storage = FirebaseStorage.instance;
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final userName = user.displayName;

      if (userName != null) {
        final storageRef = storage.ref().child(
            'profile_pictures/$userName.jpg');

        try {
          await storageRef.putFile(File(pickedFile.path));
          final downloadUrl = await storageRef.getDownloadURL();

          // Update the user's profile picture URL in your user database.
          // For example, you can use Cloud Firestore or Firebase Realtime Database.
          // Update the UI to reflect the new profile picture.
        } catch (e) {
          print('Error uploading image to Firebase Storage: $e');
          print(e);
        }
      }
    }
  }

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final XFile? pickedFile = await imagePicker.pickImage(
        source: ImageSource.gallery);

    if (pickedFile != null) {
      // Upload the picked image file to Firebase Storage and update the user's profile picture.
      await _uploadImageToFirebase(pickedFile);

      // Convert XFile to File
      File pickedFileAsFile = File(pickedFile.path);

      // Trigger UI rebuild
      setState(() {
        _selectedImage = pickedFileAsFile;
      });
    }
  }


  final formKey = GlobalKey<FormState>();

  final TextEditingController _dateOfBirth = TextEditingController();

  String _name = '';

  String _gender = '';

  String _role = '';

  String _countryValue = '';

  String _stateValue = '';

  String _cityValue = '';

  late int _age;

  @override
  void initState() {
    super.initState();
    _databaseReference = FirebaseDatabase.instance.reference();

    // Fetch the list of usernames from the 'users' directory
    _databaseReference.child('users').once().then((DatabaseEvent event) {
      if (event.snapshot != null && event.snapshot.value != null) {
        Map<dynamic, dynamic>? users = event.snapshot.value as Map<dynamic, dynamic>?;

        if (users != null) {
          patients = users.keys.cast<String>().toList();
          print("Patients 1: $patients");
          setState(() {});
          print("Patients 2: $patients");
        }
      }
    }).catchError((error) {
      print('Error fetching data: $error');
    });

  }

  Widget buildCard(String text, IconData icon) {
    return Card(
      elevation: 2,
      color: Colors.white,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
      child: ListTile(
        leading: Icon(
          icon,
          color: ConstantColors.primaryBackgroundColor,
        ),
        title: Text(
          text,
          style: GoogleFonts.rubik(
            color: Colors.black,
            fontSize: 18,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.black,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstantColors.secondaryBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        elevation: 3,
        backgroundColor: ConstantColors.secondaryBackgroundColor,
        title: Text(
          'Profile',
        ),
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: () {
                  _pickImage(); // assuming _pickImage is a function in your code
                },
                child: Text('Change Profile Picture'),
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 150,
                width: 225,
                child: CircleAvatar(
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!) as ImageProvider<Object>?
                      : AssetImage('assets/profilePicture.png'),
                ),
              ),
              SizedBox(height: 20),
              DropdownButton<String>(
                value: selectedPatient,
                items: patients.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  _onPatientSelected(newValue!);
                },
                hint: Text('Select a caretaker'),
              ),
              ElevatedButton(
                onPressed: _grantPermission,
                child: Text('Grant Permission'),
              ),
              // ... (remaining existing code)
              buildCard(
                widget.userProfile!.name,
                Icons.person_rounded,
              ),
              buildCard(
                widget.userProfile!.email,
                Icons.email_rounded,
              ),
              buildCard(
                widget.userProfile!.gender,
                Icons.male_rounded,
              ),
              buildCard(
                widget.userProfile!.dateOfBirth,
                Icons.date_range_rounded,
              ),
              buildCard(
                '${widget.userProfile!.state}, ${widget.userProfile!.country}',
                Icons.location_city_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}