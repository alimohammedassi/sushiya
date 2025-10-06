class SushiItem {
  final int id;
  final String name;
  final double price;
  final double rating;
  final String image;
  final String description;
  final String category;
  final List<String> ingredients;

  SushiItem({
    required this.id,
    required this.name,
    required this.price,
    required this.rating,
    required this.image,
    required this.description,
    required this.category,
    required this.ingredients,
  });

  // 🟢 لتحويل من Map (من SQLite أو API) لـ SushiItem
  factory SushiItem.fromMap(Map<String, dynamic> map) {
    return SushiItem(
      id: map['id'] is int ? map['id'] : int.parse(map['id'].toString()),
      name: map['name'] ?? '',
      price: map['price'] is double
          ? map['price']
          : double.tryParse(map['price'].toString()) ?? 0.0,
      rating: map['rating'] is double
          ? map['rating']
          : double.tryParse(map['rating'].toString()) ?? 0.0,
      image: map['image'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'Sushi',
      ingredients: (map['ingredients'] ?? '')
          .toString()
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
    );
  }

  // 🔴 لتحويل من SushiItem لـ Map (ندخله SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'rating': rating,
      'image': image,
      'description': description,
      'category': category,
      'ingredients': ingredients.join(','),
    };
  }
}