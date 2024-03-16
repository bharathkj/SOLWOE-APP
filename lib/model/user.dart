import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solwoe/auth.dart';
import 'package:solwoe/model/shared_preferences.dart';
import 'dart:convert';

class UserProfile {
  final bool onboarding;
  final String email;
  final String name;
  final String dateOfBirth;
  final String gender;
  final String role;
  final String country;
  final String state;
  final String city;
  final String phone;

  UserProfile({
    required this.onboarding,
    required this.email,
    required this.name,
    required this.dateOfBirth,
    required this.gender,
    required this.role,
    required this.country,
    required this.state,
    required this.city,
    required this.phone,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      onboarding: json['onboarding'],
      email: json['email'],
      name: json['name'],
      dateOfBirth: json['dateOfBirth'],
      gender: json['gender'],
      role: json['role'],
      country: json['country'],
      state: json['state'],
      city: json['city'],
      phone: json['phone']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'onboarding': onboarding,
      'email': email,
      'name': name,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'role': role,
      'country': country,
      'state': state,
      'city': city,
      'phone':phone,
    };
  }

  static Future<UserProfile?> getUserProfile() async {
    final SharedPreferences prefs =
        await SharedPreferencesService.getSharedPreferencesInstance();
    final String userProfileJson = prefs.getString('userProfile') ?? '';

    if (userProfileJson.isNotEmpty) {
      final Map<String, dynamic> userProfileData = json.decode(userProfileJson);
      log('from local');
      return UserProfile.fromJson(userProfileData);
    } else {
      final CollectionReference users =
          FirebaseFirestore.instance.collection('users');
      final String userId = Auth().currentUser!.email.toString();
      log('from firestore');
      try {
        final DocumentSnapshot userData = await users.doc(userId).get();
        final Map<String, dynamic> userDataMap =
            userData.data() as Map<String, dynamic>;

        final UserProfile userProfile = UserProfile(
          onboarding: userDataMap['onboarding'],
          email: userDataMap['email'],
          name: userDataMap['name'],
          dateOfBirth: userDataMap['dateOfBirth'],
          gender: userDataMap['gender'],
          role: userDataMap['role'],
          country: userDataMap['location']['country'],
          state: userDataMap['location']['state'],
          city: userDataMap['location']['city'],
          phone: userDataMap['phone'],
        );

        prefs.setString('userProfile', json.encode(userProfile.toJson()));

        return userProfile;
      } catch (e) {
        log('Error fetching user profile data: $e');
        return null;
      }
    }
  }
}
