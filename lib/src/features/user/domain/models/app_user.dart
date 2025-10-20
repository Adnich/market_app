import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? dateOfBirth;
  final String? gender;
  final String? photoUrl;

  AppUser({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.dateOfBirth,
    this.gender,
    this.photoUrl
  });

  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return AppUser(
      id: doc.id,
      email: data['email'] ?? '',
      firstName: data['firstName'],
      lastName: data['lastName'],
      phone: data['phone'],
      dateOfBirth: data['dateOfBirth'],
      gender: data['gender'],
      photoUrl: data['photoUrl']
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'photoUrl':photoUrl,
    };
  }
}
