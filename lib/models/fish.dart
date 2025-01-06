class Fish {
  String? _id;
  String? _name;
  String? _picture;

  Fish({String? id, String? name, String? picture})
      : _id = id,
        _name = name,
        _picture = picture;

  // Getters
  String? get id => _id;
  String? get name => _name;
  String? get picture => _picture;

  // Setters
  set id(String? id) {
    _id = id;
  }

  set name(String? name) {
    _name = name;
  }

  set picture(String? picture) {
    _picture = picture;
  }

  Map<String, dynamic> toMap() {
    return {'name': _name, 'picture': _picture};
  }

  // Add fromMap constructor
  factory Fish.fromMap(Map<String, dynamic> map, String id) {
    return Fish(id: id, name: map['name'], picture: map['picture']);
  }
}
