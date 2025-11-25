class SneakerDrop {
  final String name;
  final String image;
  final String releaseDate;
  final double price;
  final bool isHype; // Pour afficher une petite flamme 🔥

  SneakerDrop({
    required this.name,
    required this.image,
    required this.releaseDate,
    required this.price,
    this.isHype = false,
  });

  // Prêt pour une future API JSON
  factory SneakerDrop.fromJson(Map<String, dynamic> json) {
    return SneakerDrop(
      name: json['shoeName'] ?? "Unknown Kicks",
      image: json['thumbnail'] ?? "",
      releaseDate: json['releaseDate'] ?? "TBA",
      price: (json['retailPrice'] ?? 0).toDouble(),
      isHype: true,
    );
  }
}