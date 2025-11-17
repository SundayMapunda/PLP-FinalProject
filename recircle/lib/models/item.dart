import 'user.dart';

class Item {
  final int id;
  final User owner;
  final String title;
  final String description;
  final String category;
  final String itemType;
  final String? imageUrl;
  final String location;
  final bool isAvailable;
  final DateTime createdAt;
  final DateTime updatedAt;

  Item({
    required this.id,
    required this.owner,
    required this.title,
    required this.description,
    required this.category,
    required this.itemType,
    this.imageUrl,
    required this.location,
    required this.isAvailable,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      owner: User.fromJson(json['owner']),
      title: json['title'],
      description: json['description'],
      category: json['category'],
      itemType: json['item_type'],
      imageUrl: json['image'],
      location: json['location'],
      isAvailable: json['is_available'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // Helper getters
  bool get isForBorrow => itemType == 'BORROW';
  bool get isForGive => itemType == 'GIVE';

  String get typeLabel => isForBorrow ? 'For Borrowing' : 'For Giving Away';
}
