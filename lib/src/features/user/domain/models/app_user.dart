import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_mappable/dart_mappable.dart';
part 'app_user.mapper.dart'; 


@MappableClass()
class AppUser with AppUserMappable {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? dateOfBirth;
  final String? gender;
  final String? photoUrl;

  const AppUser({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.dateOfBirth,
    this.gender,
    this.photoUrl,
  });

  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw Exception('Firestore document is null');
    }

    return AppUserMapper.fromMap({
      ...data,
      'id': doc.id,
    });
  }

  Map<String, dynamic> toFirestore() => toMap();
}
