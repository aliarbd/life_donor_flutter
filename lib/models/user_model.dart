class UserModel {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String phone;
  final int age;
  final String city;
  final String gender;
  final String division;
  final String district;
  final String upazila;
  final String bloodGroup;
  final String createdAt;

  const UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.age,
    required this.city,
    required this.gender,
    required this.division,
    required this.district,
    required this.upazila,
    required this.bloodGroup,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'age': age,
      'city': city,
      'gender': gender,
      'division': division,
      'district': district,
      'upazila': upazila,
      'blood_group': bloodGroup,
      'created_at': createdAt,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      phone: map['phone'] as String,
      age: map['age'] as int,
      city: map['city'] as String,
      gender: map['gender'] as String,
      division: map['division'] as String,
      district: map['district'] as String,
      upazila: map['upazila'] as String,
      bloodGroup: map['blood_group'] as String,
      createdAt: map['created_at'] as String,
    );
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    String? phone,
    int? age,
    String? city,
    String? gender,
    String? division,
    String? district,
    String? upazila,
    String? bloodGroup,
    String? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      age: age ?? this.age,
      city: city ?? this.city,
      gender: gender ?? this.gender,
      division: division ?? this.division,
      district: district ?? this.district,
      upazila: upazila ?? this.upazila,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
