class Ad {
  final int id;
  final String title;
  final String description;
  final String price;
  final String city;
  final String? image;
  final int views;
  final String status;

  Ad({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.city,
    this.image,
    required this.views,
    required this.status,
  });

  factory Ad.fromJson(Map<String, dynamic> json) {
    return Ad(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      price: json['price'],
      city: json['city'],
      image: json['image'],
      views: json['views'] ?? 0,
      status: json['status'] ?? 'active',
    );
  }
}
