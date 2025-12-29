import 'package:firebase_database/firebase_database.dart';
import '../models/ServiceModel.dart';

class LandingServicesService {
  final _ref = FirebaseDatabase.instance.ref('services');

  Future<List<ServiceModel>> getServices() async {
    final snap = await _ref.get();
    if (!snap.exists) return [];

    final raw = snap.value as Map<dynamic, dynamic>;

    return raw.entries.map((e) {
      return ServiceModel.fromMap(
        e.key,
        Map<String, dynamic>.from(e.value),
      );
    }).toList();
  }
}
