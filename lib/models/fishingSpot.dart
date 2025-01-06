import 'package:cloud_firestore/cloud_firestore.dart';

class FishingSpot {
  String? _id;
  String? _title;
  String? _description;
  String? _picture;
  double? _latitude;
  double? _longitude;
  DocumentReference? _creator;
  List<DocumentReference>? _fishes;

  FishingSpot({
    String? id,
    String? title,
    String? description,
    String? picture,
    double? latitude,
    double? longitude,
    DocumentReference? creator,
    List<DocumentReference>? fishes,
  })  : _id = id,
        _title = title,
        _description = description,
        _picture = picture,
        _latitude = latitude,
        _longitude = longitude,
        _creator = creator,
        _fishes = fishes;

  // Getters
  String? get id => _id;
  String? get title => _title;
  String? get description => _description;
  String? get picture => _picture;
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  DocumentReference? get creator => _creator;
  List<DocumentReference>? get fishes => _fishes;

  // Setters
  set id(String? id) {
    _id = id;
  }

  set title(String? title) {
    _title = title;
  }

  set description(String? description) {
    _description = description;
  }

  set picture(String? picture) {
    _picture = picture;
  }

  set latitude(double? latitude) {
    _latitude = latitude;
  }

  set longitude(double? longitude) {
    _longitude = longitude;
  }

  set creator(DocumentReference? creator) {
    _creator = creator;
  }

  set fishes(List<DocumentReference>? fishes) {
    _fishes = fishes;
  }

  Map<String, dynamic> toMap() {
    return {
      'title': _title,
      'description': _description,
      'picture': _picture,
      'latitude': _latitude,
      'longitude': _longitude,
      'creator': _creator,
      'fishes': _fishes,
    };
  }

  // Add fromMap constructor
  factory FishingSpot.fromMap(Map<String, dynamic> map, String id) {
    return FishingSpot(
      id: id,
      title: map['title'],
      description: map['description'],
      picture: map['picture'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      creator: map['creator'] as DocumentReference,
      fishes: map['fishes'] != null
          ? List<DocumentReference>.from(map['fishes'])
          : [],
    );
  }
}
