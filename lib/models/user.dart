import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String? _id;
  String? _name;
  String? _surname;
  String? _email;
  List<DocumentReference>? _contacts;
  List<DocumentReference>? _friendRequests;

  User({
    String? id,
    String? name,
    String? surname,
    String? email,
    List<DocumentReference>? contacts,
    List<DocumentReference>? friendRequests,
  })  : _id = id,
        _name = name,
        _surname = surname,
        _email = email,
        _contacts = contacts,
        _friendRequests = friendRequests;

  // Getters
  String? get id => _id;
  String? get name => _name;
  String? get surname => _surname;
  String? get email => _email;
  List<DocumentReference>? get contacts => _contacts;
  List<DocumentReference>? get friendRequests => _friendRequests;

  // Setters
  set id(String? id) {
    _id = id;
  }

  set name(String? name) {
    _name = name;
  }

  set surname(String? surname) {
    _surname = surname;
  }

  set email(String? email) {
    _email = email;
  }

  set contacts(List<DocumentReference>? contacts) {
    _contacts = contacts;
  }

  set friendRequests(List<DocumentReference>? friendRequests) {
    _friendRequests = friendRequests;
  }

  Map<String, dynamic> toMap() {
  final map = <String, dynamic>{
    'name': _name,
    'surname': _surname,
    'email': _email,
  };
  
  if (_contacts != null) map['contacts'] = _contacts;
  if (_friendRequests != null) map['friendRequests'] = _friendRequests;
  
  return map;
}

  // Add fromMap constructor
  factory User.fromMap(Map<String, dynamic> map, String id) {
    return User(
      id: id,
      name: map['name'],
      surname: map['surname'],
      email: map['email'],
      contacts: map['contacts'] != null 
          ? (map['contacts'] as List).map((item) => item as DocumentReference).toList()
          : null,
      friendRequests: map['friendRequests'] != null
          ? (map['friendRequests'] as List).map((item) => item as DocumentReference).toList()
          : null,
   );
  }
}