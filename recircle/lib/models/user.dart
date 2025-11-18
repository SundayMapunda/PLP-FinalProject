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

  // Helper methods for the UI
  String get displayName => username;

  String get joinDate {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return 'Joined ${months[createdAt.month - 1]} ${createdAt.year}';
  }

  bool get hasBio => bio != null && bio!.isNotEmpty;
  bool get hasLocation => location != null && location!.isNotEmpty;
}
