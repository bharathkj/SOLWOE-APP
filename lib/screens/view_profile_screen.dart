import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solwoe/colors.dart';
import 'package:solwoe/model/user.dart';

class ViewProfileScreen extends StatefulWidget {
  final UserProfile? userProfile;
  const ViewProfileScreen({super.key, this.userProfile});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
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
    /*   _name = widget.userEntity.name;
    _dateOfBirth.text = widget.userEntity.dateOfBirth;
    _age = widget.userEntity.age;
    _gender = widget.userEntity.gender;
    _role = widget.userEntity.role;
    _countryValue = widget.userEntity.country;
    _stateValue = widget.userEntity.state;
    _cityValue = widget.userEntity.city; */
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height:20),
            SizedBox(
              height: 150,
              width: 225,
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/profilePicture.png'),
              ),
            ),
            SizedBox(height: 20),
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
    );
  }
}
