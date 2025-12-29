import 'package:firebase_database/firebase_database.dart';

import '../models/BarberModel.dart';

class LandingBarbersService {
  final _ref = FirebaseDatabase.instance.ref('barbers');

  Future<List<BarberModel>> getBarbers() async {
    final snap = await _ref.get();
    if (!snap.exists) return [];

    final data = Map<String, dynamic>.from(snap.value as Map);

    return data.entries
        .where((e) => e.value['active'] == true)
        .map((e) => BarberModel.fromMap(e.key, e.value))
        .toList();
  }
}
