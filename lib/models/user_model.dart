class User {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String? profilePictureUrl;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.profilePictureUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      profilePictureUrl: json['profilePictureUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'profilePictureUrl': profilePictureUrl,
    };
  }

  User copyWith({
    int? id,
    String? email,
    String? firstName,
    String? lastName,
    String? profilePictureUrl,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
    );
  }
}
