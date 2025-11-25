class Sneaker {
  final int? id;
  final String brand;
  final String model;
  final String colorway;
  final String imagePath;
  final double price;
  final int year;
  final DateTime dateAdded;

  Sneaker({this.id, required this.brand, required this.model, required this.colorway, required this.imagePath, required this.price, required this.year, required this.dateAdded});

  Map<String, dynamic> toMap() => {'id': id, 'brand': brand, 'model': model, 'colorway': colorway, 'image_path': imagePath, 'price': price, 'year': year, 'date_added': dateAdded.toIso8601String()};
  factory Sneaker.fromMap(Map<String, dynamic> map) => Sneaker(id: map['id'], brand: map['brand'], model: map['model'], colorway: map['colorway'], imagePath: map['image_path'], price: map['price'], year: map['year'], dateAdded: DateTime.parse(map['date_added']));
}