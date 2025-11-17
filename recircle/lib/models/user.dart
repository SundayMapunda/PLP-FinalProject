class User {
  final int id;
  final String username;
  final String email;
  final String? bio;
  final String? location;
  final String? phoneNumber;
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.bio,
    this.location,
    this.phoneNumber,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      bio: json['bio'],
      location: json['location'],
      phoneNumber: json['phone_number'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
