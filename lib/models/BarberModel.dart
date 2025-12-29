class BarberModel {
  final String id;
  final String name;

  BarberModel({
    required this.id,
    required this.name,
  });

  factory BarberModel.fromMap(String id, Map data) {
    return BarberModel(
      id: id,
      name: data['name'],
    );
  }
}
