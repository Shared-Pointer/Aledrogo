class Item {
  final int id;
  final int usersId;
  final String title;
  final String description;
  final double price;
  final String category;
  final int quantity;
  final String image;
  final bool isAuction;
  final DateTime? endDate;

  Item({
    required this.id,
    required this.usersId, 
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.quantity,
    required this.image,
    required this.isAuction,
    this.endDate,
  });

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      usersId: map['users_id'], 
      title: map['title'],
      description: map['description'],
      price: map['price'],
      category: map['category'],
      quantity: map['quantity'],
      image: map['image'],
      isAuction: map['is_auction'] == 1,
      endDate: map['end_date'] != null ? DateTime.parse(map['end_date']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'users_id': usersId,
      'title': title,
      'description': description,
      'price': price,
      'category': category,
      'quantity': quantity,
      'image': image,
      'is_auction': isAuction ? 1 : 0,
      'end_date': endDate?.toIso8601String(),
    };
  }
}