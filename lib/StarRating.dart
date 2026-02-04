import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final int rating;
  final Function(int)? onChanged;
  final double size;

  const StarRating({
    super.key,
    required this.rating,
    this.onChanged,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < rating;

        return GestureDetector(
          onTap: onChanged == null ? null : () => onChanged!(i + 1),
          child: Icon(
            filled ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: size,
          ),
        );
      }),
    );
  }
}
