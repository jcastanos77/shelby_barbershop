import 'package:barbershop/services/LandingBarbersService.dart';
import 'package:barbershop/utils/bad_words_filter.dart';
import 'package:flutter/material.dart';

import 'StarRating.dart';
class ReviewsSection extends StatefulWidget {
  const ReviewsSection({super.key});

  @override
  State<ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<ReviewsSection> {
  final service = LandingBarbersService();

  final nameCtrl = TextEditingController();
  final commentCtrl = TextEditingController();

  int rating = 5;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const SizedBox(height: 60),

          const Text(
            "RESEÑAS REALES",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          /// LISTA
          StreamBuilder(
            stream: service.streamReviews(),
            builder: (_, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }

              final reviews = snapshot.data!;

              final avg = reviews.isEmpty
                  ? 0
                  : reviews
                  .map((e) => e.rating)
                  .reduce((a, b) => a + b) /
                  reviews.length;

              return Column(
                children: [

                  /// promedio ⭐
                  Row(
                    children: [
                      StarRating(rating: avg.round()),
                      const SizedBox(width: 8),
                      Text(avg.toStringAsFixed(1)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  ...reviews.map((r) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Row(
                          children: [
                            Expanded(child: Text(r.name)),
                            StarRating(rating: r.rating, size: 18),
                          ],
                        ),
                        subtitle: Text(cleanBadWords(r.comment)),
                      ),
                    );
                  }),
                ],
              );
            },
          ),

          const SizedBox(height: 30),

          const Divider(),

          const Text("Deja tu reseña"),

          const SizedBox(height: 10),

          TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(labelText: "Nombre"),
          ),

          const SizedBox(height: 10),

          TextField(
            controller: commentCtrl,
            decoration: const InputDecoration(labelText: "Comentario"),
            maxLines: 3,
          ),

          const SizedBox(height: 10),

          StarRating(
            rating: rating,
            onChanged: (v) => setState(() => rating = v),
          ),

          const SizedBox(height: 12),

          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty || commentCtrl.text.isEmpty) return;

              await service.addReview(
                nameCtrl.text,
                commentCtrl.text,
                rating,
              );

              nameCtrl.clear();
              commentCtrl.clear();
              setState(() => rating = 5);
            },
            child: const Text("Publicar reseña"),
          ),
        ],
      ),
    );
  }
}
