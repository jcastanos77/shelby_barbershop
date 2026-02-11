class BarberModel {
  final String id;
  final String name;
  final String photoUrl;
  final String email;
  final String phone;
  final bool active;

  BarberModel({
    required this.id,
    required this.name,
    required this.photoUrl,
    required this.email,
    required this.phone,
    required this.active
  });

  factory BarberModel.fromMap(String id, Map<dynamic, dynamic> data) {
    return BarberModel(
      id: id,
      name: (data['name'] ?? '').toString(),
      email: (data['email'] ?? '').toString(),
      phone: (data['phone'] ?? '').toString(),
      photoUrl: (data['photoUrl'] ?? '').toString(),
      active: data['active'] == true,
    );
  }
}
