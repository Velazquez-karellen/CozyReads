import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double value;
  final double size;

  const StarRating({
    super.key,
    required this.value,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    final fullStars = value.floor();
    final halfStar = (value - fullStars) >= 0.5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < fullStars) {
          return Icon(Icons.star, size: size, color: Colors.amber);
        } else if (i == fullStars && halfStar) {
          return Icon(Icons.star_half, size: size, color: Colors.amber);
        } else {
          return Icon(Icons.star_border, size: size, color: Colors.amber);
        }
      }),
    );
  }
}
