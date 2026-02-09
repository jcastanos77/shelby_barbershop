import 'package:firebase_database/firebase_database.dart';

import '../models/BarberModel.dart';
import '../models/ReviewModel.dart';

class LandingBarbersService {
  final _ref = FirebaseDatabase.instance.ref('barbers');
  final _refComments = FirebaseDatabase.instance.ref('comments');

  Future<List<BarberModel>> getBarbers() async {
    final snap = await _ref.get();
    if (!snap.exists) return [];

    final data = Map<String, dynamic>.from(snap.value as Map);

    return data.entries
        .where((e) =>
        (e.value['active'] ?? false) == true &&
        (e.value['mpConnected'] ?? false) == true)
        .map((e) => BarberModel.fromMap(e.key, e.value))
        .toList();
  }

  Future<void> addReview(String name, String comment, int rating) async {
    await _refComments.push().set({
      'name': name,
      'comment': comment,
      'rating': rating,
      'createdAt': ServerValue.timestamp,
    });
  }

  Stream<List<ReviewModel>> streamReviews() {
    return _refComments.onValue.map((event) {
      final value = event.snapshot.value;

      if (value == null) return <ReviewModel>[];

      final raw = Map<String, dynamic>.from(value as Map);

      final list = raw.entries.map((e) {
        return ReviewModel.fromMap(
          e.key,
          Map<String, dynamic>.from(e.value),
        );
      }).toList();

      list.sort((a, b) => b.id.compareTo(a.id));

      return list;
    });
  }
}
