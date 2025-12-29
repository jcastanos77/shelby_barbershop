class ServiceModel {
  final String id;
  final String name;
  final int price;
  final int duration;
  final String description;
  final bool isSpecial;

  ServiceModel({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
    required this.description,
    required this.isSpecial
  });

  factory ServiceModel.fromMap(String id, Map data) {
    return ServiceModel(
      id: id,
      name: data['name'],
      price: data['price'],
      duration: data['duration'],
      description: data['description'],
      isSpecial: data['isSpecial']
    );
  }
}
